import Foundation

final class HumanAgeConverter {
    static func convert(pet: Pet) -> Int {
        let realAge = Double(pet.ageInYears)

        switch pet.species {
        case .dog, .cat:
            // 最初の2年は1年=12歳、以降は1年=4歳で計算
            if realAge <= 2 {
                return Int(realAge * 12)
            } else {
                return Int(24 + (realAge - 2) * 4)
            }

        case .other:
            // その他は単純に5倍
            return Int(realAge * 5)
        }
    }

    static func humanAgeString(for pet: Pet) -> String {
        let humanAge = convert(pet: pet)
        return "人間年齢: \(humanAge)歳"
    }
}
