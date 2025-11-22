import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    private(set) var persistentContainer: NSPersistentContainer?
    private(set) var initializationError: Error?

    private var isSetup = false

    private init() {
        #if DEBUG
        print("✅ CoreDataStack: Singleton initialized.")
        #endif
    }

    func setup() throws {
        guard !isSetup else {
            #if DEBUG
            print("ℹ️ CoreDataStack: Already set up.")
            #endif
            return
        }
        
        #if DEBUG
        print("🔄 CoreDataStack: Starting setup...")
        #endif

        do {
            persistentContainer = try createPersistentContainer()
            isSetup = true
            #if DEBUG
            print("✅ CoreDataStack: Setup finished successfully.")
            #endif
        } catch {
            initializationError = error
            #if DEBUG
            print("❌ CoreDataStack: Setup failed with error: \(error)")
            #endif
            throw error
        }
    }

    private func loadCoreDataModel() throws -> NSManagedObjectModel {
        #if DEBUG
        print("🔄 CoreDataStack: Loading Core Data model...")
        #endif
        
        // CoreDataStackクラスが定義されているバンドルを優先的に探す
        let bundle = Bundle(for: CoreDataStack.self)
        if let url = bundle.url(forResource: "PetWidget", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: url) {
            #if DEBUG
            print("✅ CoreDataStack: Model found in bundle: \(bundle.bundleIdentifier ?? "unknown")")
            #endif
            return model
        }
        
        // フォールバック: メインバンドルを探す
        if let url = Bundle.main.url(forResource: "PetWidget", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: url) {
            #if DEBUG
            print("✅ CoreDataStack: Model found in main bundle (fallback).")
            #endif
            return model
        }

        #if DEBUG
        print("⚠️ CoreDataStack: Model not found in specific bundles, searching all bundles...")
        #endif
        for bundle in Bundle.allBundles {
            if let url = bundle.url(forResource: "PetWidget", withExtension: "momd"),
               let model = NSManagedObjectModel(contentsOf: url) {
                #if DEBUG
                print("✅ CoreDataStack: Model found in bundle: \(bundle.bundleIdentifier ?? "unknown")")
                #endif
                return model
            }
        }

        #if DEBUG
        print("❌ CoreDataStack: Failed to load model from any bundle.")
        #endif
        throw PetWidgetError.coreDataError(NSError(
            domain: "CoreDataStack", code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "CoreDataモデルファイルが見つかりません"]
        ))
    }

    private func createPersistentContainer() throws -> NSPersistentContainer {
        let managedObjectModel = try loadCoreDataModel()
        let container = NSPersistentContainer(name: "PetWidget", managedObjectModel: managedObjectModel)

        #if DEBUG
        print("🔄 CoreDataStack: Getting App Group container URL...")
        #endif
        guard let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConfig.appGroupID
        )?.appendingPathComponent("PetWidget.sqlite") else {
            #if DEBUG
            print("❌ CoreDataStack: App Group Container URL is nil for ID: \(AppConfig.appGroupID)")
            #endif
            throw PetWidgetError.coreDataError(NSError(
                domain: "CoreDataStack", code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "App Group Containerにアクセスできません"]
            ))
        }
        #if DEBUG
        print("✅ CoreDataStack: Store URL is \(storeURL.path)")
        #endif

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [storeDescription]

        #if DEBUG
        print("🔄 CoreDataStack: Loading persistent stores...")
        #endif
        var loadError: Error?
        container.loadPersistentStores { description, error in
            if let error = error {
                #if DEBUG
                print("❌ CoreDataStack: Failed to load persistent store: \(error)")
                #endif
                loadError = error
            } else {
                #if DEBUG
                print("✅ CoreDataStack: Persistent store loaded successfully.")
                #endif
            }
        }

        if let loadError = loadError {
            throw loadError
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }

    var viewContext: NSManagedObjectContext {
        get throws {
            if let error = initializationError { throw error }
            guard let container = persistentContainer else {
                throw PetWidgetError.coreDataError(NSError(
                    domain: "CoreDataStack", code: 1000,
                    userInfo: [NSLocalizedDescriptionKey: "CoreDataが初期化されていません。setup()が呼ばれていません。"]
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