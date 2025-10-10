import Foundation

struct ThemeSettings: Codable {
    var backgroundType: BackgroundType
    var backgroundColor: String // Hex color
    var backgroundImageData: Data?
    var fontColor: String // Hex color
    var photoFrameType: PhotoFrameType

    static var `default`: ThemeSettings {
        ThemeSettings(
            backgroundType: .color,
            backgroundColor: "#FFFFFF",
            backgroundImageData: nil,
            fontColor: "#000000",
            photoFrameType: .circle
        )
    }
}

enum BackgroundType: String, Codable, CaseIterable {
    case color = "color"
    case image = "image"
    case gradient = "gradient"

    var displayName: String {
        switch self {
        case .color: return "単色"
        case .image: return "写真"
        case .gradient: return "グラデーション"
        }
    }
}

enum PhotoFrameType: String, Codable, CaseIterable {
    case circle = "circle"
    case roundedRect = "roundedRect"
    case none = "none"

    var displayName: String {
        switch self {
        case .circle: return "円形"
        case .roundedRect: return "角丸四角"
        case .none: return "なし"
        }
    }
}
