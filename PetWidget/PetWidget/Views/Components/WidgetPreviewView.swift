import SwiftUI

/// ウィジェットプレビューコンポーネント
/// 設定画面でウィジェットの外観をリアルタイムでプレビュー表示する
struct WidgetPreviewView: View {
    let pet: Pet?
    let settings: WidgetSettings
    let widgetSize: WidgetSize

    enum WidgetSize {
        case small
        case medium
        case large

        var displayName: String {
            switch self {
            case .small: return "小"
            case .medium: return "中"
            case .large: return "大"
            }
        }

        var size: CGSize {
            switch self {
            case .small: return CGSize(width: 158, height: 158)
            case .medium: return CGSize(width: 338, height: 158)
            case .large: return CGSize(width: 338, height: 354)
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(widgetSize.displayName)
                .font(.caption)
                .foregroundColor(.secondary)

            if let pet = pet {
                petContentView(pet: pet)
                    .frame(width: widgetSize.size.width, height: widgetSize.size.height)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                emptyStateView
                    .frame(width: widgetSize.size.width, height: widgetSize.size.height)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
    }

    @ViewBuilder
    private func petContentView(pet: Pet) -> some View {
        let displaySettings = settings.displaySettings
        let themeSettings = settings.themeSettings

        ZStack {
            // 背景
            backgroundView(themeSettings: themeSettings)

            switch widgetSize {
            case .small:
                smallWidgetContent(pet: pet, displaySettings: displaySettings, themeSettings: themeSettings)
            case .medium:
                mediumWidgetContent(pet: pet, displaySettings: displaySettings, themeSettings: themeSettings)
            case .large:
                largeWidgetContent(pet: pet, displaySettings: displaySettings, themeSettings: themeSettings)
            }
        }
    }

    // MARK: - Small Widget
    private func smallWidgetContent(pet: Pet, displaySettings: DisplaySettings, themeSettings: ThemeSettings) -> some View {
        VStack(spacing: 8) {
            // ペット写真 (小さめ)
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType, size: 50)

            // 現在時刻 (大きく表示)
            if displaySettings.showTime {
                Text(Date(), style: .time)
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

    // MARK: - Medium Widget
    private func mediumWidgetContent(pet: Pet, displaySettings: DisplaySettings, themeSettings: ThemeSettings) -> some View {
        HStack(spacing: 16) {
            // 左側: ペット写真
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType, size: 120)

            // 右側: 時刻・ペット情報
            VStack(alignment: .leading, spacing: 8) {
                // 現在時刻
                if displaySettings.showTime {
                    Text(Date(), style: .time)
                        .font(.system(size: CGFloat(displaySettings.timeFontSize), weight: .bold))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                }

                // 日付
                if displaySettings.showDate {
                    Text(formattedDate(Date(), format: displaySettings.dateFormat))
                        .font(.system(size: CGFloat(displaySettings.dateFontSize)))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                }

                Divider()
                    .padding(.vertical, 4)

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
                VStack(alignment: .leading, spacing: 2) {
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

            Spacer()
        }
        .padding()
    }

    // MARK: - Large Widget
    private func largeWidgetContent(pet: Pet, displaySettings: DisplaySettings, themeSettings: ThemeSettings) -> some View {
        VStack(spacing: 16) {
            // 上部: 時刻・日付
            VStack(spacing: 4) {
                if displaySettings.showTime {
                    Text(Date(), style: .time)
                        .font(.system(size: CGFloat(displaySettings.timeFontSize * 1.2), weight: .bold, design: .rounded))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                }

                if displaySettings.showDate {
                    Text(formattedDate(Date(), format: displaySettings.dateFormat))
                        .font(.system(size: CGFloat(displaySettings.dateFontSize)))
                        .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                }
            }

            Divider()

            // 中央: ペット写真
            petPhotoView(photoData: pet.photoData, frameType: themeSettings.photoFrameType, size: 140)

            // 下部: ペット情報
            VStack(spacing: 8) {
                if displaySettings.showName {
                    HStack(spacing: 6) {
                        Image(systemName: speciesIcon(pet.species))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        Text(pet.name)
                            .font(.system(size: CGFloat(displaySettings.nameFontSize * 1.2), weight: .bold))
                            .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor))
                    }
                }

                HStack(spacing: 16) {
                    if displaySettings.showAge {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("年齢")
                                .font(.caption2)
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.5))
                            Text(ageText(pet))
                                .font(.system(size: CGFloat(displaySettings.ageFontSize)))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        }
                    }

                    if displaySettings.showHumanAge {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("人間換算")
                                .font(.caption2)
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.5))
                            Text("\(pet.humanAge)歳")
                                .font(.system(size: CGFloat(displaySettings.ageFontSize)))
                                .foregroundColor(ColorHelper.hexColor(themeSettings.fontColor).opacity(0.7))
                        }
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("アプリでペットを\n登録してください")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    // MARK: - Helper Views
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

    private func petPhotoView(photoData: Data?, frameType: PhotoFrameType, size: CGFloat) -> some View {
        Group {
            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                let image = Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)

                switch frameType {
                case .circle:
                    image.clipShape(Circle())
                case .roundedRect:
                    image.clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                case .none:
                    image
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: size, height: size)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    // MARK: - Helper Functions
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

#Preview {
    let samplePet = Pet(
        name: "ポチ",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        species: .dog,
        photoData: nil
    )

    VStack(spacing: 20) {
        WidgetPreviewView(pet: samplePet, settings: .default, widgetSize: .small)
        WidgetPreviewView(pet: samplePet, settings: .default, widgetSize: .medium)
        WidgetPreviewView(pet: samplePet, settings: .default, widgetSize: .large)
    }
    .padding()
}
