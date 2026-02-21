import Foundation

/// カレンダーイベントを表すモデル（EventKit の EKEvent をアプリ内で扱うための変換モデル）
struct CalendarEvent: Identifiable, Sendable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let calendarName: String
    let calendarColorName: String
    let isAllDay: Bool

    /// イベントの所要時間（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 時間帯テキスト
    var timeRangeText: String {
        if isAllDay { return "終日" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: startDate)
    }

    /// サンプルデータ
    static let samples: [CalendarEvent] = {
        let today = Calendar.current.startOfDay(for: Date())
        return [
            CalendarEvent(
                id: UUID(),
                title: "チームミーティング",
                startDate: today.addingTimeInterval(9 * 3600),
                endDate: today.addingTimeInterval(10 * 3600),
                location: "会議室A",
                calendarName: "仕事",
                calendarColorName: "blue",
                isAllDay: false
            ),
            CalendarEvent(
                id: UUID(),
                title: "ランチ",
                startDate: today.addingTimeInterval(12 * 3600),
                endDate: today.addingTimeInterval(13 * 3600),
                location: nil,
                calendarName: "プライベート",
                calendarColorName: "green",
                isAllDay: false
            ),
            CalendarEvent(
                id: UUID(),
                title: "プロジェクトレビュー",
                startDate: today.addingTimeInterval(14 * 3600),
                endDate: today.addingTimeInterval(15.5 * 3600),
                location: "オンライン",
                calendarName: "仕事",
                calendarColorName: "blue",
                isAllDay: false
            ),
            CalendarEvent(
                id: UUID(),
                title: "歯医者",
                startDate: today.addingTimeInterval(17 * 3600),
                endDate: today.addingTimeInterval(18 * 3600),
                location: "〇〇歯科",
                calendarName: "プライベート",
                calendarColorName: "green",
                isAllDay: false
            ),
        ]
    }()
}
