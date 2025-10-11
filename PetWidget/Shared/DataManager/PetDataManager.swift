import CoreData
import Foundation

protocol PetDataManagerProtocol {
    func fetchAll() throws -> [Pet]
    func fetch(by id: UUID) throws -> Pet?
    func create(_ pet: Pet) throws
    func update(_ pet: Pet) throws
    func delete(_ pet: Pet) throws
}

final class PetDataManager: PetDataManagerProtocol {
    static let shared = PetDataManager()

    private let coreDataStack: CoreDataStack

    private init() {
        self.coreDataStack = CoreDataStack.shared
    }

    func fetchAll() throws -> [Pet] {
        let context = try coreDataStack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let entities = try context.fetch(request)
        return entities.compactMap { toDomain(from: $0) }
    }

    func fetch(by id: UUID) throws -> Pet? {
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

    // MARK: - Private Helpers

    private func toDomain(from entity: NSManagedObject) -> Pet? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let name = entity.value(forKey: "name") as? String,
              let birthDate = entity.value(forKey: "birthDate") as? Date,
              let speciesString = entity.value(forKey: "species") as? String,
              let species = PetType(rawValue: speciesString),
              let _ = entity.value(forKey: "createdAt") as? Date else {
            return nil
        }

        let photoData = entity.value(forKey: "photoData") as? Data

        return Pet(
            id: id,
            name: name,
            birthDate: birthDate,
            species: species,
            photoData: photoData
        )
    }

    private func update(entity: NSManagedObject, from pet: Pet) {
        entity.setValue(pet.id, forKey: "id")
        entity.setValue(pet.name, forKey: "name")
        entity.setValue(pet.birthDate, forKey: "birthDate")
        entity.setValue(pet.species.rawValue, forKey: "species")
        entity.setValue(pet.photoData, forKey: "photoData")
        entity.setValue(pet.createdAt, forKey: "createdAt")
        entity.setValue(Date(), forKey: "updatedAt")
    }
}
