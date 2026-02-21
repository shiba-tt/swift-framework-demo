import Foundation
import CoreLocation

/// カレンダーイベントを地図表示用に変換したモデル
struct ScheduleEvent: Identifiable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let coordinate: CLLocationCoordinate2D?
    let calendarColor: CalendarColor
    let notes: String?
    let isAllDay: Bool

    /// イベントの所要時間（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 時間帯の表示テキスト
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    /// 座標が設定されているかどうか
    var hasCoordinate: Bool {
        coordinate != nil
    }
}

/// カレンダーのカラー識別子
enum CalendarColor: String, Sendable, CaseIterable {
    case blue
    case red
    case green
    case orange
    case purple
    case yellow
    case brown
    case pink

    /// デフォルトカラー
    static var `default`: CalendarColor { .blue }
}
