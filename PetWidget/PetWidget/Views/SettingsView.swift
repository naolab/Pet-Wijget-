import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            // ペット選択セクション
            petSelectionSection

            // 表示項目セクション
            displayItemsSection

            // フォントサイズセクション
            fontSizeSection

            // 日付・時刻フォーマットセクション
            dateTimeFormatSection

            // テーマ設定セクション
            themeSection

            // リセットセクション
            resetSection
        }
        .navigationTitle("ウィジェット設定")
        .navigationBarTitleDisplayMode(.inline)
        .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Pet Selection Section
    private var petSelectionSection: some View {
        Section {
            let pets = viewModel.fetchAvailablePets()

            if pets.isEmpty {
                Text("ペットが登録されていません")
                    .foregroundColor(.secondary)
            } else {
                Picker("表示するペット", selection: $viewModel.widgetSettings.selectedPetID) {
                    Text("最初のペット").tag(nil as UUID?)
                    ForEach(pets) { pet in
                        HStack {
                            Image(systemName: pet.species == .dog ? "pawprint.fill" : pet.species == .cat ? "cat.fill" : "hare.fill")
                            Text(pet.name)
                        }
                        .tag(pet.id as UUID?)
                    }
                }
                .onChange(of: viewModel.widgetSettings.selectedPetID) { _, newValue in
                    viewModel.selectPet(newValue)
                }
            }
        } header: {
            Text("ペット選択")
        }
    }

    // MARK: - Display Items Section
    private var displayItemsSection: some View {
        Section {
            Toggle("ペット名を表示", isOn: $viewModel.widgetSettings.displaySettings.showName)
                .onChange(of: viewModel.widgetSettings.displaySettings.showName) { _, _ in
                    viewModel.saveSettings()
                }

            Toggle("年齢を表示", isOn: $viewModel.widgetSettings.displaySettings.showAge)
                .onChange(of: viewModel.widgetSettings.displaySettings.showAge) { _, _ in
                    viewModel.saveSettings()
                }

            Toggle("人間換算年齢を表示", isOn: $viewModel.widgetSettings.displaySettings.showHumanAge)
                .onChange(of: viewModel.widgetSettings.displaySettings.showHumanAge) { _, _ in
                    viewModel.saveSettings()
                }

            Toggle("時刻を表示", isOn: $viewModel.widgetSettings.displaySettings.showTime)
                .onChange(of: viewModel.widgetSettings.displaySettings.showTime) { _, _ in
                    viewModel.saveSettings()
                }

            Toggle("日付を表示", isOn: $viewModel.widgetSettings.displaySettings.showDate)
                .onChange(of: viewModel.widgetSettings.displaySettings.showDate) { _, _ in
                    viewModel.saveSettings()
                }
        } header: {
            Text("表示項目")
        }
    }

    // MARK: - Font Size Section
    private var fontSizeSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("名前: \(Int(viewModel.widgetSettings.displaySettings.nameFontSize))pt")
                    .font(.caption)
                Slider(value: $viewModel.widgetSettings.displaySettings.nameFontSize, in: 10...24, step: 1)
                    .onChange(of: viewModel.widgetSettings.displaySettings.nameFontSize) { _, _ in
                        viewModel.saveSettings()
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("年齢: \(Int(viewModel.widgetSettings.displaySettings.ageFontSize))pt")
                    .font(.caption)
                Slider(value: $viewModel.widgetSettings.displaySettings.ageFontSize, in: 10...20, step: 1)
                    .onChange(of: viewModel.widgetSettings.displaySettings.ageFontSize) { _, _ in
                        viewModel.saveSettings()
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("時刻: \(Int(viewModel.widgetSettings.displaySettings.timeFontSize))pt")
                    .font(.caption)
                Slider(value: $viewModel.widgetSettings.displaySettings.timeFontSize, in: 20...48, step: 2)
                    .onChange(of: viewModel.widgetSettings.displaySettings.timeFontSize) { _, _ in
                        viewModel.saveSettings()
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("日付: \(Int(viewModel.widgetSettings.displaySettings.dateFontSize))pt")
                    .font(.caption)
                Slider(value: $viewModel.widgetSettings.displaySettings.dateFontSize, in: 10...16, step: 1)
                    .onChange(of: viewModel.widgetSettings.displaySettings.dateFontSize) { _, _ in
                        viewModel.saveSettings()
                    }
            }
        } header: {
            Text("フォントサイズ")
        }
    }

    // MARK: - Date Time Format Section
    private var dateTimeFormatSection: some View {
        Section {
            Picker("日付フォーマット", selection: $viewModel.widgetSettings.displaySettings.dateFormat) {
                ForEach(DateFormatType.allCases, id: \.self) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .onChange(of: viewModel.widgetSettings.displaySettings.dateFormat) { _, newValue in
                viewModel.updateDateFormat(newValue)
            }

            Toggle("24時間表示", isOn: $viewModel.widgetSettings.displaySettings.use24HourFormat)
                .onChange(of: viewModel.widgetSettings.displaySettings.use24HourFormat) { _, _ in
                    viewModel.toggle24HourFormat()
                }
        } header: {
            Text("日付・時刻フォーマット")
        }
    }

    // MARK: - Theme Section
    private var themeSection: some View {
        Section {
            Picker("背景タイプ", selection: $viewModel.widgetSettings.themeSettings.backgroundType) {
                ForEach(BackgroundType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .onChange(of: viewModel.widgetSettings.themeSettings.backgroundType) { _, newValue in
                viewModel.updateBackgroundType(newValue)
            }

            ColorPicker("背景色",
                       selection: Binding(
                           get: { ColorHelper.hexColor(viewModel.widgetSettings.themeSettings.backgroundColor) },
                           set: { viewModel.updateBackgroundColor($0) }
                       ))

            ColorPicker("文字色",
                       selection: Binding(
                           get: { ColorHelper.hexColor(viewModel.widgetSettings.themeSettings.fontColor) },
                           set: { viewModel.updateFontColor($0) }
                       ))

            Picker("写真フレーム", selection: $viewModel.widgetSettings.themeSettings.photoFrameType) {
                ForEach(PhotoFrameType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .onChange(of: viewModel.widgetSettings.themeSettings.photoFrameType) { _, newValue in
                viewModel.updatePhotoFrameType(newValue)
            }
        } header: {
            Text("テーマ設定")
        } footer: {
            Text("ウィジェットの外観をカスタマイズできます")
        }
    }

    // MARK: - Reset Section
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.resetToDefaults()
            } label: {
                HStack {
                    Spacer()
                    Text("設定をリセット")
                    Spacer()
                }
            }
        } footer: {
            Text("すべての設定をデフォルトに戻します")
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
