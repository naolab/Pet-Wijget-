import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
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

        return VStack(spacing: 0) {
            // 上部: 時刻・日付セクション
            timeSection(displaySettings: displaySettings, themeSettings: themeSettings)

            // 区切り線（時刻・日付が表示されていて、かつshowDividerがtrueの場合のみ表示）
            if displaySettings.showDivider && (displaySettings.showTime || displaySettings.showDate) {
                Divider()
                    .padding(.vertical, 12)
            }

            // 下部: ペット情報セクション
            petInfoSection(pet: pet, displaySettings: displaySettings, themeSettings: themeSettings)

            Spacer()
        }
        .padding(16)
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

    // MARK: - 時刻セクション
    private func timeSection(displaySettings: DisplaySettings, themeSettings: ThemeSettings) -> some View {
        VStack(spacing: 4) {
            // 現在時刻
            if displaySettings.showTime {
                Text(entry.date, style: .time)
                    .font(.system(size: CGFloat(displaySettings.timeFontSize * 1.5), weight: .bold, design: displaySettings.timeDateFontDesign.design))
                    .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
            }

            // 日付
            if displaySettings.showDate {
                Text(formattedDate(entry.date, format: displaySettings.dateFormat))
                    .font(.system(size: CGFloat(displaySettings.dateFontSize + 4), design: displaySettings.timeDateFontDesign.design))
                    .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))

                // 曜日
                Text(formattedWeekday(entry.date))
                    .font(.system(size: CGFloat(displaySettings.dateFontSize + 2), design: displaySettings.timeDateFontDesign.design))
                    .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: displaySettings.textAlignment.alignment)
    }

    // MARK: - ペット情報セクション
    private func petInfoSection(pet: Pet, displaySettings: DisplaySettings, themeSettings: ThemeSettings) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // 左側: ペット写真
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType)

            // 右側: 詳細情報
            VStack(alignment: displaySettings.textAlignment.horizontalAlignment, spacing: 12) {
                // ペット名
                if displaySettings.showName {
                    HStack(spacing: 6) {
                        Image(systemName: speciesIcon(pet.species))
                            .font(.system(size: 18))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.8))
                        Text(pet.name)
                            .font(.system(size: CGFloat(displaySettings.nameFontSize * 1.5), weight: .bold, design: displaySettings.textFontDesign.design))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                    }
                }

                // 誕生日
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.6))
                    Text("誕生日: \(formattedBirthDate(pet.birthDate))")
                        .font(.system(size: CGFloat(displaySettings.ageFontSize), design: displaySettings.textFontDesign.design))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                }

                // 年齢情報
                VStack(alignment: displaySettings.textAlignment.horizontalAlignment, spacing: 6) {
                    if displaySettings.showAge {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 12))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.6))
                            Text(ageText(pet))
                                .font(.system(size: CGFloat(displaySettings.ageFontSize + 2), weight: .semibold, design: displaySettings.textFontDesign.design))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                        }
                    }

                    if displaySettings.showHumanAge {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 12))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.6))
                            Text("人間だと \(pet.humanAge)歳")
                                .font(.system(size: CGFloat(displaySettings.ageFontSize), design: displaySettings.textFontDesign.design))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: displaySettings.textAlignment.alignment)

            Spacer()
        }
    }

    private func petPhotoView(photoData: Data?, frameType: PhotoFrameType) -> some View {
        Group {
            if let photoData = photoData,
               let processedImage = processPhotoForWidget(photoData) {
                let image = Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)

                switch frameType {
                case .circle:
                    image.clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                case .roundedRect:
                    image.clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                case .none:
                    image.shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 140, height: 140)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
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
        VStack(spacing: 20) {
            // 時刻表示
            VStack(spacing: 4) {
                Text(entry.date, style: .time)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(formattedDate(entry.date, format: entry.settings.displaySettings.dateFormat))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }

            Divider()
                .padding(.vertical, 8)

            // Empty State
            VStack(spacing: 12) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)

                if let errorMessage = entry.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("アプリでペットを登録してください")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Helper Functions

    private func formattedDate(_ date: Date, format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func formattedWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func formattedBirthDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func ageText(_ pet: Pet) -> String {
        return AgeCalculator.ageString(from: pet.birthDate, detailLevel: entry.settings.displaySettings.ageDisplayDetail)
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

#Preview(as: .systemLarge) {
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
