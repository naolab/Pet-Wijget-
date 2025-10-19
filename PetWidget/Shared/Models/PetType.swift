import Foundation

enum PetType: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case fish = "fish"
    case smallAnimal = "smallAnimal"
    case turtle = "turtle"
    case bird = "bird"
    case insect = "insect"
    case other = "other"

    var displayName: String {
        switch self {
        case .dog: return "犬"
        case .cat: return "猫"
        case .fish: return "魚"
        case .smallAnimal: return "小動物"
        case .turtle: return "カメ"
        case .bird: return "鳥"
        case .insect: return "虫"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .fish: return "🐟"
        case .smallAnimal: return "🐹"
        case .turtle: return "🐢"
        case .bird: return "🐦"
        case .insect: return "🐛"
        case .other: return "🐾"
        }
    }

    /// 年齢換算プロファイルを取得
    var ageConversionProfile: AgeConversionProfile {
        switch self {
        case .dog: return .dog
        case .cat: return .cat
        case .fish: return .fish
        case .smallAnimal: return .smallAnimal
        case .turtle: return .turtle
        case .bird: return .bird
        case .insect: return .insect
        case .other: return .other
        }
    }
}
