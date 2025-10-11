import Foundation

enum AppConfig {
    static let appGroupID = "group.com.nao.petwidget"
    static let widgetKind = "PetWidget"

    // 画像設定
    static let maxImageSize: CGFloat = 800
    static let widgetImageSize: CGFloat = 300
    static let imageCompressionQuality: CGFloat = 0.8

    // ウィジェット設定
    static let timelineUpdateInterval: TimeInterval = 3600 // 1時間
}
