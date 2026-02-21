import Foundation

/// 服薬スケジュールの種別
enum MedicationScheduleType: String, Codable, Sendable, CaseIterable, Identifiable {
    /// 毎日
    case daily
    /// 毎週（曜日指定）
    case weekly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: "毎日"
        case .weekly: "毎週"
        }
    }
}

/// 服薬スケジュール用の曜日
enum MedicationWeekday: Int, Codable, Sendable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .sunday: "日"
        case .monday: "月"
        case .tuesday: "火"
        case .wednesday: "水"
        case .thursday: "木"
        case .friday: "金"
        case .saturday: "土"
        }
    }
}
