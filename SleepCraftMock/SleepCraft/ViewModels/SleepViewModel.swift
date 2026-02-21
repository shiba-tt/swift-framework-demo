import Foundation
import SwiftData
import SwiftUI

/// SleepCraft のメインビューモデル
@Observable
final class SleepViewModel {
    static let shared = SleepViewModel()

    private let scheduler = SleepAlarmScheduler.shared
    private let monitor = SleepMonitor.shared
    private var modelContext: ModelContext?

    // MARK: - State

    var settings = AlarmSettings.default
    var isAlarmActive = false
    var isSleeping = false

    var isAuthorized: Bool {
        scheduler.isAuthorized && monitor.isAuthorized
    }

    var currentPhase: SleepPhase {
        monitor.currentPhase
    }

    var sleepScore: Int {
        monitor.sleepScore
    }

    var phaseHistory: [(phase: SleepPhase, date: Date)] {
        monitor.phaseHistory
    }

    var themeColor: Color { .indigo }

    private init() {}

    // MARK: - Setup

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Authorization

    func requestAllAuthorizations() async {
        _ = await scheduler.requestAuthorization()
        _ = await monitor.requestAuthorization()
    }

    // MARK: - Alarm Actions

    /// アラームをセット（就寝時に呼ぶ）
    func setAlarm() async {
        do {
            try await scheduler.scheduleSmartAlarm(
                settings: settings,
                sleepScore: 0
            )
            isAlarmActive = true
            isSleeping = true
            monitor.startMonitoring()
            print("[SleepViewModel] アラームセット完了")
        } catch {
            print("[SleepViewModel] アラームセット失敗: \(error)")
        }
    }

    /// アラームをキャンセル
    func cancelAlarm() async {
        do {
            try await scheduler.cancelAll()
            isAlarmActive = false
            isSleeping = false
            monitor.stopMonitoring()
            print("[SleepViewModel] アラームキャンセル")
        } catch {
            print("[SleepViewModel] アラームキャンセル失敗: \(error)")
        }
    }

    /// 浅い睡眠を検知 → スマートアラーム発火
    func triggerSmartWakeUp() async {
        guard currentPhase.isSuitableForWakeUp else { return }

        do {
            try await scheduler.triggerSmartWakeUp(
                settings: settings,
                sleepScore: sleepScore,
                detectedPhase: currentPhase
            )
            print("[SleepViewModel] スマートアラーム発火")
        } catch {
            print("[SleepViewModel] スマートアラーム発火失敗: \(error)")
        }
    }

    /// 起床を記録
    func recordWakeUp(wokeUpSmart: Bool) {
        guard let modelContext else { return }

        let record = SleepRecord(
            bedtime: settings.smartWindowStart.addingTimeInterval(-6 * 3600),
            wakeUpTime: .now,
            targetWakeUpTime: settings.wakeUpTimeToday,
            alarmFiredTime: .now,
            sleepScore: sleepScore,
            wokeUpSmart: wokeUpSmart
        )

        modelContext.insert(record)
        isAlarmActive = false
        isSleeping = false
        monitor.stopMonitoring()
        print("[SleepViewModel] 起床記録完了: スコア=\(sleepScore)")
    }

    // MARK: - Settings Helpers

    var wakeUpTimeBinding: Binding<Date> {
        Binding(
            get: { self.settings.wakeUpTimeToday },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                self.settings.wakeUpHour = components.hour ?? 7
                self.settings.wakeUpMinute = components.minute ?? 0
            }
        )
    }
}
