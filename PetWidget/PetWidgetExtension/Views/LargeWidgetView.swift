import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: PetWidgetEntry

    var body: some View {
        if let pet = entry.pet {
            petContentView(pet: pet)
        } else {
            emptyStateView
        }
    }

    private func petContentView(pet: Pet) -> some View {
        VStack(spacing: 0) {
            // 上部: 時刻・日付セクション
            timeSection

            Divider()
                .padding(.vertical, 12)

            // 下部: ペット情報セクション
            petInfoSection(pet: pet)

            Spacer()
        }
        .padding(16)
    }

    // MARK: - 時刻セクション
    private var timeSection: some View {
        VStack(spacing: 4) {
            // 現在時刻
            Text(entry.date, style: .time)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            // 日付
            Text(formattedDate(entry.date))
                .font(.system(size: 16))
                .foregroundColor(.secondary)

            // 曜日
            Text(formattedWeekday(entry.date))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - ペット情報セクション
    private func petInfoSection(pet: Pet) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // 左側: ペット写真
            petPhotoView(photoData: pet.photoData)

            // 右側: 詳細情報
            VStack(alignment: .leading, spacing: 12) {
                // ペット名
                HStack(spacing: 6) {
                    Image(systemName: speciesIcon(pet.species))
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text(pet.name)
                        .font(.system(size: 24, weight: .bold))
                }

                // 誕生日
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.pink)
                    Text("誕生日: \(formattedBirthDate(pet.birthDate))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                // 年齢情報
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text(ageText(pet))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("人間だと \(pet.humanAge)歳")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
    }

    private func petPhotoView(photoData: Data?) -> some View {
        Group {
            if let photoData = photoData,
               let processedImage = processPhotoForWidget(photoData) {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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

                Text(formattedDate(entry.date))
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
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
        case .other: return "hare.fill"
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

    PetWidgetEntry(date: .now, pet: samplePet, errorMessage: nil)
    PetWidgetEntry(date: .now, pet: nil, errorMessage: "ペットが登録されていません")
}
