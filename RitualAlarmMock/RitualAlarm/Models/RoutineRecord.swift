import Foundation
import SwiftData

/// ルーティン実行記録
@Model
final class RoutineRecord {
    var id: UUID
    /// ルーティンの日付
    var date: Date
    /// 各ステップの完了状況
    var completedSteps: [String]  // RoutineStep.rawValue の配列
    /// ルーティン全体が完了したか
    var isFullyCompleted: Bool
    /// 起床アラーム設定時刻
    var scheduledWakeUpTime: Date
    /// 実際の起床時刻（Stop ボタンタップ時刻）
    var actualWakeUpTime: Date?
    /// 出発時刻
    var departureTime: Date?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        scheduledWakeUpTime: Date
    ) {
        self.id = id
        self.date = date
        self.completedSteps = []
        self.isFullyCompleted = false
        self.scheduledWakeUpTime = scheduledWakeUpTime
    }

    /// ステップを完了として記録
    func markStepCompleted(_ step: RoutineStep) {
        if !completedSteps.contains(step.rawValue) {
            completedSteps.append(step.rawValue)
        }
        if step == .wakeUp {
            actualWakeUpTime = .now
        }
        if step == .departure {
            departureTime = .now
            isFullyCompleted = true
        }
    }

    /// 完了したステップ数
    var completedStepCount: Int {
        completedSteps.count
    }

    /// スヌーズ回数（起床アラーム設定時刻と実際の起床時刻の差から推定）
    var estimatedSnoozeCount: Int {
        guard let actual = actualWakeUpTime else { return 0 }
        let diff = actual.timeIntervalSince(scheduledWakeUpTime)
        guard diff > 60 else { return 0 }  // 1分未満は誤差
        return Int(diff / (5 * 60))  // 5分スヌーズで概算
    }
}
