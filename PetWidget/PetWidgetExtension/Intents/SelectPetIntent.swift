import AppIntents
import Foundation

// ペット選択用のEntity（名前を変更してCore DataのPetEntityと衝突を回避）
struct WidgetPetEntity: AppEntity, Identifiable {
    typealias ID = UUID

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

// Equatable準拠（AppIntentシステムでの比較のため）
extension WidgetPetEntity: Equatable {
    static func == (lhs: WidgetPetEntity, rhs: WidgetPetEntity) -> Bool {
        lhs.id == rhs.id
    }
}

// Hashable準拠（AppIntentシステムでのキャッシュのため）
extension WidgetPetEntity: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ペット一覧を提供するQuery
struct WidgetPetEntityQuery: EntityQuery {
    // EntityQueryの型を明示的に指定
    typealias Entity = WidgetPetEntity

    func entities(for identifiers: [WidgetPetEntity.ID]) async throws -> [WidgetPetEntity] {
        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.entities called with identifiers: \(identifiers)")
        #endif

        // CoreDataStackが初期化されているか確認
        do {
            try CoreDataStack.shared.setup()
        } catch {
            #if DEBUG
            print("❌ [Intent] WidgetPetEntityQuery.entities: CoreDataStack setup failed: \(error)")
            #endif
            throw error
        }

        let dataManager = PetDataManager.shared
        let pets = try dataManager.fetchAll()

        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.entities: Fetched \(pets.count) pets")
        print("   Pet IDs in database: \(pets.map { $0.id })")
        #endif

        let entities = pets
            .filter { identifiers.contains($0.id) }
            .map { WidgetPetEntity(id: $0.id, name: $0.name) }

        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.entities: Returning \(entities.count) entities")
        if entities.isEmpty && !identifiers.isEmpty {
            print("⚠️ [Intent] No matching entities found for identifiers!")
        }
        #endif

        return entities
    }

    func suggestedEntities() async throws -> [WidgetPetEntity] {
        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.suggestedEntities called")
        #endif

        // CoreDataStackが初期化されているか確認
        try CoreDataStack.shared.setup()

        let dataManager = PetDataManager.shared
        let pets = try dataManager.fetchAll()

        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.suggestedEntities: Fetched \(pets.count) pets")
        for (index, pet) in pets.enumerated() {
            print("   Pet \(index + 1): \(pet.name) (ID: \(pet.id))")
        }
        #endif

        return pets.map { WidgetPetEntity(id: $0.id, name: $0.name) }
    }

    func defaultResult() async -> WidgetPetEntity? {
        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.defaultResult called")
        #endif

        // CoreDataStackが初期化されているか確認
        try? CoreDataStack.shared.setup()

        let dataManager = PetDataManager.shared
        guard let firstPet = try? dataManager.fetchAll().first else {
            #if DEBUG
            print("⚠️ [Intent] WidgetPetEntityQuery.defaultResult: No pets found")
            #endif
            return nil
        }

        #if DEBUG
        print("🔍 [Intent] WidgetPetEntityQuery.defaultResult: Returning \(firstPet.name) (ID: \(firstPet.id))")
        #endif

        return WidgetPetEntity(id: firstPet.id, name: firstPet.name)
    }
}

// ペット選択Intent
struct SelectPetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "ペットを選択"
    static var description = IntentDescription("ウィジェットに表示するペットを選択します")

    // AppEntityの場合はoptionsProviderではなく、defaultQueryを使用
    @Parameter(title: "ペット")
    var selectedPet: WidgetPetEntity?

    init(selectedPet: WidgetPetEntity? = nil) {
        self.selectedPet = selectedPet
    }

    init() {
        self.selectedPet = nil
    }
}
