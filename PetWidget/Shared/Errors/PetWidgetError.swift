import Foundation

enum PetWidgetError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case photoAccessDenied
    case photoSaveFailed
    case invalidData
    case coreDataError(Error)

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "データの読み込みに失敗しました"
        case .dataSaveFailed:
            return "データの保存に失敗しました"
        case .photoAccessDenied:
            return "写真へのアクセスが拒否されました"
        case .photoSaveFailed:
            return "写真の保存に失敗しました"
        case .invalidData:
            return "不正なデータです"
        case .coreDataError(let error):
            return "データベースエラー: \(error.localizedDescription)"
        }
    }
}
