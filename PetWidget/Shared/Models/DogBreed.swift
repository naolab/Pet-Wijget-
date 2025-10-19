import Foundation

/// 犬種の定義
enum DogBreed: String, Codable, CaseIterable {
    // MARK: - 小型犬（19種）
    case toyPoodle = "toyPoodle"
    case miniatureDachshund = "miniatureDachshund"
    case papillon = "papillon"
    case italianGreyhound = "italianGreyhound"
    case miniaturePinscher = "miniaturePinscher"
    case shihTzu = "shihTzu"
    case chihuahua = "chihuahua"
    case westHighlandWhiteTerrier = "westHighlandWhiteTerrier"
    case yorkshireTerrier = "yorkshireTerrier"
    case pomeranian = "pomeranian"
    case maltese = "maltese"
    case miniatureSchnauzer = "miniatureSchnauzer"
    case pekingese = "pekingese"
    case japaneseSpitz = "japaneseSpitz"
    case norfolkTerrier = "norfolkTerrier"
    case pug = "pug"
    case cavalierKingCharlesSpaniel = "cavalierKingCharlesSpaniel"
    case bostonTerrier = "bostonTerrier"
    case japaneseChin = "japaneseChin"

    // MARK: - 中型犬（15種）
    case shibaInu = "shibaInu"
    case kaiKen = "kaiKen"
    case hokkaidoKen = "hokkaidoKen"
    case englishCockerSpaniel = "englishCockerSpaniel"
    case beagle = "beagle"
    case americanCockerSpaniel = "americanCockerSpaniel"
    case borderCollie = "borderCollie"
    case welshCorgiPembroke = "welshCorgiPembroke"
    case shetlandSheepdog = "shetlandSheepdog"
    case akitaInu = "akitaInu"
    case siberianHusky = "siberianHusky"
    case frenchBulldog = "frenchBulldog"
    case shikokuKen = "shikokuKen"
    case germanShepherd = "germanShepherd"
    case englishBulldog = "englishBulldog"

    // MARK: - 大型犬（5種）
    case labradorRetriever = "labradorRetriever"
    case goldenRetriever = "goldenRetriever"
    case dobermanPinscher = "dobermanPinscher"
    case berneseMountainDog = "berneseMountainDog"
    case greatDane = "greatDane"

    // MARK: - ミックス・その他
    case smallMix = "smallMix"
    case largeMix = "largeMix"
    case unknown = "unknown"

    /// 日本語表示名
    var displayName: String {
        switch self {
        // 小型犬
        case .toyPoodle: return "トイ・プードル"
        case .miniatureDachshund: return "ミニチュア・ダックスフンド"
        case .papillon: return "パピヨン"
        case .italianGreyhound: return "イタリアン・グレーハウンド"
        case .miniaturePinscher: return "ミニチュア・ピンシャー"
        case .shihTzu: return "シー・ズー"
        case .chihuahua: return "チワワ"
        case .westHighlandWhiteTerrier: return "ウエスト・ハイランド・ホワイト・テリア"
        case .yorkshireTerrier: return "ヨークシャー・テリア"
        case .pomeranian: return "ポメラニアン"
        case .maltese: return "マルチーズ"
        case .miniatureSchnauzer: return "ミニチュア・シュナウザー"
        case .pekingese: return "ペキニーズ"
        case .japaneseSpitz: return "日本スピッツ"
        case .norfolkTerrier: return "ノーフォーク・テリア"
        case .pug: return "パグ"
        case .cavalierKingCharlesSpaniel: return "キャバリア・キング・チャールズ・スパニエル"
        case .bostonTerrier: return "ボストン・テリア"
        case .japaneseChin: return "狆（チン）"

        // 中型犬
        case .shibaInu: return "柴犬"
        case .kaiKen: return "甲斐犬"
        case .hokkaidoKen: return "北海道犬"
        case .englishCockerSpaniel: return "イングリッシュ・コッカー・スパニエル"
        case .beagle: return "ビーグル"
        case .americanCockerSpaniel: return "アメリカン・コッカー・スパニエル"
        case .borderCollie: return "ボーダー・コリー"
        case .welshCorgiPembroke: return "ウェルシュ・コーギー・ペンブローク"
        case .shetlandSheepdog: return "シェットランド・シープドッグ"
        case .akitaInu: return "秋田犬"
        case .siberianHusky: return "シベリアン・ハスキー"
        case .frenchBulldog: return "フレンチ・ブルドッグ"
        case .shikokuKen: return "四国犬"
        case .germanShepherd: return "ジャーマン・シェパード・ドッグ"
        case .englishBulldog: return "イングリッシュ・ブルドッグ"

        // 大型犬
        case .labradorRetriever: return "ラブラドール・レトリーバー"
        case .goldenRetriever: return "ゴールデン・レトリーバー"
        case .dobermanPinscher: return "ドーベルマン"
        case .berneseMountainDog: return "バーニーズ・マウンテン・ドッグ"
        case .greatDane: return "グレート・デーン"

        // ミックス・その他
        case .smallMix: return "ミックス（小型）"
        case .largeMix: return "ミックス（大型）"
        case .unknown: return "不明・その他"
        }
    }

