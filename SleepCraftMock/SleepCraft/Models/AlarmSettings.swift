import Foundation

/// スマートアラームの設定
struct AlarmSettings: Codable, Sendable {
    /// 起床希望時刻（時:分）
    var wakeUpHour: Int
    var wakeUpMinute: Int

    /// スマートアラームウィンドウ（分）— 起床希望時刻の何分前から浅い睡眠を検知するか
    var smartWindowMinutes: Int

    /// スヌーズ時間（分）
    var snoozeDurationMinutes: Int

    /// スマートアラーム有効
    var isSmartAlarmEnabled: Bool

    /// アラーム有効
    var isEnabled: Bool

    /// 繰り返し曜日（0=日, 1=月, ... 6=土）
    var repeatDays: Set<Int>

    static let `default` = AlarmSettings(
        wakeUpHour: 7,
        wakeUpMinute: 0,
        smartWindowMinutes: 30,
        snoozeDurationMinutes: 5,
        isSmartAlarmEnabled: true,
        isEnabled: true,
        repeatDays: [1, 2, 3, 4, 5] // 平日
    )

    /// 起床希望時刻を今日の Date に変換
    var wakeUpTimeToday: Date {
        Calendar.current.date(
            bySettingHour: wakeUpHour,
            minute: wakeUpMinute,
            second: 0,
            of: .now
        ) ?? .now
    }

    /// スマートウィンドウ開始時刻
    var smartWindowStart: Date {
        wakeUpTimeToday.addingTimeInterval(-Double(smartWindowMinutes) * 60)
    }

    /// 繰り返し曜日の表示テキスト
    var repeatDaysText: String {
        if repeatDays.isEmpty { return "なし" }
        if repeatDays.count == 7 { return "毎日" }
        if repeatDays == [1, 2, 3, 4, 5] { return "平日" }
        if repeatDays == [0, 6] { return "週末" }

        let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
        let sorted = repeatDays.sorted()
        return sorted.map { dayNames[$0] }.joined(separator: " ")
    }
}
