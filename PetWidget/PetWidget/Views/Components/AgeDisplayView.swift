import SwiftUI

struct AgeDisplayView: View {
    let pet: Pet
    let showHumanAge: Bool
    let detailLevel: AgeDisplayDetailLevel?

    init(pet: Pet, showHumanAge: Bool = true, detailLevel: AgeDisplayDetailLevel? = nil) {
        self.pet = pet
        self.showHumanAge = showHumanAge
        self.detailLevel = detailLevel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 実年齢表示
            HStack(spacing: 4) {
                Text(ageText)
                    .font(.body)
                    .fontWeight(.medium)
                Text("(\(formattedBirthDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 人間換算年齢表示
            if showHumanAge {
                Text("人間だと \(pet.humanAge)歳")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var ageText: String {
        // detailLevelが指定されている場合はそれを使用
        if let detailLevel = detailLevel {
            return AgeCalculator.ageString(from: pet.birthDate, detailLevel: detailLevel)
        }

        // 指定がない場合は従来の表示（年月）
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

    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: pet.birthDate)
    }
}

#Preview {
    let samplePet = Pet(
        name: "ポチ",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        species: .dog
    )

    return VStack(spacing: 20) {
        AgeDisplayView(pet: samplePet, showHumanAge: true)
        AgeDisplayView(pet: samplePet, showHumanAge: false)
    }
    .padding()
}
