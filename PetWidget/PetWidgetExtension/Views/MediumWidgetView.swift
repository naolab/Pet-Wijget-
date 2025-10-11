import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: PetWidgetEntry

    var body: some View {
        if let pet = entry.pet {
            petContentView(pet: pet)
        } else {
            emptyStateView
        }
    }

    private func petContentView(pet: Pet) -> some View {
        HStack(spacing: 16) {
            // 左側: ペット写真
            petPhotoView(photoData: pet.photoData)

            // 右側: 時刻・ペット情報
            VStack(alignment: .leading, spacing: 8) {
                // 現在時刻
                Text(entry.date, style: .time)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                // 日付
                Text(formattedDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical, 4)

                // ペット名
                HStack(spacing: 4) {
                    Image(systemName: speciesIcon(pet.species))
                        .foregroundColor(.secondary)
                    Text(pet.name)
                        .font(.headline)
                }

                // 年齢情報
                VStack(alignment: .leading, spacing: 2) {
                    Text(ageText(pet))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("人間だと \(pet.humanAge)歳")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func petPhotoView(photoData: Data?) -> some View {
        Group {
            if let photoData = photoData,
               let processedImage = processPhotoForWidget(photoData) {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
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
        case .other: return "hare.fill"
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

    PetWidgetEntry(date: .now, pet: samplePet, errorMessage: nil)
    PetWidgetEntry(date: .now, pet: nil, errorMessage: "ペットが登録されていません")
}
