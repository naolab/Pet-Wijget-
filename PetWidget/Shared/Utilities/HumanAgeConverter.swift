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

        case .smallAnimal:
            // 小動物（ハムスター、ウサギなど）は1年=15歳程度
            return Int(realAge * 15)

        case .bird:
            // 鳥は種類によって寿命が大きく異なるが、平均的に1年=7歳程度
            return Int(realAge * 7)

        case .turtle:
            // カメは長寿なので1年=2歳程度
            return Int(realAge * 2)

        case .fish:
            // 魚は種類によって異なるが、平均的に1年=10歳程度
            return Int(realAge * 10)

        case .insect:
            // 虫は寿命が短いため、1年=30歳程度
            return Int(realAge * 30)

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
