import Foundation
import SwiftUI

/// ポモドーロ設定
@Observable
final class PomodoroSettings {
    /// 作業時間（秒）
    var workDuration: TimeInterval {
        didSet { save() }
    }

    /// 短い休憩時間（秒）
    var shortBreakDuration: TimeInterval {
        didSet { save() }
    }

    /// 長い休憩時間（秒）
    var longBreakDuration: TimeInterval {
        didSet { save() }
    }

    /// 長い休憩までのポモドーロ数
    var longBreakInterval: Int {
        didSet { save() }
    }

    /// 自動的に次のフェーズに移行するか
    var autoStartNextPhase: Bool {
        didSet { save() }
    }

    /// 1日のポモドーロ目標数
    var dailyGoal: Int {
        didSet { save() }
    }

    private static let workDurationKey = "workDuration"
    private static let shortBreakDurationKey = "shortBreakDuration"
    private static let longBreakDurationKey = "longBreakDuration"
    private static let longBreakIntervalKey = "longBreakInterval"
    private static let autoStartNextPhaseKey = "autoStartNextPhase"
    private static let dailyGoalKey = "dailyGoal"

    init() {
        let defaults = UserDefaults.standard
        self.workDuration = defaults.double(forKey: Self.workDurationKey).nonZero ?? 25 * 60
        self.shortBreakDuration = defaults.double(forKey: Self.shortBreakDurationKey).nonZero ?? 5 * 60
        self.longBreakDuration = defaults.double(forKey: Self.longBreakDurationKey).nonZero ?? 15 * 60
        self.longBreakInterval = defaults.nonZeroInteger(forKey: Self.longBreakIntervalKey) ?? 4
        self.autoStartNextPhase = defaults.bool(forKey: Self.autoStartNextPhaseKey)
        self.dailyGoal = defaults.nonZeroInteger(forKey: Self.dailyGoalKey) ?? 8
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(workDuration, forKey: Self.workDurationKey)
        defaults.set(shortBreakDuration, forKey: Self.shortBreakDurationKey)
        defaults.set(longBreakDuration, forKey: Self.longBreakDurationKey)
        defaults.set(longBreakInterval, forKey: Self.longBreakIntervalKey)
        defaults.set(autoStartNextPhase, forKey: Self.autoStartNextPhaseKey)
        defaults.set(dailyGoal, forKey: Self.dailyGoalKey)
    }

    /// フェーズに応じた時間（秒）を返す
    func duration(for phase: PomodoroPhase) -> TimeInterval {
        switch phase {
        case .work: workDuration
        case .shortBreak: shortBreakDuration
        case .longBreak: longBreakDuration
        }
    }
}

// MARK: - Helpers

private extension Double {
    var nonZero: Double? {
        self == 0 ? nil : self
    }
}

private extension UserDefaults {
    func nonZeroInteger(forKey key: String) -> Int? {
        let value = integer(forKey: key)
        return value == 0 ? nil : value
    }
}
