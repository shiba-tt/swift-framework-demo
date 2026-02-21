import Foundation
import SwiftData

/// 睡眠記録データ
@Model
final class SleepRecord {
    /// 就寝時刻
    var bedtime: Date
    /// 起床時刻
    var wakeUpTime: Date
    /// 設定していた起床希望時刻
    var targetWakeUpTime: Date
    /// 実際にアラームが発火した時刻
    var alarmFiredTime: Date
    /// 睡眠スコア (0-100)
    var sleepScore: Int
    /// スマートアラームで起きたか（ウィンドウ内で浅い睡眠を検出して起きた場合 true）
    var wokeUpSmart: Bool
    /// 記録日
    var date: Date

    init(
        bedtime: Date,
        wakeUpTime: Date,
        targetWakeUpTime: Date,
        alarmFiredTime: Date,
        sleepScore: Int,
        wokeUpSmart: Bool,
        date: Date = .now
    ) {
        self.bedtime = bedtime
        self.wakeUpTime = wakeUpTime
        self.targetWakeUpTime = targetWakeUpTime
        self.alarmFiredTime = alarmFiredTime
        self.sleepScore = sleepScore
        self.wokeUpSmart = wokeUpSmart
        self.date = date
    }

    /// 睡眠時間（時間単位）
    var sleepDurationHours: Double {
        wakeUpTime.timeIntervalSince(bedtime) / 3600.0
    }

    /// ウィンドウ内で何分早く起きたか
    var minutesSavedBySmart: Int {
        guard wokeUpSmart else { return 0 }
        let diff = targetWakeUpTime.timeIntervalSince(alarmFiredTime)
        return max(0, Int(diff / 60))
    }
}
