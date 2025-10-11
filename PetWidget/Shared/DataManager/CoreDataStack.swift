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
            print("❌ CoreData: Initialization failed: \(error)")
        }
    }

    private func createPersistentContainer() throws -> NSPersistentContainer {
        // モデルファイルのURLを取得
        // まずBundle.mainを試し、見つからなければ全てのBundleから探す
        var modelURL: URL?
        var managedObjectModel: NSManagedObjectModel?

        if let url = Bundle.main.url(forResource: "PetWidget", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: url) {
            modelURL = url
            managedObjectModel = model
            print("✅ CoreData: Model found in main bundle")
        } else {
            // Widget ExtensionなどでBundle.mainが見つからない場合、全Bundleを検索
            print("⚠️ CoreData: Model not found in main bundle, searching all bundles...")
            for bundle in Bundle.allBundles {
                if let url = bundle.url(forResource: "PetWidget", withExtension: "momd"),
                   let model = NSManagedObjectModel(contentsOf: url) {
                    modelURL = url
                    managedObjectModel = model
                    print("✅ CoreData: Model found in bundle: \(bundle.bundleIdentifier ?? "unknown")")
                    break
                }
            }
        }

        guard let modelURL = modelURL,
              let managedObjectModel = managedObjectModel else {
            print("❌ CoreData: Failed to load model file from any bundle")
            print("❌ CoreData: Searched bundles:")
            for bundle in Bundle.allBundles {
                print("  - \(bundle.bundleIdentifier ?? "unknown"): \(bundle.bundlePath)")
            }
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
            print("❌ CoreData: App Group Container URL is nil!")
            throw PetWidgetError.coreDataError(NSError(
                domain: "CoreDataStack",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "App Group Container (\(AppConfig.appGroupID)) にアクセスできません"]
            ))
        }

        print("📦 CoreData: App Group ID = \(AppConfig.appGroupID)")
        print("📦 CoreData: Store URL = \(storeURL.path)")
        print("📦 CoreData: Model URL = \(modelURL.path)")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]

        var loadError: Error?
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ CoreData: Failed to load store: \(error)")
                loadError = error
            } else {
                print("✅ CoreData: Store loaded successfully at \(description.url?.path ?? "unknown")")
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
