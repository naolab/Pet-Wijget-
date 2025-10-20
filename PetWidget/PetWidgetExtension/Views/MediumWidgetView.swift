import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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

        return HStack(spacing: 16) {
            // 左側: ペット写真
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType)

            // 右側: 時刻・ペット情報
            VStack(alignment: displaySettings.textAlignment.horizontalAlignment, spacing: 8) {
                // 現在時刻
                if displaySettings.showTime {
                    Text(entry.date, style: .time)
                        .font(.system(size: CGFloat(displaySettings.timeFontSize), weight: .bold))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                }

                // 日付
                if displaySettings.showDate {
                    Text(formattedDate(entry.date, format: displaySettings.dateFormat))
                        .font(.system(size: CGFloat(displaySettings.dateFontSize)))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                }

                // 区切り線（時刻・日付が表示されていて、かつshowDividerがtrueの場合のみ表示）
                if displaySettings.showDivider && (displaySettings.showTime || displaySettings.showDate) {
                    Divider()
                        .padding(.vertical, 4)
                }

                // ペット名
                if displaySettings.showName {
                    HStack(spacing: 4) {
                        Image(systemName: speciesIcon(pet.species))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        Text(pet.name)
                            .font(.system(size: CGFloat(displaySettings.nameFontSize), weight: .semibold))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                    }
                }

                // 年齢情報
                VStack(alignment: displaySettings.textAlignment.horizontalAlignment, spacing: 2) {
                    if displaySettings.showAge {
                        Text(ageText(pet))
                            .font(.system(size: CGFloat(displaySettings.ageFontSize)))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                    }

                    if displaySettings.showHumanAge {
                        Text("人間だと \(pet.humanAge)歳")
                            .font(.system(size: CGFloat(displaySettings.ageFontSize * 0.9)))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: displaySettings.textAlignment.alignment)

            Spacer()
        }
        .padding()
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
                    .frame(width: 120, height: 120)

                switch frameType {
                case .circle:
                    image.clipShape(Circle())
                case .roundedRect:
                    image.clipShape(RoundedRectangle(cornerRadius: 16))
                case .none:
                    image
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 50))
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
        VStack(spacing: 12) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            if let errorMessage = entry.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("アプリでペットを\n登録してください")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formattedDate(_ date: Date, format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func ageText(_ pet: Pet) -> String {
        let components = pet.ageComponents
        let years = components.year ?? 0
        let months = components.month ?? 0

        if years == 0 {
            return "\(months)ヶ月"
        } else if months == 0 {
            return "\(years)歳"
        } else {
            return "\(years)歳\(months)ヶ月"
        }
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

#Preview(as: .systemMedium) {
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
