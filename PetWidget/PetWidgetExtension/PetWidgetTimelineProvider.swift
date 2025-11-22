import WidgetKit
import SwiftUI
import AppIntents

struct PetWidgetEntry: TimelineEntry {
    let date: Date
    let pet: Pet?
    let errorMessage: String?
    let settings: WidgetSettings

    var isValid: Bool {
        pet != nil && errorMessage == nil
    }
}

struct PetWidgetTimelineProvider: TimelineProvider {
    private var dataManager: PetDataManager { PetDataManager.shared }
    private var settingsManager: SettingsManager { SettingsManager.shared }

    func placeholder(in context: Context) -> PetWidgetEntry {
        let settings = loadSettings()
        return PetWidgetEntry(
            date: Date(),
            pet: createSamplePet(),
            errorMessage: nil,
            settings: settings
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> Void) {
        let entry: PetWidgetEntry

        if context.isPreview {
            let settings = loadSettings()
            entry = PetWidgetEntry(
                date: Date(),
                pet: createSamplePet(),
                errorMessage: nil,
                settings: settings
            )
        } else {
            entry = createEntry(for: Date())
        }

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetWidgetEntry>) -> Void) {
        var entries: [PetWidgetEntry] = []

        // 現在時刻から1時間先まで、1分ごとにエントリを生成
        let currentDate = Date()
        let calendar = Calendar.current

        for minuteOffset in 0..<60 {
            if let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: currentDate) {
                let entry = createEntry(for: entryDate)
                entries.append(entry)
            }
        }

        // 1時間後に次のタイムラインを要求
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))

        completion(timeline)
    }

    private func createEntry(for date: Date) -> PetWidgetEntry {
        // 設定を読み込み
        let settings: WidgetSettings
        do {
            settings = try settingsManager.loadWidgetSettings()
        } catch {
            #if DEBUG
            print("⚠️ Widget: Failed to load settings, using defaults: \(error)")
            #endif
            settings = .default
        }

        do {
            #if DEBUG
            print("🔄 Widget: Attempting to fetch pets...")
            #endif
            let pets = try dataManager.fetchAll()
            #if DEBUG
            print("✅ Widget: Fetched \(pets.count) pets")
            #endif

            // 設定で指定されたペットを取得、なければ最初のペット
            var selectedPet: Pet?
            if let selectedID = settings.selectedPetID {
                selectedPet = pets.first(where: { $0.id == selectedID })
            }
            if selectedPet == nil {
                selectedPet = pets.first
            }

            if let pet = selectedPet {
                #if DEBUG
                print("✅ Widget: Displaying pet: \(pet.name)")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: pet,
                    errorMessage: nil,
                    settings: settings
                )
            } else {
                #if DEBUG
                print("⚠️ Widget: No pets found")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: nil,
                    errorMessage: "ペットが登録されていません",
                    settings: settings
                )
            }
        } catch {
            #if DEBUG
            print("❌ Widget: Failed to fetch pets: \(error)")
            #endif
            return PetWidgetEntry(
                date: date,
                pet: nil,
                errorMessage: "データの読み込みに失敗しました: \(error.localizedDescription)",
                settings: settings
            )
        }
    }

    private func loadSettings() -> WidgetSettings {
        do {
            return try settingsManager.loadWidgetSettings()
        } catch {
            #if DEBUG
            print("⚠️ Widget: Failed to load settings, using defaults: \(error)")
            #endif
            return .default
        }
    }

    private func createSamplePet() -> Pet {
        Pet(
            name: "ポチ",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            species: .dog,
            photoData: nil
        )
    }
}

// MARK: - AppIntent TimelineProvider (iOS 16+)

@available(iOS 16.0, *)
struct PetWidgetIntentTimelineProvider: AppIntentTimelineProvider {
    private var dataManager: PetDataManager { PetDataManager.shared }
    private var settingsManager: SettingsManager { SettingsManager.shared }

    func placeholder(in context: Context) -> PetWidgetEntry {
        let settings = loadSettings()
        return PetWidgetEntry(
            date: Date(),
            pet: createSamplePet(),
            errorMessage: nil,
            settings: settings
        )
    }

    func snapshot(for configuration: SelectPetIntent, in context: Context) async -> PetWidgetEntry {
        #if DEBUG
        print("✅ [AppIntent] Widget: Creating a dummy snapshot.")
        #endif
        let dummyPet = createSamplePet()
        let settings = loadSettings()
        return PetWidgetEntry(date: Date(), pet: dummyPet, errorMessage: nil, settings: settings)
    }

