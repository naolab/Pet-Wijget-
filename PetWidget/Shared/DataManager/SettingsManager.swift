import Foundation

final class SettingsManager {
    static let shared = SettingsManager()

    private let defaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // UserDefaults Keys
    private enum Keys {
        static let widgetSettings = "widgetSettings"
        static let selectedPetID = "selectedPetID"
    }

    private init() {
        self.defaults = UserDefaults(suiteName: AppConfig.appGroupID)
    }

    // ウィジェット設定の保存
    func saveWidgetSettings(_ settings: WidgetSettings) throws {
        let data = try encoder.encode(settings)
        defaults?.set(data, forKey: Keys.widgetSettings)
    }

    // ウィジェット設定の読み込み
    func loadWidgetSettings() throws -> WidgetSettings {
        guard let data = defaults?.data(forKey: Keys.widgetSettings) else {
            return .default
        }
        return try decoder.decode(WidgetSettings.self, from: data)
    }

    // 選択中のペットID
    var selectedPetID: UUID? {
        get {
            guard let uuidString = defaults?.string(forKey: Keys.selectedPetID) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set {
            defaults?.set(newValue?.uuidString, forKey: Keys.selectedPetID)
        }
    }
}
