import AppIntents
import Foundation

// ペット選択用のEntity（名前を変更してCore DataのPetEntityと衝突を回避）
struct WidgetPetEntity: AppEntity {
    let id: UUID
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "ペット")
    }

    static var defaultQuery = WidgetPetEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

// ペット一覧を提供するQuery
struct WidgetPetEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetPetEntity] {
        let dataManager = PetDataManager.shared
        let pets = try dataManager.fetchAll()

        return pets
            .filter { identifiers.contains($0.id) }
            .map { WidgetPetEntity(id: $0.id, name: $0.name) }
    }

    func suggestedEntities() async throws -> [WidgetPetEntity] {
        let dataManager = PetDataManager.shared
        let pets = try dataManager.fetchAll()

        return pets.map { WidgetPetEntity(id: $0.id, name: $0.name) }
    }

    func defaultResult() async -> WidgetPetEntity? {
        let dataManager = PetDataManager.shared
        guard let firstPet = try? dataManager.fetchAll().first else {
            return nil
        }
        return WidgetPetEntity(id: firstPet.id, name: firstPet.name)
    }
}

// ペット選択Intent
struct SelectPetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "ペットを選択"
    static var description = IntentDescription("ウィジェットに表示するペットを選択します")

    @Parameter(title: "ペット", optionsProvider: PetOptionsProvider())
    var selectedPet: WidgetPetEntity?

    init(selectedPet: WidgetPetEntity? = nil) {
        self.selectedPet = selectedPet
    }

    init() {
        self.selectedPet = nil
    }
}

// ペット選択のオプションプロバイダー
struct PetOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [WidgetPetEntity] {
        let dataManager = PetDataManager.shared
        let pets = try dataManager.fetchAll()

        return pets.map { WidgetPetEntity(id: $0.id, name: $0.name) }
    }

    func defaultResult() async -> WidgetPetEntity? {
        let dataManager = PetDataManager.shared
        guard let firstPet = try? dataManager.fetchAll().first else {
            return nil
        }
        return WidgetPetEntity(id: firstPet.id, name: firstPet.name)
    }
}
