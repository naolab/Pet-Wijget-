import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: PetWidgetEntry

    var body: some View {
        if let pet = entry.pet {
            petContentView(pet: pet)
        } else {
            emptyStateView
        }
    }

    private func petContentView(pet: Pet) -> some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                // ペット写真 (小さめ)
                petPhotoView(photoData: pet.photoData)

                // 現在時刻 (大きく表示)
                Text(entry.date, style: .time)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                // ペット名 (コンパクト)
                HStack(spacing: 2) {
                    Image(systemName: speciesIcon(pet.species))
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text(pet.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
        }
    }

    private func petPhotoView(photoData: Data?) -> some View {
        Group {
            if let photoData = photoData,
               let processedImage = processPhotoForWidget(photoData) {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
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

    PetWidgetEntry(date: .now, pet: samplePet, errorMessage: nil)
    PetWidgetEntry(date: .now, pet: nil, errorMessage: "ペットが登録されていません")
}