    /// 平均寿命（年）
    var averageLifespan: Double {
        switch self {
        // 小型犬
        case .toyPoodle: return 15.3
        case .miniatureDachshund: return 14.9
        case .papillon: return 14.5
        case .italianGreyhound: return 14.5
        case .miniaturePinscher: return 14.3
        case .shihTzu: return 14.0
        case .chihuahua: return 13.9
        case .westHighlandWhiteTerrier: return 13.9
        case .yorkshireTerrier: return 13.8
        case .pomeranian: return 13.7
        case .maltese: return 13.6
        case .miniatureSchnauzer: return 13.6
        case .pekingese: return 13.1
        case .japaneseSpitz: return 13.1
        case .norfolkTerrier: return 12.7
        case .pug: return 12.6
        case .cavalierKingCharlesSpaniel: return 12.4
        case .bostonTerrier: return 12.3
        case .japaneseChin: return 13.0  // 12-14歳の中間値

        // 中型犬
        case .shibaInu: return 14.7
        case .kaiKen: return 14.3
        case .hokkaidoKen: return 14.0
        case .englishCockerSpaniel: return 14.1
        case .beagle: return 13.3
        case .americanCockerSpaniel: return 13.2
        case .borderCollie: return 13.0
        case .welshCorgiPembroke: return 12.3
        case .shetlandSheepdog: return 12.3
        case .akitaInu: return 11.8
        case .siberianHusky: return 11.3
        case .frenchBulldog: return 11.1
        case .shikokuKen: return 11.0
        case .germanShepherd: return 11.0  // 10-12歳の中間値
        case .englishBulldog: return 8.7

        // 大型犬
        case .labradorRetriever: return 12.7
        case .goldenRetriever: return 10.9
        case .dobermanPinscher: return 11.0  // 10-12歳の中間値
        case .berneseMountainDog: return 8.8
        case .greatDane: return 7.5  // 7-8歳の中間値

        // ミックス・その他
        case .smallMix: return 15.0
        case .largeMix: return 13.0
        case .unknown: return 12.0  // デフォルト値
        }
    }

    /// サイズカテゴリ
    var sizeCategory: DogSize {
        switch self {
        case .toyPoodle, .miniatureDachshund, .papillon, .italianGreyhound,
             .miniaturePinscher, .shihTzu, .chihuahua, .westHighlandWhiteTerrier,
             .yorkshireTerrier, .pomeranian, .maltese, .miniatureSchnauzer,
             .pekingese, .japaneseSpitz, .norfolkTerrier, .pug,
             .cavalierKingCharlesSpaniel, .bostonTerrier, .japaneseChin:
            return .small

        case .shibaInu, .kaiKen, .hokkaidoKen, .englishCockerSpaniel,
             .beagle, .americanCockerSpaniel, .borderCollie, .welshCorgiPembroke,
             .shetlandSheepdog, .akitaInu, .siberianHusky, .frenchBulldog,
             .shikokuKen, .germanShepherd, .englishBulldog:
            return .medium

        case .labradorRetriever, .goldenRetriever, .dobermanPinscher,
             .berneseMountainDog, .greatDane:
            return .large

        case .smallMix:
            return .small
        case .largeMix:
            return .large
        case .unknown:
            return .medium  // デフォルト
        }
    }
}

/// 犬のサイズカテゴリ
enum DogSize {
    case small   // 小型犬
    case medium  // 中型犬
    case large   // 大型犬

    var displayName: String {
        switch self {
        case .small: return "小型犬"
        case .medium: return "中型犬"
        case .large: return "大型犬"
        }
    }
}

// MARK: - サイズ別フィルタ

extension DogBreed {
    /// 小型犬の一覧
    static var smallBreeds: [DogBreed] {
        allCases.filter { $0.sizeCategory == .small && $0 != .smallMix && $0 != .unknown }
    }

    /// 中型犬の一覧
    static var mediumBreeds: [DogBreed] {
        allCases.filter { $0.sizeCategory == .medium && $0 != .unknown }
    }

    /// 大型犬の一覧
    static var largeBreeds: [DogBreed] {
        allCases.filter { $0.sizeCategory == .large && $0 != .largeMix }
    }

    /// ミックス・その他の一覧
    static var otherBreeds: [DogBreed] {
        [.smallMix, .largeMix, .unknown]
    }
}
