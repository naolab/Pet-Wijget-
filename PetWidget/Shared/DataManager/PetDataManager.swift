import CoreData
import Foundation

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
        self.coreDataStack = CoreDataStack.shared
        // App Group用のUserDefaultsを取得
        guard let userDefaults = UserDefaults(suiteName: AppConfig.appGroupID) else {
            fatalError("Failed to initialize UserDefaults with App Group ID: \(AppConfig.appGroupID)")
        }
        self.userDefaults = userDefaults
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
    }

    // MARK: - Persistent History Tracking

    private func mergeChanges() throws {
        let context = try coreDataStack.viewContext
        
        try context.performAndWait {
            let historyRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            
            guard let historyResult = try? context.execute(historyRequest) as? NSPersistentHistoryResult,
                  let history = historyResult.history,
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
        entity.setValue(pet.originalPhotoData, forKey: "originalPhotoData")
        entity.setValue(pet.createdAt, forKey: "createdAt")
        entity.setValue(Date(), forKey: "updatedAt")
        entity.setValue(pet.displayOrder, forKey: "displayOrder")
        entity.setValue(pet.breed, forKey: "breed")
    }
}