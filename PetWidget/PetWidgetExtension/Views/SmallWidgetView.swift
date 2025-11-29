import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: PetWidgetEntry

    var body: some View {
        Group {
            if let pet = entry.pet {
                petContentView(pet: pet)
            } else {
                emptyStateView
            }
        }
        .containerBackground(for: .widget) {
            if entry.pet != nil {
                backgroundView(themeSettings: entry.settings.themeSettings)
            } else {
                Color.gray.opacity(0.1)
            }
        }
    }

    private func petContentView(pet: Pet) -> some View {
        let settings = entry.settings
        let displaySettings = settings.displaySettings
        let themeSettings = settings.themeSettings

        // ペット写真のみを大きく表示
        return petPhotoView(pet: pet, frameType: themeSettings.photoFrameType)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
    }

    private func backgroundView(themeSettings: ThemeSettings) -> some View {
        Group {
            switch themeSettings.backgroundType {
            case .color:
                ColorHelper.hexColor(themeSettings.backgroundColor)
            case .gradient:
                LinearGradient(
                    gradient: Gradient(colors: [
                        ColorHelper.hexColor(themeSettings.backgroundColor).opacity(0.3),
                        ColorHelper.hexColor(themeSettings.backgroundColor).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .image:
                ColorHelper.hexColor(themeSettings.backgroundColor)
            }
        }
    }

    private func petPhotoView(pet: Pet, frameType: PhotoFrameType) -> some View {
        Group {
            if let image = resolveWidgetImage(for: pet) {
                // ウィジェット全体を覆うように画像を大きく表示
                let viewImage = Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

                switch frameType {
                case .circle:
                    viewImage.clipShape(Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .roundedRect:
                    viewImage.clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .none:
                    viewImage
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // プレースホルダー
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))

                    VStack(spacing: 4) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        Text("アプリを開いて\n更新")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func resolveWidgetImage(for pet: Pet) -> UIImage? {
        // 1. 軽量化されたウィジェット用データがあればそれを使用
        if let widgetData = pet.widgetPhotoData, let image = UIImage(data: widgetData) {
            return image
        }
        
        // 2. フォールバック削除: ウィジェットでの重い画像処理はクラッシュの原因になるため行わない
        // 代わりにnilを返し、プレースホルダーを表示させる（アプリを開いて移行を促す）
        return nil
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 32))
                .foregroundColor(.gray)

            Text(entry.date, style: .time)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            if let errorMessage = entry.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            } else {
                Text("ペットを\n登録")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(8)
    }

    private func speciesIcon(_ species: PetType) -> String {
        switch species {
        case .dog: return "pawprint.fill"
        case .cat: return "cat.fill"
        case .fish: return "fish.fill"
        case .smallAnimal: return "hare.fill"
        case .turtle: return "tortoise.fill"
        case .bird: return "bird.fill"
        case .insect: return "ladybug.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

#Preview(as: .systemSmall) {
    PetWidgetExtension()
} timeline: {
    let samplePet = Pet(
        name: "ポチ",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        species: .dog,
        photoData: nil
    )

    PetWidgetEntry(date: .now, pet: samplePet, errorMessage: nil, settings: .default)
    PetWidgetEntry(date: .now, pet: nil, errorMessage: "ペットが登録されていません", settings: .default)
}
