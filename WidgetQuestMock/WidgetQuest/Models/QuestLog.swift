import Foundation

/// 冒険ログのエントリー
struct QuestLogEntry: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let eventType: QuestEventType
    let message: String
    let choiceLabel: String?
    let hpChange: Int
    let mpChange: Int
    let goldChange: Int
    let expChange: Int

    /// 日時テキスト
    var dateTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 結果サマリーテキスト
    var resultSummary: String {
        var parts: [String] = []
        if hpChange != 0 { parts.append("HP\(hpChange > 0 ? "+" : "")\(hpChange)") }
        if mpChange != 0 { parts.append("MP\(mpChange > 0 ? "+" : "")\(mpChange)") }
        if goldChange != 0 { parts.append("💰\(goldChange > 0 ? "+" : "")\(goldChange)") }
        if expChange != 0 { parts.append("EXP\(expChange > 0 ? "+" : "")\(expChange)") }
        return parts.isEmpty ? "変化なし" : parts.joined(separator: " ")
    }
}

// MARK: - QuestStats

/// 冒険の統計情報
struct QuestStats: Sendable {
    var totalBattles: Int
    var totalTreasures: Int
    var totalGoldEarned: Int
    var totalExpEarned: Int
    var bossesDefeated: Int
    var eventsCompleted: Int
    var longestStreak: Int

    /// デフォルトの統計
    static let `default` = QuestStats(
        totalBattles: 0,
        totalTreasures: 0,
        totalGoldEarned: 0,
        totalExpEarned: 0,
        bossesDefeated: 0,
        eventsCompleted: 0,
        longestStreak: 0
    )
}
