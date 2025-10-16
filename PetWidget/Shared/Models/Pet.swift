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

// MARK: - AgeConversionProfile

/// ペットの年齢を人間年齢に換算するためのプロファイル
/// 各動物種の成長特性(急成長期の割合と目標年齢)を定義
struct AgeConversionProfile {
    /// 急成長期の割合(平均寿命に対する比率)
    /// 例: 0.167 = 平均寿命の1/6が急成長期
    let earlyGrowthRatio: Double

    /// 急成長期終了時点の人間年齢
    /// 例: 24歳(犬猫は約2歳で人間の24歳相当)
    let earlyGrowthTarget: Double

    /// デフォルト平均寿命(年)
    let defaultLifespan: Double

    /// 人間の平均寿命(固定値)
    static let humanLifespan: Double = 85.0

    /// 人間年齢を計算
    /// - Parameters:
    ///   - realAge: ペットの実年齢
    ///   - customLifespan: カスタム平均寿命(nilの場合はdefaultLifespanを使用)
    /// - Returns: 人間年齢
    func calculateHumanAge(realAge: Double, customLifespan: Double? = nil) -> Int {
        let lifespan = customLifespan ?? defaultLifespan
        let earlyYears = lifespan * earlyGrowthRatio

        if realAge <= earlyYears {
            // 急成長期:線形でearlyGrowthTargetまで成長
            return Int((realAge / earlyYears) * earlyGrowthTarget)
        } else {
            // 安定成長期:残りの人生で85歳まで成長
            let remainingYears = lifespan - earlyYears
            let remainingHumanAge = Self.humanLifespan - earlyGrowthTarget
            let humanAge = earlyGrowthTarget + ((realAge - earlyYears) / remainingYears) * remainingHumanAge
            return Int(humanAge)
        }
    }
}

// MARK: - 各動物種のプロファイル定義

extension AgeConversionProfile {
    /// 犬のプロファイル
    static let dog = AgeConversionProfile(
        earlyGrowthRatio: 0.167,
        earlyGrowthTarget: 24,
        defaultLifespan: 12
    )

    /// 猫のプロファイル
    static let cat = AgeConversionProfile(
        earlyGrowthRatio: 0.133,
        earlyGrowthTarget: 24,
        defaultLifespan: 15
    )

    /// 魚のプロファイル
    static let fish = AgeConversionProfile(
        earlyGrowthRatio: 0.2,
        earlyGrowthTarget: 24,
        defaultLifespan: 5
    )

    /// 小動物(ハムスター、ウサギなど)のプロファイル
    static let smallAnimal = AgeConversionProfile(
        earlyGrowthRatio: 0.25,
        earlyGrowthTarget: 30,
        defaultLifespan: 4
    )

    /// カメのプロファイル
    static let turtle = AgeConversionProfile(
        earlyGrowthRatio: 0.1,
        earlyGrowthTarget: 20,
        defaultLifespan: 30
    )

    /// 鳥のプロファイル
    static let bird = AgeConversionProfile(
        earlyGrowthRatio: 0.2,
        earlyGrowthTarget: 28,
        defaultLifespan: 10
    )

    /// 虫のプロファイル
    static let insect = AgeConversionProfile(
        earlyGrowthRatio: 0.3,
        earlyGrowthTarget: 35,
        defaultLifespan: 1
    )

    /// その他のプロファイル
    static let other = AgeConversionProfile(
        earlyGrowthRatio: 0.2,
        earlyGrowthTarget: 25,
        defaultLifespan: 10
    )
}
