import Foundation

// MARK: - 料理タイマーの状態

/// タイマーの現在の状態を表す列挙型
enum TimerState: String, Codable, Sendable {
    /// スケジュール済み（まだ開始されていない）
    case scheduled
    /// カウントダウン中
    case counting
    /// 一時停止中
    case paused
    /// アラート発火中（タイマー完了）
    case alerting
    /// 停止済み（完了）
    case stopped
}

// MARK: - 料理カテゴリ

/// 料理の工程カテゴリ
enum CookingCategory: String, Codable, Sendable, CaseIterable {
    case boil       // 茹でる
    case simmer     // 煮込む
    case bake       // オーブン
    case grill      // グリル
    case steam      // 蒸す
    case fry        // 炒める・揚げる
    case rest       // 寝かせる・冷ます
    case marinate   // 漬け込む
    case custom     // カスタム

    /// カテゴリの表示名
    var displayName: String {
        switch self {
        case .boil:     return "茹でる"
        case .simmer:   return "煮込む"
        case .bake:     return "オーブン"
        case .grill:    return "グリル"
        case .steam:    return "蒸す"
        case .fry:      return "炒める"
        case .rest:     return "寝かせる"
        case .marinate: return "漬け込む"
        case .custom:   return "カスタム"
        }
    }

    /// カテゴリのアイコン（SF Symbols）
    var iconName: String {
        switch self {
        case .boil:     return "flame.fill"
        case .simmer:   return "cooktop.fill"
        case .bake:     return "oven.fill"
        case .grill:    return "flame.fill"
        case .steam:    return "cloud.fill"
        case .fry:      return "frying.pan.fill"
        case .rest:     return "snowflake"
        case .marinate: return "clock.arrow.circlepath"
        case .custom:   return "timer"
        }
    }

    /// カテゴリの絵文字
    var emoji: String {
        switch self {
        case .boil:     return "🍝"
        case .simmer:   return "🥘"
        case .bake:     return "🍖"
        case .grill:    return "🔥"
        case .steam:    return "🫕"
        case .fry:      return "🍳"
        case .rest:     return "❄️"
        case .marinate: return "🫙"
        case .custom:   return "⏱️"
        }
    }

    /// カテゴリごとのテーマカラー名
    var colorName: String {
        switch self {
        case .boil:     return "timerBlue"
        case .simmer:   return "timerRed"
        case .bake:     return "timerOrange"
        case .grill:    return "timerBrown"
        case .steam:    return "timerTeal"
        case .fry:      return "timerYellow"
        case .rest:     return "timerCyan"
        case .marinate: return "timerPurple"
        case .custom:   return "timerGray"
        }
    }
}

// MARK: - 料理タイマーモデル

/// 個々の料理タイマーを表すモデル
struct CookingTimer: Identifiable, Codable, Sendable {
    /// タイマーの一意識別子（AlarmKit の Alarm ID と一致させる）
    let id: UUID
    /// タイマー名（例: "パスタ茹で"）
    var name: String
    /// 料理カテゴリ
    var category: CookingCategory
    /// 設定された時間（秒）
    var duration: TimeInterval
    /// タイマー開始時刻
    var startedAt: Date?
    /// 一時停止時の残り時間（秒）
    var pausedRemainingTime: TimeInterval?
    /// 現在の状態
    var state: TimerState
    /// カスタムサウンド名（nil の場合はデフォルト）
    var soundName: String?
    /// メモ（任意）
    var note: String?
    /// 作成日時
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: CookingCategory,
        duration: TimeInterval,
        soundName: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.duration = duration
        self.state = .scheduled
        self.soundName = soundName
        self.note = note
        self.createdAt = Date()
    }

    /// 残り時間を計算
    var remainingTime: TimeInterval {
        switch state {
        case .paused:
            return pausedRemainingTime ?? duration
        case .counting:
            guard let startedAt else { return duration }
            let elapsed = Date().timeIntervalSince(startedAt)
            return max(0, duration - elapsed)
        default:
            return duration
        }
    }

    /// 残り時間のフォーマット済み文字列（mm:ss）
    var formattedRemainingTime: String {
        let total = Int(remainingTime)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// 進捗率（0.0 〜 1.0）
    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }
}
