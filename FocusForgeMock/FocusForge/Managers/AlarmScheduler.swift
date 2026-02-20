import Foundation
import AlarmKit

/// AlarmKit を使ったポモドーロアラームのスケジューラー
@Observable
final class AlarmScheduler {
    static let shared = AlarmScheduler()

    private(set) var isAuthorized = false
    private(set) var currentAlarmID: UUID?

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
                print("[AlarmScheduler] 認可リクエスト失敗: \(error)")
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

    // MARK: - Schedule Pomodoro Alarm

    /// ポモドーロフェーズのアラームをスケジュール
    /// - Parameters:
    ///   - phase: 開始するフェーズ
    ///   - duration: フェーズの時間（秒）
    ///   - completedCount: 完了済みポモドーロ数
    ///   - dailyGoal: 1日の目標ポモドーロ数
    /// - Returns: スケジュールされたアラームのID
    @discardableResult
    func schedulePomodoro(
        phase: PomodoroPhase,
        duration: TimeInterval,
        completedCount: Int,
        dailyGoal: Int
    ) async throws -> UUID {
        let alarmID = UUID()

        // メタデータ
        let metadata = FocusForgeAlarmMetadata(
            phaseRawValue: phase.rawValue,
            completedCount: completedCount,
            dailyGoal: dailyGoal
        )

        // アラート表示設定
        let alertPresentation = makeAlertPresentation(for: phase, completedCount: completedCount)

        // カウントダウン設定（preAlert でフェーズの時間分カウントダウン）
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: duration,
            postAlert: nil
        )

        // アラーム属性
        let attributes = AlarmAttributes(metadata: metadata)

        // 設定を組み立て
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: nil,  // nil = 即時開始（カウントダウンタイマー）
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: .default
        )

        // スケジュール
        let alarm = try await AlarmManager.shared.schedule(
            id: alarmID,
            configuration: configuration
        )

        currentAlarmID = alarm.id
        print("[AlarmScheduler] アラームスケジュール完了: \(phase.label) (\(Int(duration / 60))分) ID=\(alarm.id)")
        return alarm.id
    }

    // MARK: - Control

    /// 現在のアラームを停止
    func stopCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.stop(id: alarmID)
        currentAlarmID = nil
        print("[AlarmScheduler] アラーム停止: \(alarmID)")
    }

    /// 現在のアラームをキャンセル
    func cancelCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.cancel(id: alarmID)
        currentAlarmID = nil
        print("[AlarmScheduler] アラームキャンセル: \(alarmID)")
    }

    /// カウントダウンを一時停止
    func pauseCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.pause(id: alarmID)
        print("[AlarmScheduler] アラーム一時停止: \(alarmID)")
    }

    /// カウントダウンを再開
    func resumeCurrent() async throws {
        guard let alarmID = currentAlarmID else { return }
        try await AlarmManager.shared.resume(id: alarmID)
        print("[AlarmScheduler] アラーム再開: \(alarmID)")
    }

    // MARK: - Alert Presentation

    /// フェーズに応じたアラートプレゼンテーションを生成
    private func makeAlertPresentation(
        for phase: PomodoroPhase,
        completedCount: Int
    ) -> AlarmPresentation.Alert {
        // 次のフェーズに応じたボタン設定
        switch phase {
        case .work:
            // 作業フェーズ完了 → 休憩開始ボタンを表示
            return AlarmPresentation.Alert(
                title: PomodoroPhase.shortBreak.alertTitle,
                stopButton: AlarmButton(
                    text: "休憩開始",
                    textColor: .white,
                    systemImageName: "cup.and.saucer.fill"
                ),
                secondaryButton: AlarmButton(
                    text: "スキップ",
                    textColor: .white,
                    systemImageName: "forward.fill"
                ),
                secondaryButtonBehavior: .dismiss
            )

        case .shortBreak, .longBreak:
            // 休憩フェーズ完了 → 作業開始ボタンを表示
            return AlarmPresentation.Alert(
                title: PomodoroPhase.work.alertTitle,
                stopButton: AlarmButton(
                    text: "作業開始",
                    textColor: .white,
                    systemImageName: "brain.head.profile"
                ),
                secondaryButton: AlarmButton(
                    text: "終了",
                    textColor: .white,
                    systemImageName: "stop.circle.fill"
                ),
                secondaryButtonBehavior: .dismiss
            )
        }
    }
}
