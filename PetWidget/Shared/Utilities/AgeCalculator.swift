import Foundation

final class AgeCalculator {
    static func calculateAge(from birthDate: Date, to currentDate: Date = Date()) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: currentDate)
        return (components.year ?? 0, components.month ?? 0)
    }

    static func ageString(from birthDate: Date) -> String {
        let (years, months) = calculateAge(from: birthDate)

        if years == 0 {
            return "\(months)ヶ月"
        } else if months == 0 {
            return "\(years)歳"
        } else {
            return "\(years)歳\(months)ヶ月"
        }
    }
}
