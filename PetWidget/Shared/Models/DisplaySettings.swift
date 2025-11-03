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

    // 年齢表示詳細度
    var ageDisplayDetail: AgeDisplayDetailLevel

    // フォントデザイン
    var textFontDesign: FontDesignType      // テキスト（名前・年齢）用
    var timeDateFontDesign: FontDesignType  // 時刻・日付用

    // フォントサイズ
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
            ageDisplayDetail: .yearsAndMonths,
            textFontDesign: .default,
            timeDateFontDesign: .rounded,
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

enum AgeDisplayDetailLevel: String, Codable, CaseIterable {
    case yearsOnly = "years"
    case yearsAndMonths = "yearsMonths"
    case full = "full"

    var displayName: String {
        switch self {
        case .yearsOnly: return "年のみ"
        case .yearsAndMonths: return "年月"
        case .full: return "年月日"
        }
    }

    var example: String {
        switch self {
        case .yearsOnly: return "3歳"
        case .yearsAndMonths: return "3歳2ヶ月"
        case .full: return "3歳2ヶ月15日"
        }
    }
}

enum FontDesignType: String, Codable, CaseIterable {
    case `default` = "default"
    case rounded = "rounded"
    case serif = "serif"
    case monospaced = "monospaced"

    var displayName: String {
        switch self {
        case .default: return "標準"
        case .rounded: return "丸ゴシック"
        case .serif: return "セリフ"
        case .monospaced: return "等幅"
        }
    }

    var design: Font.Design {
        switch self {
        case .default: return .default
        case .rounded: return .rounded
        case .serif: return .serif
        case .monospaced: return .monospaced
        }
    }
}
