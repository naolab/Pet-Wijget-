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

        return ZStack {
            // メインのペット写真を大きく中央に配置
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType)

            // 下部に時刻とペット名を重ねて表示（表示設定による）
            VStack {
                Spacer()

                VStack(spacing: 4) {
                    // 現在時刻
                    if displaySettings.showTime {
                        Text(entry.date, style: .time)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }

                    // ペット名
                    if displaySettings.showName {
                        Text(pet.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .lineLimit(1)
                    }
                }
                .padding(.bottom, 8)
            }
        }
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

    private func petPhotoView(photoData: Data?, frameType: PhotoFrameType) -> some View {
        Group {
            if let photoData = photoData,
               let processedImage = processPhotoForWidget(photoData) {
                // ウィジェット全体を覆うように画像を大きく表示
                let image = Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

                switch frameType {
                case .circle:
                    image.clipShape(Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .roundedRect:
                    image.clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .none:
                    image
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // プレースホルダー
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func processPhotoForWidget(_ photoData: Data) -> UIImage? {
        guard let uiImage = UIImage(data: photoData),
              let resizedData = PhotoManager.shared.processImageForWidget(uiImage),
              let resizedImage = UIImage(data: resizedData) else {
            return nil
        }
        return resizedImage
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
