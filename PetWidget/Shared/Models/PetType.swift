import Foundation

enum PetType: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case other = "other"

    var displayName: String {
        switch self {
        case .dog: return "犬"
        case .cat: return "猫"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .other: return "🐾"
        }
    }
}
