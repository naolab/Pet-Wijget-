import Foundation
import SwiftUI

struct DisplaySettings: Codable {
    // 表示項目ON/OFF
    var showName: Bool
    var showAge: Bool
    var showHumanAge: Bool
    var showTime: Bool
    var showDate: Bool
    var showDivider: Bool

    // 時刻・日付フォーマット
    var use24HourFormat: Bool
    var dateFormat: DateFormatType

    // レイアウト設定
    var textAlignment: TextAlignmentType

    // フォント設定
    var nameFontSize: CGFloat
    var ageFontSize: CGFloat
    var timeFontSize: CGFloat
    var dateFontSize: CGFloat

    static var `default`: DisplaySettings {
        DisplaySettings(
            showName: true,
            showAge: true,
            showHumanAge: true,
            showTime: true,
            showDate: true,
            showDivider: true,
            use24HourFormat: true,
            dateFormat: .yearMonthDay,
            textAlignment: .leading,
            nameFontSize: 16,
            ageFontSize: 14,
            timeFontSize: 24,
            dateFontSize: 12
        )
    }
}

enum DateFormatType: String, Codable, CaseIterable {
    case yearMonthDay = "yyyy年M月d日"
    case monthDay = "M月d日"
    case dayOfWeek = "M月d日(E)"
    case western = "yyyy/MM/dd"

    var displayName: String {
        switch self {
        case .yearMonthDay: return "2025年1月1日"
        case .monthDay: return "1月1日"
        case .dayOfWeek: return "1月1日(水)"
        case .western: return "2025/01/01"
        }
    }
}

enum TextAlignmentType: String, Codable, CaseIterable {
    case leading = "left"
    case center = "center"
    case trailing = "right"

    var displayName: String {
        switch self {
        case .leading: return "左寄せ"
        case .center: return "中央"
        case .trailing: return "右寄せ"
        }
    }

    var alignment: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}
