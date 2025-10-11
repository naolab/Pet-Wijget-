import WidgetKit
import SwiftUI

struct PetWidgetEntry: TimelineEntry {
    let date: Date
    let pet: Pet?
    let errorMessage: String?

    var isValid: Bool {
        pet != nil && errorMessage == nil
    }
}

struct PetWidgetTimelineProvider: TimelineProvider {
    private let dataManager = PetDataManager.shared

    func placeholder(in context: Context) -> PetWidgetEntry {
        PetWidgetEntry(
            date: Date(),
            pet: createSamplePet(),
            errorMessage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> Void) {
        let entry: PetWidgetEntry

        if context.isPreview {
            entry = PetWidgetEntry(
                date: Date(),
                pet: createSamplePet(),
                errorMessage: nil
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
        do {
            #if DEBUG
            print("🔄 Widget: Attempting to fetch pets...")
            #endif
            let pets = try dataManager.fetchAll()
            #if DEBUG
            print("✅ Widget: Fetched \(pets.count) pets")
            #endif

            if let firstPet = pets.first {
                #if DEBUG
                print("✅ Widget: Displaying pet: \(firstPet.name)")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: firstPet,
                    errorMessage: nil
                )
            } else {
                #if DEBUG
                print("⚠️ Widget: No pets found")
                #endif
                return PetWidgetEntry(
                    date: date,
                    pet: nil,
                    errorMessage: "ペットが登録されていません"
                )
            }
        } catch {
            #if DEBUG
            print("❌ Widget: Failed to fetch pets: \(error)")
            #endif
            return PetWidgetEntry(
                date: date,
                pet: nil,
                errorMessage: "データの読み込みに失敗しました: \(error.localizedDescription)"
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
