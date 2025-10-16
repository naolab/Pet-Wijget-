import Foundation

final class HumanAgeConverter {
    /// ペットの実年齢を人間年齢に換算
    /// - Parameters:
    ///   - pet: 換算対象のペット
    ///   - customLifespan: カスタム平均寿命（nilの場合はデフォルト値を使用）
    /// - Returns: 人間年齢（歳）
    static func convert(pet: Pet, customLifespan: Double? = nil) -> Int {
        let profile = pet.species.ageConversionProfile
        let realAge = Double(pet.ageInYears)
        return profile.calculateHumanAge(realAge: realAge, customLifespan: customLifespan)
    }

    /// 人間年齢を文字列で返す
    /// - Parameters:
    ///   - pet: 対象のペット
    ///   - customLifespan: カスタム平均寿命（nilの場合はデフォルト値を使用）
    /// - Returns: "人間年齢: XX歳" 形式の文字列
    static func humanAgeString(for pet: Pet, customLifespan: Double? = nil) -> String {
        let humanAge = convert(pet: pet, customLifespan: customLifespan)
        return "人間年齢: \(humanAge)歳"
    }
}
