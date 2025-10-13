import WidgetKit
import SwiftUI

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
    private let dataManager = PetDataManager.shared
    private let settingsManager = SettingsManager.shared

    func placeholder(in context: Context) -> PetWidgetEntry {
        PetWidgetEntry(
            date: Date(),
            pet: createSamplePet(),
            errorMessage: nil,
            settings: .default
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> Void) {
        let entry: PetWidgetEntry

        if context.isPreview {
            entry = PetWidgetEntry(
                date: Date(),
                pet: createSamplePet(),
                errorMessage: nil,
                settings: .default
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

    private func createSamplePet() -> Pet {
        Pet(
            name: "ポチ",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            species: .dog,
            photoData: nil
        )
    }
}
