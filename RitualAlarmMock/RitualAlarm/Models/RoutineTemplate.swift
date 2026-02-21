import Foundation
import SwiftUI

/// ルーティンテンプレート — 各ステップの所要時間をカスタマイズ可能
@Observable
final class RoutineTemplate {
    /// 起床時刻
    var wakeUpTime: Date {
        didSet { save() }
    }

    /// 各ステップの所要時間（秒）
    var stepDurations: [RoutineStep: TimeInterval] {
        didSet { save() }
    }

    /// スヌーズ時間（秒）
    var snoozeDuration: TimeInterval {
        didSet { save() }
    }

    /// 繰り返し曜日
    var repeatDays: Set<Weekday> {
        didSet { save() }
    }

    /// ルーティンが有効か
    var isEnabled: Bool {
        didSet { save() }
    }

    // MARK: - UserDefaults Keys

    private static let wakeUpHourKey = "wakeUpHour"
    private static let wakeUpMinuteKey = "wakeUpMinute"
    private static let stepDurationsKey = "stepDurations"
    private static let snoozeDurationKey = "snoozeDuration"
    private static let repeatDaysKey = "repeatDays"
    private static let isEnabledKey = "isEnabled"

    init() {
        let defaults = UserDefaults.standard

        // 起床時刻の復元（デフォルト: 6:30）
        let hour = defaults.nonZeroInteger(forKey: Self.wakeUpHourKey) ?? 6
        let minute = defaults.object(forKey: Self.wakeUpMinuteKey) != nil
            ? defaults.integer(forKey: Self.wakeUpMinuteKey)
            : 30
        var calendar = Calendar.current
        calendar.timeZone = .current
        self.wakeUpTime = calendar.date(
            bySettingHour: hour, minute: minute, second: 0, of: .now
        ) ?? .now

        // 各ステップの所要時間
        var durations: [RoutineStep: TimeInterval] = [:]
        for step in RoutineStep.allCases {
            let key = "duration_\(step.rawValue)"
            let value = defaults.double(forKey: key)
            durations[step] = value > 0 ? value : step.defaultDuration
        }
        self.stepDurations = durations

        // スヌーズ時間（デフォルト: 5分）
        let snooze = defaults.double(forKey: Self.snoozeDurationKey)
        self.snoozeDuration = snooze > 0 ? snooze : 5 * 60

        // 繰り返し曜日（デフォルト: 月〜金）
        if let savedDays = defaults.array(forKey: Self.repeatDaysKey) as? [Int] {
            self.repeatDays = Set(savedDays.compactMap { Weekday(rawValue: $0) })
        } else {
            self.repeatDays = [.monday, .tuesday, .wednesday, .thursday, .friday]
        }

        // 有効/無効
        self.isEnabled = defaults.object(forKey: Self.isEnabledKey) != nil
            ? defaults.bool(forKey: Self.isEnabledKey)
            : true
    }

    /// ステップの所要時間を取得
    func duration(for step: RoutineStep) -> TimeInterval {
        stepDurations[step] ?? step.defaultDuration
    }

    /// ルーティン全体の所要時間（分）
    var totalDurationMinutes: Int {
        let total = RoutineStep.allCases.reduce(0.0) { $0 + duration(for: $1) }
        return Int(total / 60)
    }

    /// 出発予定時刻
    var estimatedDepartureTime: Date {
        let total = RoutineStep.allCases.reduce(0.0) { $0 + duration(for: $1) }
        return wakeUpTime.addingTimeInterval(total)
    }

    private func save() {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current

        defaults.set(calendar.component(.hour, from: wakeUpTime), forKey: Self.wakeUpHourKey)
        defaults.set(calendar.component(.minute, from: wakeUpTime), forKey: Self.wakeUpMinuteKey)

        for (step, duration) in stepDurations {
            defaults.set(duration, forKey: "duration_\(step.rawValue)")
        }

        defaults.set(snoozeDuration, forKey: Self.snoozeDurationKey)
        defaults.set(repeatDays.map(\.rawValue), forKey: Self.repeatDaysKey)
        defaults.set(isEnabled, forKey: Self.isEnabledKey)
    }
}

// MARK: - Weekday

/// 曜日
enum Weekday: Int, Codable, Sendable, CaseIterable, Identifiable {
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

// MARK: - Helpers

private extension UserDefaults {
    func nonZeroInteger(forKey key: String) -> Int? {
        let value = integer(forKey: key)
        return value == 0 && object(forKey: key) == nil ? nil : value
    }
}