    func timeline(for configuration: SelectPetIntent, in context: Context) async -> Timeline<PetWidgetEntry> {
        if let userDefaults = UserDefaults(suiteName: AppConfig.appGroupID) {
            let message = userDefaults.string(forKey: "group.test.message") ?? "NOT FOUND"
            print("✅ Widget: Read from shared UserDefaults: \(message)")
        } else {
            print("❌ Widget: Failed to get shared UserDefaults.")
        }

        var entries: [PetWidgetEntry] = []

        // 現在時刻から1時間先まで、1分ごとにエントリを生成
        let currentDate = Date()
        let calendar = Calendar.current

        for minuteOffset in 0..<60 {
            if let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: currentDate) {
                let entry = await createEntry(for: entryDate, with: configuration)
                entries.append(entry)
            }
        }

        // 1時間後に次のタイムラインを要求
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    private func createEntry(for date: Date, with configuration: SelectPetIntent) async -> PetWidgetEntry {
        #if DEBUG
        print("═══════════════════════════════════════════════════")
        print("🎯 [Timeline] createEntry called at \(date)")
        print("   Configuration.selectedPet: \(configuration.selectedPet?.name ?? "nil")")
        if let selectedPet = configuration.selectedPet {
            print("   Configuration.selectedPet.id: \(selectedPet.id)")
        }
        print("═══════════════════════════════════════════════════")
        #endif

        // 設定を読み込み
        let settings: WidgetSettings
        do {
            settings = try settingsManager.loadWidgetSettings()
        } catch {
            #if DEBUG
            print("⚠️ Widget: Failed to load settings, using defaults: \(error)")
            #endif
            settings = .default
        }

        do {
            #if DEBUG
            print("🔄 Widget: Attempting to fetch pets...")
            #endif
            let pets = try dataManager.fetchAll()
            #if DEBUG
            print("✅ Widget: Fetched \(pets.count) pets")
            for (index, pet) in pets.enumerated() {
                print("   Pet \(index + 1): \(pet.name) (ID: \(pet.id))")
            }
            #endif

            // Intentで選択されたペットを取得
            var selectedPet: Pet?
            if let selectedWidgetPet = configuration.selectedPet {
                #if DEBUG
                print("🔍 Widget: Looking for Intent selected pet: \(selectedWidgetPet.name) (ID: \(selectedWidgetPet.id))")
                #endif
                selectedPet = pets.first(where: { $0.id == selectedWidgetPet.id })
                #if DEBUG
                if selectedPet != nil {
                    print("✅ Widget: Intent selected pet FOUND: \(selectedWidgetPet.name)")
                } else {
                    print("❌ Widget: Intent selected pet NOT FOUND: \(selectedWidgetPet.name) (ID: \(selectedWidgetPet.id))")
                    print("   Available pet IDs: \(pets.map { $0.id })")
                }
                #endif
            } else {
                #if DEBUG
                print("⚠️ Widget: configuration.selectedPet is NIL")
                #endif
            }

            // 選択されたペットがない場合は、設定で指定されたペットまたは最初のペット
            if selectedPet == nil {
                #if DEBUG
                print("🔄 Widget: Falling back to settings or first pet")
                #endif

                if let selectedID = settings.selectedPetID {
                    selectedPet = pets.first(where: { $0.id == selectedID })
                    #if DEBUG
                    if selectedPet != nil {
                        print("✅ Widget: Found pet from settings: \(selectedPet!.name)")
                    } else {
                        print("⚠️ Widget: Pet from settings NOT found (ID: \(selectedID))")
                    }
                    #endif
                }
                if selectedPet == nil {
                    selectedPet = pets.first
                    #if DEBUG
                    if let pet = selectedPet {
                        print("✅ Widget: Using first available pet: \(pet.name)")
                    }
                    #endif
                }
            }

            if let pet = selectedPet {
                #if DEBUG
                print("✅ Widget: Displaying pet: \(pet.name)")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: pet,
                    errorMessage: nil,
                    settings: settings
                )
            } else {
                #if DEBUG
                print("⚠️ Widget: No pets found")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: nil,
                    errorMessage: "ペットが登録されていません",
                    settings: settings
                )
            }
        } catch {
            #if DEBUG
            print("❌ Widget: Failed to fetch pets: \(error)")
            #endif
            return PetWidgetEntry(
                date: date,
                pet: nil,
                errorMessage: "データの読み込みに失敗しました: \(error.localizedDescription)",
                settings: settings
            )
        }
    }

    private func loadSettings() -> WidgetSettings {
        do {
            return try settingsManager.loadWidgetSettings()
        } catch {
            #if DEBUG
            print("⚠️ Widget: Failed to load settings, using defaults: \(error)")
            #endif
            return .default
        }
    }

    private func createSamplePet() -> Pet {
        Pet(
            name: "ポチ",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            species: .dog,
            photoData: nil
        )
    }
}
