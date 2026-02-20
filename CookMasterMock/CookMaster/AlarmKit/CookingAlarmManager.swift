import AlarmKit
import Foundation

// MARK: - 料理アラームマネージャー

/// AlarmKit をラップして料理タイマーのスケジュール・管理を行うマネージャー
@MainActor
final class CookingAlarmManager: ObservableObject {
    static let shared = CookingAlarmManager()

    @Published var isAuthorized = false

    private init() {}

    // MARK: - 認可

    /// AlarmKit の認可状態を確認・リクエスト
    func requestAuthorization() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            do {
                let state = try await AlarmManager.shared.requestAuthorization()
                isAuthorized = state == .authorized
                return isAuthorized
            } catch {
                print("[CookMaster] 認可リクエスト失敗: \(error)")
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

    // MARK: - タイマースケジュール

    /// 料理タイマーを AlarmKit でスケジュール
    /// - Parameter timer: スケジュールする CookingTimer
    /// - Returns: スケジュール済みの Alarm オブジェクト
    @discardableResult
    func scheduleTimer(_ timer: CookingTimer) async throws -> Alarm {
        let metadata = CookingAlarmMetadata(
            timerName: timer.name,
            category: timer.category
        )

        // アラート表示の設定
        let alertPresentation = AlarmPresentation.Alert(
            title: "\(timer.category.emoji) \(timer.name)が完了しました!",
            stopButton: AlarmButton(
                text: "完了",
                textColor: .white,
                systemImageName: "checkmark.circle.fill"
            ),
            secondaryButton: AlarmButton(
                text: "+1分追加",
                textColor: .white,
                systemImageName: "plus.circle.fill"
            ),
            secondaryButtonBehavior: .countdown  // +1分追加 → postAlert カウントダウン再開
        )

        // カウントダウン設定
        // preAlert: メインのカウントダウン時間（タイマー本体）
        // postAlert: +1分追加時のスヌーズカウントダウン
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: timer.duration,
            postAlert: TimeInterval(60)  // +1分追加のデフォルト
        )

        // アラーム属性
        let attributes = AlarmAttributes(metadata: metadata)

        // サウンド設定
        let sound: AlarmManager.AlarmConfiguration.Sound
        if let soundName = timer.soundName {
            sound = .named(soundName)
        } else {
            sound = .default
        }

        // AlarmConfiguration の組み立て
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: nil,  // nil = 即時開始のカウントダウンタイマー
            attributes: attributes,
            presentation: AlarmPresentation(alert: alertPresentation),
            sound: sound
        )

        // スケジュール実行
        let alarm = try await AlarmManager.shared.schedule(
            id: timer.id,
            configuration: configuration
        )

        print("[CookMaster] タイマーをスケジュール: \(timer.name) (\(timer.id))")
        return alarm
    }

    // MARK: - タイマー操作

    /// タイマーを一時停止
    func pauseTimer(id: UUID) async {
        do {
            try await AlarmManager.shared.pause(id: id)
            print("[CookMaster] タイマーを一時停止: \(id)")
        } catch {
            print("[CookMaster] 一時停止失敗: \(error)")
        }
    }

    /// タイマーを再開
    func resumeTimer(id: UUID) async {
        do {
            try await AlarmManager.shared.resume(id: id)
            print("[CookMaster] タイマーを再開: \(id)")
        } catch {
            print("[CookMaster] 再開失敗: \(error)")
        }
    }

    /// タイマーを停止（完了）
    func stopTimer(id: UUID) async {
        do {
            try await AlarmManager.shared.stop(id: id)
            print("[CookMaster] タイマーを停止: \(id)")
        } catch {
            print("[CookMaster] 停止失敗: \(error)")
        }
    }

    /// タイマーをキャンセル
    func cancelTimer(id: UUID) async {
        do {
            try await AlarmManager.shared.cancel(id: id)
            print("[CookMaster] タイマーをキャンセル: \(id)")
        } catch {
            print("[CookMaster] キャンセル失敗: \(error)")
        }
    }

    /// タイマーに時間を追加（再スケジュール）
    func extendTimer(id: UUID, additionalSeconds: TimeInterval) async {
        do {
            // 現在のタイマーを停止して新しいタイマーとして再スケジュール
            try await AlarmManager.shared.stop(id: id)

            // 延長用の新しい設定で再スケジュール
            let metadata = CookingAlarmMetadata(
                timerName: "+\(Int(additionalSeconds / 60))分延長",
                category: .custom
            )

            let alertPresentation = AlarmPresentation.Alert(
                title: "延長タイマーが完了しました!",
                stopButton: AlarmButton(
                    text: "完了",
                    textColor: .white,
                    systemImageName: "checkmark.circle.fill"
                ),
                secondaryButton: AlarmButton(
                    text: "+1分追加",
                    textColor: .white,
                    systemImageName: "plus.circle.fill"
                ),
                secondaryButtonBehavior: .countdown
            )

            let countdownDuration = Alarm.CountdownDuration(
                preAlert: additionalSeconds,
                postAlert: TimeInterval(60)
            )

            let configuration = AlarmManager.AlarmConfiguration(
                countdownDuration: countdownDuration,
                schedule: nil,
                attributes: AlarmAttributes(metadata: metadata),
                presentation: AlarmPresentation(alert: alertPresentation),
                sound: .default
            )

            try await AlarmManager.shared.schedule(
                id: id,
                configuration: configuration
            )

            print("[CookMaster] タイマーを\(Int(additionalSeconds))秒延長: \(id)")
        } catch {
            print("[CookMaster] 延長失敗: \(error)")
        }
    }

    // MARK: - アラーム監視

    /// アクティブなアラーム一覧を監視する AsyncSequence
    var activeAlarms: AlarmManager.Alarms {
        AlarmManager.shared.alarms
    }
}
