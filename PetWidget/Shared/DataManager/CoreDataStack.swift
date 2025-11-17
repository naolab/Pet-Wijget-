import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    private(set) var persistentContainer: NSPersistentContainer?
    private(set) var initializationError: Error?

    private init() {
        do {
            self.persistentContainer = try createPersistentContainer()
        } catch {
            self.initializationError = error
            #if DEBUG
            print("❌ CoreData: Initialization failed: \(error)")
            #endif
        }
    }

    private func loadCoreDataModel() -> (URL, NSManagedObjectModel)? {
        // まずBundle.mainを試す
        if let url = Bundle.main.url(forResource: "PetWidget", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: url) {
            #if DEBUG
            print("✅ CoreData: Model found in main bundle")
            #endif
            return (url, model)
        }

        // Widget Extensionなどで見つからない場合、全Bundleを検索
        #if DEBUG
        print("⚠️ CoreData: Model not found in main bundle, searching all bundles...")
        #endif

        for bundle in Bundle.allBundles {
            if let url = bundle.url(forResource: "PetWidget", withExtension: "momd"),
               let model = NSManagedObjectModel(contentsOf: url) {
                #if DEBUG
                print("✅ CoreData: Model found in bundle: \(bundle.bundleIdentifier ?? "unknown")")
                #endif
                return (url, model)
            }
        }

        #if DEBUG
        print("❌ CoreData: Failed to load model file from any bundle")
        Bundle.allBundles.forEach { bundle in
            print("  - \(bundle.bundleIdentifier ?? "unknown"): \(bundle.bundlePath)")
        }
        #endif

        return nil
    }

    private func createPersistentContainer() throws -> NSPersistentContainer {
        // モデルファイルの取得
        guard let (modelURL, managedObjectModel) = loadCoreDataModel() else {
            throw PetWidgetError.coreDataError(NSError(
                domain: "CoreDataStack",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "CoreDataモデルファイルが見つかりません"]
            ))
        }

        let container = NSPersistentContainer(name: "PetWidget", managedObjectModel: managedObjectModel)

        // App Group Containerに保存
        guard let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConfig.appGroupID
        )?.appendingPathComponent("PetWidget.sqlite") else {
            #if DEBUG
            print("❌ CoreData: App Group Container URL is nil!")
            #endif
            throw PetWidgetError.coreDataError(NSError(
                domain: "CoreDataStack",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "App Group Container (\(AppConfig.appGroupID)) にアクセスできません"]
            ))
        }

        #if DEBUG
        print("📦 CoreData: App Group ID = \(AppConfig.appGroupID)")
        print("📦 CoreData: Store URL = \(storeURL.path)")
        print("📦 CoreData: Model URL = \(modelURL.path)")
        #endif

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [storeDescription]

        var loadError: Error?
        container.loadPersistentStores { description, error in
            if let error = error {
                #if DEBUG
                print("❌ CoreData: Failed to load store: \(error)")
                #endif
                loadError = error
            } else {
                #if DEBUG
                print("✅ CoreData: Store loaded successfully at \(description.url?.path ?? "unknown")")
                #endif
            }
        }

        if let loadError = loadError {
            throw PetWidgetError.coreDataError(loadError as NSError)
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }

    var viewContext: NSManagedObjectContext {
        get throws {
            if let error = initializationError {
                throw error
            }
            guard let container = persistentContainer else {
                throw PetWidgetError.coreDataError(NSError(
                    domain: "CoreDataStack",
                    code: 1000,
                    userInfo: [NSLocalizedDescriptionKey: "CoreDataが初期化されていません"]
                ))
            }
            return container.viewContext
        }
    }

    func saveContext() throws {
        let context = try viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
