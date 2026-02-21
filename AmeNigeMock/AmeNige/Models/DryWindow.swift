import Foundation

/// 雨が止む/降らない「晴れ間ウィンドウ」
struct DryWindow: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date

    /// 晴れ間の長さ（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 晴れ間の長さの表示テキスト
    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)時間\(minutes)分" : "\(hours)時間"
        }
        return "\(minutes)分"
    }

    /// 開始時刻の表示テキスト
    var startTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startDate)
    }

    /// 終了時刻の表示テキスト
    var endTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endDate)
    }

    /// 時間帯の表示テキスト
    var timeRangeText: String {
        "\(startTimeText) - \(endTimeText)"
    }

    /// 外出に十分な長さかどうか（10分以上）
    var isSufficientForOutdoor: Bool {
        durationMinutes >= 10
    }

    /// 今すぐ利用可能かどうか
    var isAvailableNow: Bool {
        let now = Date()
        return startDate <= now && endDate > now
    }

    /// 開始までの残り時間（分）
    var minutesUntilStart: Int {
        max(0, Int(startDate.timeIntervalSinceNow / 60))
    }
}

/// 外出判定の結果
enum OutdoorVerdict: Sendable {
    /// 今すぐ外出可能（雨が降っていない）
    case goNow(returnBy: Date)
    /// 少し待てば外出可能
    case waitThenGo(window: DryWindow)
    /// 当面外出は難しい
    case stayIndoor(nextDryWindow: DryWindow?)
    /// 降水データが利用不可能
    case unavailable

    /// 判定メッセージ
    var message: String {
        switch self {
        case .goNow(let returnBy):
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "\(formatter.string(from: returnBy)) までに帰宅すれば濡れません"
        case .waitThenGo(let window):
            return "\(window.startTimeText) から \(window.durationText) の晴れ間があります"
        case .stayIndoor(let nextWindow):
            if let window = nextWindow {
                return "次の晴れ間は \(window.startTimeText) 頃です"
            }
            return "1時間以内に晴れ間はなさそうです"
        case .unavailable:
            return "降水予報データを取得できませんでした"
        }
    }

    /// 判定に対応するアイコン
    var systemImageName: String {
        switch self {
        case .goNow: "figure.walk"
        case .waitThenGo: "clock.fill"
        case .stayIndoor: "house.fill"
        case .unavailable: "questionmark.circle"
        }
    }

    /// 判定の見出し
    var title: String {
        switch self {
        case .goNow: "今すぐ外出OK"
        case .waitThenGo: "もう少し待って"
        case .stayIndoor: "今は室内が安全"
        case .unavailable: "データなし"
        }
    }
}
