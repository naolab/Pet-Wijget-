import Foundation
import SwiftUI
import WidgetKit
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var widgetSettings: WidgetSettings
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let settingsManager = SettingsManager.shared
    private let petDataManager = PetDataManager.shared

    init() {
        // 設定を読み込み
        do {
            self.widgetSettings = try settingsManager.loadWidgetSettings()
        } catch {
            print("Failed to load settings: \(error)")
            self.widgetSettings = .default
        }
    }

    // 設定を保存してウィジェットを更新
    func saveSettings() {
        isLoading = true
        errorMessage = nil

        do {
            try settingsManager.saveWidgetSettings(widgetSettings)

            // ウィジェットのタイムラインを更新
            WidgetCenter.shared.reloadAllTimelines()

            #if DEBUG
            print("✅ Settings saved successfully")
            #endif
        } catch {
            errorMessage = "設定の保存に失敗しました: \(error.localizedDescription)"
            #if DEBUG
            print("❌ Failed to save settings: \(error)")
            #endif
        }

        isLoading = false
    }

    // 表示項目の切り替え
    func toggleShowName() {
        widgetSettings.displaySettings.showName.toggle()
        saveSettings()
    }

    func toggleShowAge() {
        widgetSettings.displaySettings.showAge.toggle()
        saveSettings()
    }

    func toggleShowHumanAge() {
        widgetSettings.displaySettings.showHumanAge.toggle()
        saveSettings()
    }

    func toggleShowTime() {
        widgetSettings.displaySettings.showTime.toggle()
        saveSettings()
    }

    func toggleShowDate() {
        widgetSettings.displaySettings.showDate.toggle()
        saveSettings()
    }

    // フォントサイズの更新
    func updateNameFontSize(_ size: CGFloat) {
        widgetSettings.displaySettings.nameFontSize = size
    }

    func updateAgeFontSize(_ size: CGFloat) {
        widgetSettings.displaySettings.ageFontSize = size
    }

    func updateTimeFontSize(_ size: CGFloat) {
        widgetSettings.displaySettings.timeFontSize = size
    }

    func updateDateFontSize(_ size: CGFloat) {
        widgetSettings.displaySettings.dateFontSize = size
    }

    // 日付フォーマットの更新
    func updateDateFormat(_ format: DateFormatType) {
        widgetSettings.displaySettings.dateFormat = format
        saveSettings()
    }

    // 時刻フォーマットの切り替え
    func toggle24HourFormat() {
        widgetSettings.displaySettings.use24HourFormat.toggle()
        saveSettings()
    }

    // テーマ設定の更新
    func updateBackgroundType(_ type: BackgroundType) {
        widgetSettings.themeSettings.backgroundType = type
        saveSettings()
    }

    func updateBackgroundColor(_ color: Color) {
        widgetSettings.themeSettings.backgroundColor = ColorHelper.colorToHex(color)
        saveSettings()
    }

    func updateFontColor(_ color: Color) {
        widgetSettings.themeSettings.fontColor = ColorHelper.colorToHex(color)
        saveSettings()
    }

    func updatePhotoFrameType(_ type: PhotoFrameType) {
        widgetSettings.themeSettings.photoFrameType = type
        saveSettings()
    }

    // 設定をリセット
    func resetToDefaults() {
        widgetSettings = .default
        saveSettings()
    }

    // 利用可能なペット一覧を取得
    func fetchAvailablePets() -> [Pet] {
        do {
            return try petDataManager.fetchAll()
        } catch {
            errorMessage = "ペット情報の取得に失敗しました"
            return []
        }
    }

    // ペット選択
    func selectPet(_ petID: UUID?) {
        widgetSettings.selectedPetID = petID
        saveSettings()
    }

    // プレビュー用: 選択されたペットを取得
    func getSelectedPet() -> Pet? {
        do {
            if let selectedPetID = widgetSettings.selectedPetID {
                // 特定のペットが選択されている場合
                return try petDataManager.fetch(by: selectedPetID)
            } else {
                // 「最初のペット」が選択されている場合
                let allPets = try petDataManager.fetchAll()
                return allPets.first
            }
        } catch {
            errorMessage = "ペット情報の取得に失敗しました"
            return nil
        }
    }
}
