import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PetWidget")

        // App Group Containerに保存
        let storeURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConfig.appGroupID
        )?.appendingPathComponent("PetWidget.sqlite")

        if let storeURL = storeURL {
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
