import Foundation
import AlarmKit

/// AlarmKit を使ったスマートスリープアラームのスケジューラー
@Observable
final class SleepAlarmScheduler {
    static let shared = SleepAlarmScheduler()

    private(set) var isAuthorized = false
    private(set) var currentAlarmID: UUID?
    private(set) var fallbackAlarmID: UUID?

    private init() {}

    // MARK: - Authorization

    /// AlarmKit の認可を確認・リクエスト
    func requestAuthorization() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            do {
                let state = try await AlarmManager.shared.requestAuthorization()
                isAuthorized = state == .authorized
                return isAuthorized
            } catch {
                print("[SleepAlarmScheduler] 認可リクエスト失敗: \(error)")
                return false
            }
        case .authorized:
            isAuthorized = true
            return true
        case .denied:
            isAuthorized = false
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Schedule Smart Alarm

    /// スマートアラームをスケジュール（フォールバック付き）
    /// - Parameters:
    ///   - settings: アラーム設定
    ///   - sleepScore: 現在の睡眠スコア
    /// - Returns: フォールバックアラームの ID
    @discardableResult
    func scheduleSmartAlarm(
        settings: AlarmSettings,
        sleepScore: Int = 0
    ) async throws -> UUID {
        // フォールバックアラーム：ウィンドウ終了時刻（起床希望時刻）に確実にアラーム
        let fallbackID = UUID()

        let metadata = SleepCraftAlarmMetadata(
            targetWakeUpTimestamp: settings.wakeUpTimeToday.timeIntervalSince1970,
            windowStartTimestamp: settings.smartWindowStart.timeIntervalSince1970,
            sleepScore: sleepScore,
            isSmartWakeUp: false
        )

        let alertPresentation = AlarmPresentation.Alert(
            title: "おはようございます",
            stopButton: AlarmButton(
                text: "起きる",
                textColor: .white,
                systemImageName: "sun.max.fill"
            ),
            secondaryButton: AlarmButton(
                text: "スヌーズ",
                textColor: .white,
                systemImageName: "zzz"
            ),
            secondaryButtonBehavior: .countdown
        )

        let snoozeDuration = Double(settings.snoozeDurationMinutes) * 60
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: snoozeDuration
        )

        let attributes = AlarmAttributes(metadata: metadata)

        let schedule = Alarm.Schedule.fixed(
            Alarm.Schedule.Fixed(date: settings.wakeUpTimeToday)
        )

        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: schedule,
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: .default
        )

        let alarm = try await AlarmManager.shared.schedule(
            id: fallbackID,
            configuration: configuration
        )

        fallbackAlarmID = alarm.id
        print("[SleepAlarmScheduler] フォールバックアラームスケジュール: \(settings.wakeUpTimeToday) ID=\(alarm.id)")
        return alarm.id
    }

    // MARK: - Trigger Smart Wake-Up

    /// 浅い睡眠を検知した際にスマートアラームを即時発火
    /// フォールバックアラームをキャンセルし、即時アラームを再スケジュール
    @discardableResult
    func triggerSmartWakeUp(
        settings: AlarmSettings,
        sleepScore: Int,
        detectedPhase: SleepPhase
    ) async throws -> UUID {
        // フォールバックアラームをキャンセル
        if let fallbackID = fallbackAlarmID {
            try await AlarmManager.shared.cancel(id: fallbackID)
            self.fallbackAlarmID = nil
            print("[SleepAlarmScheduler] フォールバックアラームキャンセル: \(fallbackID)")
        }

        // スマートアラームを即時スケジュール
        let smartID = UUID()

        let metadata = SleepCraftAlarmMetadata(
            targetWakeUpTimestamp: settings.wakeUpTimeToday.timeIntervalSince1970,
            windowStartTimestamp: settings.smartWindowStart.timeIntervalSince1970,
            sleepScore: sleepScore,
            isSmartWakeUp: true
        )

        let alertPresentation = AlarmPresentation.Alert(
            title: "おはようございます",
            stopButton: AlarmButton(
                text: "起きる",
                textColor: .white,
                systemImageName: "sun.max.fill"
            ),
            secondaryButton: AlarmButton(
                text: "スヌーズ",
                textColor: .white,
                systemImageName: "zzz"
            ),
            secondaryButtonBehavior: .countdown
        )

        let snoozeDuration = Double(settings.snoozeDurationMinutes) * 60
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: snoozeDuration
        )

        let attributes = AlarmAttributes(metadata: metadata)

        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: nil, // 即時発火
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: .default
        )

        let alarm = try await AlarmManager.shared.schedule(
            id: smartID,
            configuration: configuration
        )

        currentAlarmID = alarm.id
        print("[SleepAlarmScheduler] スマートアラーム発火: \(detectedPhase.label) 睡眠スコア=\(sleepScore) ID=\(alarm.id)")
        return alarm.id
    }

    // MARK: - Control

    /// 現在のアラームを停止
    func stopCurrent() async throws {
        if let alarmID = currentAlarmID {
            try await AlarmManager.shared.stop(id: alarmID)
            currentAlarmID = nil
        }
        if let fallbackID = fallbackAlarmID {
            try await AlarmManager.shared.cancel(id: fallbackID)
            fallbackAlarmID = nil
        }
        print("[SleepAlarmScheduler] アラーム停止")
    }

    /// すべてのアラームをキャンセル
    func cancelAll() async throws {
        if let alarmID = currentAlarmID {
            try await AlarmManager.shared.cancel(id: alarmID)
            currentAlarmID = nil
        }
        if let fallbackID = fallbackAlarmID {
            try await AlarmManager.shared.cancel(id: fallbackID)
            fallbackAlarmID = nil
        }
        print("[SleepAlarmScheduler] 全アラームキャンセル")
    }
}
