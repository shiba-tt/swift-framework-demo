import Foundation
import CoreLocation

/// イベント間の空き時間スロット
struct TimeSlot: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let previousEvent: ScheduleEvent?
    let nextEvent: ScheduleEvent?

    /// 空き時間の長さ（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 表示用の空き時間テキスト
    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)時間\(minutes)分" : "\(hours)時間"
        }
        return "\(minutes)分"
    }

    /// 時間帯の表示テキスト
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

/// 空き時間に提案するアクティビティ
struct SuggestedActivity: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let category: ActivityCategory
    let estimatedMinutes: Int
    let systemImageName: String

    /// 提案アクティビティの表示テキスト
    var durationText: String {
        "\(estimatedMinutes)分"
    }
}

/// アクティビティのカテゴリ
enum ActivityCategory: String, Sendable, CaseIterable {
    case cafe = "カフェ"
    case exercise = "運動"
    case shopping = "買い物"
    case rest = "休憩"
    case reading = "読書"
    case walk = "散歩"

    var systemImageName: String {
        switch self {
        case .cafe: "cup.and.saucer.fill"
        case .exercise: "figure.run"
        case .shopping: "bag.fill"
        case .rest: "leaf.fill"
        case .reading: "book.fill"
        case .walk: "figure.walk"
        }
    }
}
