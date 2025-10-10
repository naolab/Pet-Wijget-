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
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let entities = try context.fetch(request)
        return entities.compactMap { $0.toDomain() }
    }

    func fetch(by id: UUID) throws -> Pet? {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let entities = try context.fetch(request)
        return entities.first?.toDomain()
    }

    func create(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let entity = PetEntity(context: context)
        entity.update(from: pet)

        try coreDataStack.saveContext()
    }

    func update(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        entity.update(from: pet)
        try coreDataStack.saveContext()
    }

    func delete(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        context.delete(entity)
        try coreDataStack.saveContext()
    }
}

// MARK: - PetEntity Extensions
extension PetEntity {
    func toDomain() -> Pet? {
        guard let id = id,
              let name = name,
              let birthDate = birthDate,
              let speciesString = species,
              let species = PetType(rawValue: speciesString),
              let createdAt = createdAt,
              let updatedAt = updatedAt else {
            return nil
        }

        return Pet(
            id: id,
            name: name,
            birthDate: birthDate,
            species: species,
            photoData: photoData
        )
    }

    func update(from pet: Pet) {
        self.id = pet.id
        self.name = pet.name
        self.birthDate = pet.birthDate
        self.species = pet.species.rawValue
        self.photoData = pet.photoData
        self.createdAt = pet.createdAt
        self.updatedAt = Date()
    }
}
