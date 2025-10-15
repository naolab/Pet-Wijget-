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
            if let pet = entry.pet {
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

        return VStack(spacing: 8) {
            // ペット写真 (小さめ)
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType)

            // 現在時刻 (大きく表示)
            if displaySettings.showTime {
                Text(entry.date, style: .time)
                    .font(.system(size: CGFloat(displaySettings.timeFontSize), weight: .bold, design: .rounded))
                    .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
            }

            // ペット名 (コンパクト)
            if displaySettings.showName {
                HStack(spacing: 2) {
                    Image(systemName: speciesIcon(pet.species))
                        .font(.system(size: 8))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                    Text(pet.name)
                        .font(.system(size: CGFloat(displaySettings.nameFontSize * 0.6), weight: .medium))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
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
                let image = Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)

                switch frameType {
                case .circle:
                    image.clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                case .roundedRect:
                    image.clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.5), lineWidth: 2))
                case .none:
                    image
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
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
        case .other: return "hare.fill"
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
