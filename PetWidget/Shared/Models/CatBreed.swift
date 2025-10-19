import Foundation

/// 猫の品種
/// 各品種の平均寿命データに基づいて人間換算年齢を計算
enum CatBreed: String, Codable, CaseIterable {
    // ミックス
    case japaneseDomestic = "japaneseDomestic"
    case mixed = "mixed"

    // 純血種（寿命が長い順）
    case siberian = "siberian"
    case japaneseBobTail = "japaneseBobTail"
    case ragdoll = "ragdoll"
    case americanCurl = "americanCurl"
    case persian = "persian"
    case scottishFold = "scottishFold"
    case americanShorthair = "americanShorthair"
    case norwegianForest = "norwegianForest"
    case abyssinian = "abyssinian"
    case russianBlue = "russianBlue"
    case britishShorthair = "britishShorthair"
    case birman = "birman"
    case maineCoon = "maineCoon"
    case somali = "somali"
    case exoticShorthair = "exoticShorthair"
    case toyger = "toyger"
    case singapura = "singapura"
    case orientalShorthair = "orientalShorthair"
    case chartreux = "chartreux"
    case munchkin = "munchkin"
    case selkirkRex = "selkirkRex"
    case tonkinese = "tonkinese"
    case cornishRex = "cornishRex"
    case devonRex = "devonRex"
    case ragamuffin = "ragamuffin"
    case ocicat = "ocicat"
    case burmese = "burmese"
    case siamese = "siamese"
    case bengal = "bengal"
    case americanWirehair = "americanWirehair"
    case minuet = "minuet"
    case sphynx = "sphynx"

    // 不明
    case unknown = "unknown"

    /// 表示名（日本語）
    var displayName: String {
        switch self {
        // ミックス
        case .japaneseDomestic: return "日本猫"
        case .mixed: return "ミックス"

        // 純血種
        case .siberian: return "シベリアン"
        case .japaneseBobTail: return "ジャパニーズボブテイル"
        case .ragdoll: return "ラグドール"
        case .americanCurl: return "アメリカンカール"
        case .persian: return "ペルシャ"
        case .scottishFold: return "スコティッシュフォールド"
        case .americanShorthair: return "アメリカンショートヘア"
        case .norwegianForest: return "ノルウェージャンフォレストキャット"
        case .abyssinian: return "アビシニアン"
        case .russianBlue: return "ロシアンブルー"
        case .britishShorthair: return "ブリティッシュショートヘア"
        case .birman: return "バーマン"
        case .maineCoon: return "メインクーン"
        case .somali: return "ソマリ"
        case .exoticShorthair: return "エキゾチックショートヘア"
        case .toyger: return "トイガー"
        case .singapura: return "シンガプーラ"
        case .orientalShorthair: return "オリエンタルショートヘア"
        case .chartreux: return "シャルトリュー"
        case .munchkin: return "マンチカン"
        case .selkirkRex: return "セルカークレックス"
        case .tonkinese: return "トンキニーズ"
        case .cornishRex: return "コーニッシュレックス"
        case .devonRex: return "デボンレックス"
        case .ragamuffin: return "ラガマフィン"
        case .ocicat: return "オシキャット"
        case .burmese: return "バーミーズ"
        case .siamese: return "シャム"
        case .bengal: return "ベンガル"
        case .americanWirehair: return "アメリカンワイヤーヘア"
        case .minuet: return "ミヌエット"
        case .sphynx: return "スフィンクス"

        // 不明
        case .unknown: return "不明"
        }
    }

    /// 平均寿命（年）
    var averageLifespan: Double {
        switch self {
        // ミックス
        case .japaneseDomestic: return 15.2
        case .mixed: return 14.9

        // 純血種
        case .siberian: return 15.7
        case .japaneseBobTail: return 15.3
        case .ragdoll: return 14.9
        case .americanCurl: return 14.8
        case .persian: return 14.3
        case .scottishFold: return 14.0
        case .americanShorthair: return 14.0
        case .norwegianForest: return 14.0
        case .abyssinian: return 13.9
        case .russianBlue: return 13.8
        case .britishShorthair: return 13.4
        case .birman: return 13.3
        case .maineCoon: return 12.9
        case .somali: return 12.6
        case .exoticShorthair: return 12.2
        case .toyger: return 12.2
        case .singapura: return 11.6
        case .orientalShorthair: return 11.6
        case .chartreux: return 11.3
        case .munchkin: return 11.2
        case .selkirkRex: return 11.2
        case .tonkinese: return 10.5
        case .cornishRex: return 10.5
        case .devonRex: return 10.5
        case .ragamuffin: return 10.3
        case .ocicat: return 10.1
        case .burmese: return 10.1
        case .siamese: return 9.6
        case .bengal: return 9.2
        case .americanWirehair: return 9.1
        case .minuet: return 8.3
        case .sphynx: return 7.0

        // 不明（デフォルト値として猫の平均寿命を使用）
        case .unknown: return 15.0
        }
    }

    /// 人気度カテゴリ
    enum PopularityCategory {
        case veryPopular    // 非常に人気
        case popular        // 人気
        case moderate       // 中程度
        case rare           // レア
    }

    /// 人気度
    var popularityCategory: PopularityCategory {
        switch self {
        case .japaneseDomestic, .mixed:
            return .veryPopular
        case .scottishFold, .americanShorthair, .ragdoll, .maineCoon, .norwegianForest, .munchkin, .britishShorthair, .persian:
            return .veryPopular
        case .russianBlue, .bengal, .abyssinian, .siamese, .exoticShorthair, .birman, .somali:
            return .popular
        case .americanCurl, .tonkinese, .singapura, .orientalShorthair, .chartreux, .sphynx, .selkirkRex:
            return .moderate
        case .siberian, .japaneseBobTail, .toyger, .cornishRex, .devonRex, .ragamuffin, .ocicat, .burmese, .americanWirehair, .minuet:
            return .rare
        case .unknown:
            return .moderate
        }
    }

    // MARK: - カテゴリ別品種リスト

    /// ミックス・日本猫
    static var mixedBreeds: [CatBreed] {
        [.japaneseDomestic, .mixed]
    }

    /// 非常に人気のある純血種
    static var veryPopularBreeds: [CatBreed] {
        allCases.filter { $0.popularityCategory == .veryPopular && !mixedBreeds.contains($0) }
            .sorted { $0.displayName < $1.displayName }
    }

    /// 人気のある純血種
    static var popularBreeds: [CatBreed] {
        allCases.filter { $0.popularityCategory == .popular }
            .sorted { $0.displayName < $1.displayName }
    }

    /// その他の品種
    static var otherBreeds: [CatBreed] {
        allCases.filter {
            ($0.popularityCategory == .moderate || $0.popularityCategory == .rare) && $0 != .unknown
        }.sorted { $0.displayName < $1.displayName }
    }
}
