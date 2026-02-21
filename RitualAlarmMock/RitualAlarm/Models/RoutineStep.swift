import Foundation

/// 朝のルーティンの各ステップを表す列挙型
enum RoutineStep: String, Codable, Sendable, CaseIterable, Identifiable {
    /// 起床アラーム
    case wakeUp
    /// ストレッチタイマー
    case stretch
    /// 朝食準備アラーム
    case breakfast
    /// 出発準備タイマー
    case preparation
    /// 出発アラーム
    case departure

    var id: String { rawValue }

    /// ステップの表示名
    var label: String {
        switch self {
        case .wakeUp: "起床"
        case .stretch: "ストレッチ"
        case .breakfast: "朝食準備"
        case .preparation: "出発準備"
        case .departure: "出発"
        }
    }

    /// システムアイコン名
    var systemImageName: String {
        switch self {
        case .wakeUp: "alarm.fill"
        case .stretch: "figure.flexibility"
        case .breakfast: "fork.knife"
        case .preparation: "bag.fill"
        case .departure: "door.left.hand.open"
        }
    }

    /// 絵文字
    var emoji: String {
        switch self {
        case .wakeUp: "🔔"
        case .stretch: "🧘"
        case .breakfast: "🍳"
        case .preparation: "👔"
        case .departure: "🚶"
        }
    }

    /// テーマカラー名（SwiftUI Color にマッピング）
    var colorName: String {
        switch self {
        case .wakeUp: "orange"
        case .stretch: "green"
        case .breakfast: "yellow"
        case .preparation: "blue"
        case .departure: "purple"
        }
    }

    /// アラーム発火時のタイトル
    var alertTitle: String {
        switch self {
        case .wakeUp: "🔔 起きる時間です！"
        case .stretch: "🧘 ストレッチ完了！"
        case .breakfast: "🍳 朝食準備の時間です！"
        case .preparation: "👔 出発準備完了！"
        case .departure: "🚶 家を出る時間です！"
        }
    }

    /// アラーム発火時のサブタイトル
    var alertSubtitle: String {
        switch self {
        case .wakeUp: "おはようございます！今日も良い1日を"
        case .stretch: "体がほぐれましたね。次は朝食です"
        case .breakfast: "しっかり食べてエネルギーチャージ"
        case .preparation: "忘れ物はありませんか？"
        case .departure: "行ってらっしゃい！"
        }
    }

    /// デフォルトの所要時間（秒）
    var defaultDuration: TimeInterval {
        switch self {
        case .wakeUp: 0         // 即時アラーム（カウントダウンなし）
        case .stretch: 5 * 60   // 5分
        case .breakfast: 20 * 60 // 20分
        case .preparation: 20 * 60 // 20分
        case .departure: 0      // 即時アラーム
        }
    }

    /// このステップがカウントダウンタイマーか（アラームではなく）
    var isCountdown: Bool {
        defaultDuration > 0
    }

    /// Stop ボタンのテキスト
    var stopButtonText: String {
        switch self {
        case .wakeUp: "起きた"
        case .stretch: "完了"
        case .breakfast: "準備完了"
        case .preparation: "完了"
        case .departure: "出発した"
        }
    }

    /// 次のステップ（nil = 最後のステップ）
    var next: RoutineStep? {
        let all = RoutineStep.allCases
        guard let index = all.firstIndex(of: self),
              index + 1 < all.count else { return nil }
        return all[index + 1]
    }

    /// ステップのインデックス（0始まり）
    var index: Int {
        RoutineStep.allCases.firstIndex(of: self) ?? 0
    }

    /// 全ステップ数
    static var totalCount: Int {
        allCases.count
    }
}
