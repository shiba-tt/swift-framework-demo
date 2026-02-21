import Foundation
import AlarmKit

/// AlarmKit を使ったルーティンアラームのスケジューラー
@Observable
final class RoutineAlarmScheduler {
    static let shared = RoutineAlarmScheduler()

    private(set) var isAuthorized = false
    private(set) var currentAlarmID: UUID?
    private(set) var currentStep: RoutineStep?

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
                print("[RoutineAlarmScheduler] 認可リクエスト失敗: \(error)")
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

    // MARK: - Schedule Step Alarm

    /// ルーティンステップのアラームをスケジュール
    /// - Parameters:
    ///   - step: スケジュールするステップ
    ///   - duration: カウントダウン時間（秒）。0 の場合は即時アラーム
    ///   - snoozeDuration: スヌーズ時間（秒）
    /// - Returns: スケジュールされたアラームの ID
    @discardableResult
    func scheduleStep(
        _ step: RoutineStep,
        duration: TimeInterval,
        snoozeDuration: TimeInterval
    ) async throws -> UUID {
        let alarmID = UUID()

        // メタデータ
        let metadata = RitualAlarmMetadata(
            stepRawValue: step.rawValue,
            totalSteps: RoutineStep.totalCount,
            currentStepIndex: step.index
        )

        // アラート表示設定
        let alertPresentation = makeAlertPresentation(for: step)

        // カウントダウン設定
        let countdownDuration: Alarm.CountdownDuration
        if step.isCountdown {
            // カウントダウンタイマー（ストレッチ、朝食準備、出発準備）
            countdownDuration = Alarm.CountdownDuration(
                preAlert: duration,
                postAlert: nil
            )
        } else {
            // 即時アラーム（起床、出発）— スヌーズ付き
            countdownDuration = Alarm.CountdownDuration(
                preAlert: nil,
                postAlert: snoozeDuration
            )
        }

        // アラーム属性
        let attributes = AlarmAttributes(metadata: metadata)

        // 設定の組み立て
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: nil,  // nil = 即時開始
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: .default
        )

        // スケジュール実行
        let alarm = try await AlarmManager.shared.schedule(
            id: alarmID,
            configuration: configuration
        )

        currentAlarmID = alarm.id
        currentStep = step
        print("[RoutineAlarmScheduler] ステップスケジュール完了: \(step.label) ID=\(alarm.id)")
        return alarm.id
    }

    // MARK: - Schedule Wake-Up Alarm (Fixed)

    /// 起床アラームを固定スケジュールでスケジュール（翌朝用）
    @discardableResult
    func scheduleWakeUp(
        at time: Date,
        snoozeDuration: TimeInterval
    ) async throws -> UUID {
        let alarmID = UUID()
        let step = RoutineStep.wakeUp

        let metadata = RitualAlarmMetadata(
            stepRawValue: step.rawValue,
            totalSteps: RoutineStep.totalCount,
            currentStepIndex: 0
        )

        let alertPresentation = makeAlertPresentation(for: step)

        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: snoozeDuration
        )

        let attributes = AlarmAttributes(metadata: metadata)

        let schedule = Alarm.Schedule.fixed(
            Alarm.Schedule.Fixed(date: time)
        )

        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: schedule,
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: .default
        )

        let alarm = try await AlarmManager.shared.schedule(
            id: alarmID,
            configuration: configuration
        )

        currentAlarmID = alarm.id
        currentStep = step
        print("[RoutineAlarmScheduler] 起床アラームスケジュール: \(time) ID=\(alarm.id)")
        return alarm.id
    }

    // MARK: - Control

    /// 現在のアラームを停止
    func stopCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.stop(id: alarmID)
        currentAlarmID = nil
        currentStep = nil
        print("[RoutineAlarmScheduler] アラーム停止: \(alarmID)")
    }

    /// 現在のアラームをキャンセル
    func cancelCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.cancel(id: alarmID)
        currentAlarmID = nil
        currentStep = nil
        print("[RoutineAlarmScheduler] アラームキャンセル: \(alarmID)")
    }

    /// カウントダウンを一時停止
    func pauseCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.pause(id: alarmID)
        print("[RoutineAlarmScheduler] アラーム一時停止: \(alarmID)")
    }

    /// カウントダウンを再開
    func resumeCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.resume(id: alarmID)
        print("[RoutineAlarmScheduler] アラーム再開: \(alarmID)")
    }

    // MARK: - Alert Presentation

    /// ステップに応じたアラートプレゼンテーションを生成
    private func makeAlertPresentation(for step: RoutineStep) -> AlarmPresentation.Alert {
        let hasNext = step.next != nil

        if hasNext {
            // 次のステップがある場合: Stop で次へ進む
            return AlarmPresentation.Alert(
                title: step.alertTitle,
                stopButton: AlarmButton(
                    text: step.stopButtonText,
                    textColor: .white,
                    systemImageName: "checkmark.circle.fill"
                ),
                secondaryButton: AlarmButton(
                    text: "スキップ",
                    textColor: .white,
                    systemImageName: "forward.fill"
                ),
                secondaryButtonBehavior: step.isCountdown ? .dismiss : .countdown
            )
        } else {
            // 最後のステップ（出発）
            return AlarmPresentation.Alert(
                title: step.alertTitle,
                stopButton: AlarmButton(
                    text: step.stopButtonText,
                    textColor: .white,
                    systemImageName: "door.left.hand.open"
                ),
                secondaryButton: AlarmButton(
                    text: "スヌーズ",
                    textColor: .white,
                    systemImageName: "zzz"
                ),
                secondaryButtonBehavior: .countdown
            )
        }
    }
}
