import CoreData
import Foundation
import UIKit
import WidgetKit

enum PetSortOption {
    case displayOrder   // カスタム並び順
    case name           // 名前順
    case birthDate      // 誕生日順（古い順）
    case species        // 種別順
}

protocol PetDataManagerProtocol {
    func fetchAll(sortBy: PetSortOption) throws -> [Pet]
    func fetch(by id: UUID) throws -> Pet?
    func create(_ pet: Pet) throws
    func update(_ pet: Pet) throws
    func delete(_ pet: Pet) throws
    func updateDisplayOrders(_ pets: [Pet]) throws
    func migrateWidgetData()
}

final class PetDataManager: PetDataManagerProtocol {
    static let shared = PetDataManager()

    private let coreDataStack: CoreDataStack
    private let userDefaults: UserDefaults

    // 履歴追跡用のプロパティ
    private let historyTokenKey = "PetDataManager.historyToken"
    private var lastHistoryToken: NSPersistentHistoryToken? {
        get {
            guard let data = userDefaults.data(forKey: historyTokenKey) else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
        }
        set {
            guard let token = newValue,
                  let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
                userDefaults.removeObject(forKey: historyTokenKey)
                return
            }
            userDefaults.set(data, forKey: historyTokenKey)
        }
    }

    private init() {
        #if DEBUG
        print("✅ PetDataManager: Singleton initialized.")
        #endif
        self.coreDataStack = CoreDataStack.shared
        do {
            try self.coreDataStack.setup()
        } catch {
            #if DEBUG
            print("❌ PetDataManager: Failed to setup CoreDataStack during init. Error: \(error)")
            #endif
        }

        // App Group用のUserDefaultsを取得
        guard let userDefaults = UserDefaults(suiteName: AppConfig.appGroupID) else {
            #if DEBUG
            print("❌ PetDataManager: Failed to initialize UserDefaults with App Group ID. This will cause a crash.")
            #endif
            fatalError("Failed to initialize UserDefaults with App Group ID: \(AppConfig.appGroupID)")
        }
        self.userDefaults = userDefaults
        #if DEBUG
        print("✅ PetDataManager: UserDefaults initialized successfully.")
        #endif
    }

    func fetchAll(sortBy: PetSortOption = .displayOrder) throws -> [Pet] {
        try mergeChanges() // 変更をマージ

        let context = try coreDataStack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")

        // ソート条件を設定
        switch sortBy {
        case .displayOrder:
            request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]
        case .name:
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        case .birthDate:
            request.sortDescriptors = [NSSortDescriptor(key: "birthDate", ascending: true)]
        case .species:
            request.sortDescriptors = [
                NSSortDescriptor(key: "species", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]
        }

        let entities = try context.fetch(request)
        return entities.compactMap { toDomain(from: $0) }
    }

    func fetch(by id: UUID) throws -> Pet? {
        try mergeChanges() // 変更をマージ

        let context = try coreDataStack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let entities = try context.fetch(request)
        return entities.first.flatMap { toDomain(from: $0) }
    }

    func create(_ pet: Pet) throws {
        let context = try coreDataStack.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PetEntity", into: context)
        update(entity: entity, from: pet)

        try coreDataStack.saveContext()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func update(_ pet: Pet) throws {
        let context = try coreDataStack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        update(entity: entity, from: pet)
        try coreDataStack.saveContext()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func delete(_ pet: Pet) throws {
        let context = try coreDataStack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        context.delete(entity)
        try coreDataStack.saveContext()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateDisplayOrders(_ pets: [Pet]) throws {
        let context = try coreDataStack.viewContext

        for (index, pet) in pets.enumerated() {
            let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
            request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
            request.fetchLimit = 1

            if let entity = try context.fetch(request).first {
                entity.setValue(index, forKey: "displayOrder")
            }
        }

        try coreDataStack.saveContext()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func migrateWidgetData() {
        do {
            let context = try coreDataStack.viewContext
            let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
            
            // widgetPhotoDataが未設定で、かつphotoDataが存在するデータのみを取得
            request.predicate = NSPredicate(format: "widgetPhotoData == nil AND photoData != nil")
            
            let entities = try context.fetch(request)
            
            if entities.isEmpty {
                return
            }

            print("🔄 PetDataManager: Found \(entities.count) pets needing widget data migration.")
            var hasChanges = false
            var successCount = 0
            var failCount = 0

            for entity in entities {
                let name = entity.value(forKey: "name") as? String ?? "Unknown"
                
                guard let photoData = entity.value(forKey: "photoData") as? Data,
                      let image = UIImage(data: photoData),
                      let widgetData = PhotoManager.shared.processImageForWidget(image) else {
                    failCount += 1
                    #if DEBUG
                    print("❌ PetDataManager: Failed to process image for: \(name)")
                    #endif
                    continue
                }

                entity.setValue(widgetData, forKey: "widgetPhotoData")
                hasChanges = true
                successCount += 1
            }

            if hasChanges {
                try coreDataStack.saveContext()
                #if DEBUG
                print("✅ PetDataManager: Migration completed. Success: \(successCount), Failed: \(failCount)")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ PetDataManager: Migration failed with error: \(error)")
            #endif
        }
    }

    // MARK: - Persistent History Tracking

    private func mergeChanges() throws {
        let context = try coreDataStack.viewContext
        
        context.performAndWait {
            do {
                let historyRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
                
                guard let historyResult = try context.execute(historyRequest) as? NSPersistentHistoryResult,
                      let history = historyResult.result as? [NSPersistentHistoryTransaction],
                      !history.isEmpty else {
                    return
                }

                #if DEBUG
                print("🔄 PetDataManager: Found \(history.count) new transaction(s) to merge.")
                #endif

                for transaction in history {
                    context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                }

                if let lastToken = history.last?.token {
                     if self.lastHistoryToken != lastToken {
                         #if DEBUG
                         print("✅ PetDataManager: Merged changes. New token saved.")
                         #endif
                         self.lastHistoryToken = lastToken
                     }
                }
            } catch {
                #if DEBUG
                print("❌ PetDataManager: Failed to merge history: \(error)")
                #endif
            }
        }
    }

    // MARK: - Private Helpers

    private func toDomain(from entity: NSManagedObject) -> Pet? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let name = entity.value(forKey: "name") as? String,
              let birthDate = entity.value(forKey: "birthDate") as? Date,
              let speciesString = entity.value(forKey: "species") as? String,
              let species = PetType(rawValue: speciesString),
              let createdAt = entity.value(forKey: "createdAt") as? Date else {
            return nil
        }

        let photoData = entity.value(forKey: "photoData") as? Data
        let widgetPhotoData = entity.value(forKey: "widgetPhotoData") as? Data
        let originalPhotoData = entity.value(forKey: "originalPhotoData") as? Data
        let displayOrder = entity.value(forKey: "displayOrder") as? Int ?? 0
        let updatedAt = entity.value(forKey: "updatedAt") as? Date ?? createdAt
        let breed = entity.value(forKey: "breed") as? String

        var pet = Pet(
            id: id,
            name: name,
            birthDate: birthDate,
            species: species,
            photoData: photoData,
            widgetPhotoData: widgetPhotoData,
            originalPhotoData: originalPhotoData,
            displayOrder: displayOrder,
            breed: breed
        )
        pet.createdAt = createdAt
        pet.updatedAt = updatedAt

        return pet
    }

    private func update(entity: NSManagedObject, from pet: Pet) {
        entity.setValue(pet.id, forKey: "id")
        entity.setValue(pet.name, forKey: "name")
        entity.setValue(pet.birthDate, forKey: "birthDate")
        entity.setValue(pet.species.rawValue, forKey: "species")
        entity.setValue(pet.photoData, forKey: "photoData")
        entity.setValue(pet.displayOrder, forKey: "displayOrder")
        entity.setValue(pet.breed, forKey: "breed")
        
        // widgetPhotoDataをphotoDataから自動生成して保存（常に同期させる）
        if let photoData = pet.photoData,
           let image = UIImage(data: photoData),
           let widgetData = PhotoManager.shared.processImageForWidget(image) {
            entity.setValue(widgetData, forKey: "widgetPhotoData")
        } else {
            // photoDataがない、または生成失敗した場合はnilにする
            entity.setValue(nil, forKey: "widgetPhotoData")
        }
    }
}