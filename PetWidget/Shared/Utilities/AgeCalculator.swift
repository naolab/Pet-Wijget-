import Foundation

final class AgeCalculator {
    static func calculateAge(from birthDate: Date, to currentDate: Date = Date()) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: currentDate)
        return (components.year ?? 0, components.month ?? 0)
    }

    static func calculateAgeWithDays(from birthDate: Date, to currentDate: Date = Date()) -> (years: Int, months: Int, days: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: currentDate)
        return (components.year ?? 0, components.month ?? 0, components.day ?? 0)
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

    static func ageString(from birthDate: Date, detailLevel: AgeDisplayDetailLevel) -> String {
        let (years, months, days) = calculateAgeWithDays(from: birthDate)

        switch detailLevel {
        case .yearsOnly:
            return years == 0 ? "\(months)ヶ月" : "\(years)歳"

        case .yearsAndMonths:
            if years == 0 {
                return "\(months)ヶ月"
            } else if months == 0 {
                return "\(years)歳"
            } else {
                return "\(years)歳\(months)ヶ月"
            }

        case .full:
            var components: [String] = []
            if years > 0 {
                components.append("\(years)歳")
            }
            if months > 0 || years > 0 {
                components.append("\(months)ヶ月")
            }
            if days > 0 || (years == 0 && months == 0) {
                components.append("\(days)日")
            }
            return components.joined()
        }
    }
}
