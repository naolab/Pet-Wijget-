import Foundation

struct Pet: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var species: PetType
    var photoData: Data?
    var createdAt: Date
    var updatedAt: Date
    var displayOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        species: PetType,
        photoData: Data? = nil,
        displayOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.species = species
        self.photoData = photoData
        self.createdAt = Date()
        self.updatedAt = Date()
        self.displayOrder = displayOrder
    }

    // 年齢計算(年単位)
    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    // 年齢計算(月単位まで)
    var ageComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
    }

    // 人間換算年齢
    var humanAge: Int {
        HumanAgeConverter.convert(pet: self)
    }
}
