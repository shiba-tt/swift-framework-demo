import Foundation
import AlarmKit

/// AlarmKit を使った服薬アラームのスケジューラー
@Observable
final class MedicationAlarmScheduler {
    static let shared = MedicationAlarmScheduler()

    private(set) var isAuthorized = false
    /// アクティブなアラーム ID のマッピング（薬 ID → アラーム ID）
    private(set) var activeAlarms: [UUID: UUID] = [:]

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
                print("[MedicationAlarmScheduler] 認可リクエスト失敗: \(error)")
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

    // MARK: - Schedule Medication Alarm

    /// 服薬アラームを相対スケジュールでスケジュール（毎日繰り返し）
    @discardableResult
    func scheduleDailyAlarm(for medication: Medication) async throws -> UUID {
        let alarmID = UUID()

        let metadata = MedicineAlarmMetadata(
            medicationName: medication.name,
            dosage: medication.dosage,
            categoryRawValue: medication.categoryRawValue,
            scheduleDescription: medication.scheduleDescription
        )

        let alertPresentation = makeAlertPresentation(for: medication)

        // スヌーズ用の postAlert
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: medication.snoozeDuration
        )

        let attributes = AlarmAttributes(metadata: metadata)

        // 相対スケジュール: 毎日指定時刻
        let schedule = Alarm.Schedule.relative(
            Alarm.Schedule.Relative(
                time: Alarm.Schedule.Relative.Time(
                    hour: medication.scheduleHour,
                    minute: medication.scheduleMinute
                ),
                repeats: .daily
            )
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

        activeAlarms[medication.id] = alarm.id
        print("[MedicationAlarmScheduler] 毎日アラームスケジュール: \(medication.name) \(medication.scheduleTimeText) ID=\(alarm.id)")
        return alarm.id
    }

    /// 服薬アラームを相対スケジュールでスケジュール（毎週指定曜日）
    @discardableResult
    func scheduleWeeklyAlarm(for medication: Medication) async throws -> UUID {
        let alarmID = UUID()

        let metadata = MedicineAlarmMetadata(
            medicationName: medication.name,
            dosage: medication.dosage,
            categoryRawValue: medication.categoryRawValue,
            scheduleDescription: medication.scheduleDescription
        )

        let alertPresentation = makeAlertPresentation(for: medication)

        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: medication.snoozeDuration
        )

        let attributes = AlarmAttributes(metadata: metadata)

        // 曜日の変換
        let weekdays: [Alarm.Schedule.Relative.Weekday] = medication.repeatDaysRawValues.compactMap { rawValue in
            switch rawValue {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: return nil
            }
        }

        let schedule = Alarm.Schedule.relative(
            Alarm.Schedule.Relative(
                time: Alarm.Schedule.Relative.Time(
                    hour: medication.scheduleHour,
                    minute: medication.scheduleMinute
                ),
                repeats: .weekly(weekdays)
            )
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

        activeAlarms[medication.id] = alarm.id
        print("[MedicationAlarmScheduler] 週次アラームスケジュール: \(medication.name) ID=\(alarm.id)")
        return alarm.id
    }

    /// 薬に応じたアラームをスケジュール
    @discardableResult
    func scheduleAlarm(for medication: Medication) async throws -> UUID {
        switch medication.scheduleType {
        case .daily:
            return try await scheduleDailyAlarm(for: medication)
        case .weekly:
            return try await scheduleWeeklyAlarm(for: medication)
        }
    }

    // MARK: - Control

    /// 特定の薬のアラームをキャンセル
    func cancelAlarm(for medicationID: UUID) async throws {
        guard let alarmID = activeAlarms[medicationID] else { return }
        try await AlarmManager.shared.cancel(id: alarmID)
        activeAlarms.removeValue(forKey: medicationID)
        print("[MedicationAlarmScheduler] アラームキャンセル: \(alarmID)")
    }

    /// すべてのアラームをキャンセル
    func cancelAll() async {
        for (medicationID, alarmID) in activeAlarms {
            do {
                try await AlarmManager.shared.cancel(id: alarmID)
                print("[MedicationAlarmScheduler] アラームキャンセル: \(alarmID)")
            } catch {
                print("[MedicationAlarmScheduler] キャンセル失敗: \(medicationID) - \(error)")
            }
        }
        activeAlarms.removeAll()
    }

    // MARK: - Alert Presentation

    /// 服薬アラートプレゼンテーションを生成
    private func makeAlertPresentation(for medication: Medication) -> AlarmPresentation.Alert {
        AlarmPresentation.Alert(
            title: "💊 \(medication.name)の時間です",
            stopButton: AlarmButton(
                text: "服用済み",
                textColor: .white,
                systemImageName: "checkmark.circle.fill"
            ),
            secondaryButton: AlarmButton(
                text: "\(Int(medication.snoozeDuration / 60))分後",
                textColor: .white,
                systemImageName: "clock.badge.fill"
            ),
            secondaryButtonBehavior: .countdown
        )
    }
}
