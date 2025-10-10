import Foundation

struct WidgetSettings: Codable {
    var selectedPetID: UUID?
    var displaySettings: DisplaySettings
    var themeSettings: ThemeSettings

    static var `default`: WidgetSettings {
        WidgetSettings(
            selectedPetID: nil,
            displaySettings: .default,
            themeSettings: .default
        )
    }
}
