import Foundation

/// クエスト中に発生するイベント
struct QuestEvent: Identifiable, Sendable {
    let id: UUID
    let type: QuestEventType
    let title: String
    let description: String
    let choices: [EventChoice]
    let occurredAt: Date

    /// 時刻テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: occurredAt)
    }

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: occurredAt)
    }
}

// MARK: - QuestEventType

/// イベントの種類
enum QuestEventType: String, CaseIterable, Sendable {
    case battle = "バトル"
    case treasure = "宝箱"
    case encounter = "出会い"
    case trap = "罠"
    case rest = "休憩所"
    case boss = "ボス"
    case shop = "お店"

    var emoji: String {
        switch self {
        case .battle: "⚔️"
        case .treasure: "🎁"
        case .encounter: "👤"
        case .trap: "💥"
        case .rest: "⛺"
        case .boss: "🐉"
        case .shop: "🏪"
        }
    }

    var systemImageName: String {
        switch self {
        case .battle: "bolt.fill"
        case .treasure: "gift.fill"
        case .encounter: "person.fill"
        case .trap: "exclamationmark.triangle.fill"
        case .rest: "tent.fill"
        case .boss: "flame.fill"
        case .shop: "bag.fill"
        }
    }
}

// MARK: - EventChoice

/// イベントの選択肢
struct EventChoice: Identifiable, Sendable {
    let id: UUID
    let label: String
    let emoji: String
    let resultDescription: String
    let hpEffect: Int
    let mpEffect: Int
    let goldEffect: Int
    let expEffect: Int

    /// 効果のサマリーテキスト
    var effectSummary: String {
        var parts: [String] = []
        if hpEffect != 0 { parts.append("HP \(hpEffect > 0 ? "+" : "")\(hpEffect)") }
        if mpEffect != 0 { parts.append("MP \(mpEffect > 0 ? "+" : "")\(mpEffect)") }
        if goldEffect != 0 { parts.append("💰 \(goldEffect > 0 ? "+" : "")\(goldEffect)") }
        if expEffect != 0 { parts.append("EXP \(expEffect > 0 ? "+" : "")\(expEffect)") }
        return parts.joined(separator: " ")
    }
}

// MARK: - QuestLocation

/// 冒険の場所
struct QuestLocation: Identifiable, Sendable {
    let id: UUID
    let name: String
    let emoji: String
    let description: String
    let difficulty: Int

    /// 難易度のテキスト表示
    var difficultyText: String {
        String(repeating: "★", count: difficulty) + String(repeating: "☆", count: 5 - difficulty)
    }
}
