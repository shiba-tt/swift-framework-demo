import Foundation
import SwiftUI
import SwiftData

/// 服薬管理の中心的な ViewModel
@MainActor
@Observable
final class MedicationViewModel {
    // MARK: - Singleton (AppIntents からのアクセス用)

    static let shared = MedicationViewModel()

    // MARK: - State

    /// 登録済みの薬一覧
    private(set) var medications: [Medication] = []
    /// 今日の服薬記録
    private(set) var todayRecords: [MedicationRecord] = []
    /// 連続服薬日数
    private(set) var streakDays: Int = 0
    /// 現在アラート中の薬 ID
    private(set) var currentAlertingMedicationID: UUID?

    // MARK: - Dependencies

    private let alarmScheduler = MedicationAlarmScheduler.shared
    private var modelContext: ModelContext?

    // MARK: - Computed

    /// 今日の服薬率（%）
    var todayAdherenceRate: Int {
        guard !medications.isEmpty else { return 0 }
        let activeMeds = medications.filter(\.isActive)
        guard !activeMeds.isEmpty else { return 0 }
        let taken = todayRecords.filter(\.isTaken).count
        return Int(Double(taken) / Double(activeMeds.count) * 100)
    }

    /// 今日の服薬済み数
    var todayTakenCount: Int {
        todayRecords.filter(\.isTaken).count
    }

    /// 今日の服薬予定数
    var todayScheduledCount: Int {
        medications.filter(\.isActive).count
    }

    /// 次の服薬予定
    var nextScheduledMedication: Medication? {
        let now = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let currentMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)

        return medications
            .filter(\.isActive)
            .filter { med in
                let medMinutes = med.scheduleHour * 60 + med.scheduleMinute
                return medMinutes > currentMinutes
            }
            .min { a, b in
                let aMin = a.scheduleHour * 60 + a.scheduleMinute
                let bMin = b.scheduleHour * 60 + b.scheduleMinute
                return aMin < bMin
            }
    }

    // MARK: - Setup

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadMedications()
        loadTodayRecords()
        calculateStreak()
    }

    // MARK: - Medication CRUD

    /// 薬を追加
    func addMedication(_ medication: Medication) async {
        modelContext?.insert(medication)
        try? modelContext?.save()
        medications.append(medication)

        // アラームをスケジュール
        guard await alarmScheduler.requestAuthorization() else {
            print("[MedicationVM] AlarmKit 認可なし")
            return
        }

        do {
            try await alarmScheduler.scheduleAlarm(for: medication)
        } catch {
            print("[MedicationVM] アラームスケジュール失敗: \(error)")
        }

        // 今日の記録を作成
        createTodayRecord(for: medication)
    }

    /// 薬を削除
    func deleteMedication(_ medication: Medication) async {
        do {
            try await alarmScheduler.cancelAlarm(for: medication.id)
        } catch {
            print("[MedicationVM] アラームキャンセル失敗: \(error)")
        }

        modelContext?.delete(medication)
        try? modelContext?.save()
        medications.removeAll { $0.id == medication.id }
    }

    /// 薬の有効/無効を切り替え
    func toggleMedication(_ medication: Medication) async {
        medication.isActive.toggle()
        try? modelContext?.save()

        if medication.isActive {
            guard await alarmScheduler.requestAuthorization() else { return }
            do {
                try await alarmScheduler.scheduleAlarm(for: medication)
            } catch {
                print("[MedicationVM] アラームスケジュール失敗: \(error)")
            }
        } else {
            do {
                try await alarmScheduler.cancelAlarm(for: medication.id)
            } catch {
                print("[MedicationVM] アラームキャンセル失敗: \(error)")
            }
        }
    }

    // MARK: - Recording

    /// 現在アラート中の薬を服薬済みとして記録
    func recordCurrentMedicationTaken() {
        guard let medicationID = currentAlertingMedicationID,
              let record = todayRecords.first(where: { $0.medicationID == medicationID && !$0.isTaken }) else {
            // アラート中の薬が特定できない場合、直近の未服薬記録を更新
            if let record = todayRecords.first(where: { !$0.isTaken }) {
                record.markAsTaken()
                try? modelContext?.save()
            }
            return
        }

        record.markAsTaken()
        try? modelContext?.save()
        currentAlertingMedicationID = nil
        calculateStreak()
        print("[MedicationVM] 服薬記録: \(record.medicationName)")
    }

    /// 特定の薬を服薬済みとして記録
    func recordMedicationTaken(_ medicationID: UUID) {
        guard let record = todayRecords.first(where: { $0.medicationID == medicationID && !$0.isTaken }) else {
            return
        }

        record.markAsTaken()
        try? modelContext?.save()
        calculateStreak()
    }

    /// 現在アラート中の薬をスヌーズ
    func snoozeCurrentMedication() {
        guard let medicationID = currentAlertingMedicationID,
              let record = todayRecords.first(where: { $0.medicationID == medicationID && !$0.isTaken }) else {
            if let record = todayRecords.first(where: { !$0.isTaken }) {
                record.incrementSnooze()
                try? modelContext?.save()
            }
            return
        }

        record.incrementSnooze()
        try? modelContext?.save()
        currentAlertingMedicationID = nil
        print("[MedicationVM] スヌーズ: \(record.medicationName) (\(record.snoozeCount)回目)")
    }

    /// すべてのアクティブな薬のアラームをスケジュール
    func scheduleAllAlarms() async {
        guard await alarmScheduler.requestAuthorization() else {
            print("[MedicationVM] AlarmKit 認可なし")
            return
        }

        for medication in medications where medication.isActive {
            do {
                try await alarmScheduler.scheduleAlarm(for: medication)
            } catch {
                print("[MedicationVM] アラームスケジュール失敗: \(medication.name) - \(error)")
            }
        }
    }

    // MARK: - Private

    /// 薬一覧をロード
    private func loadMedications() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.scheduleHour), SortDescriptor(\.scheduleMinute)]
        )

        do {
            medications = try modelContext.fetch(descriptor)
        } catch {
            print("[MedicationVM] 薬一覧ロード失敗: \(error)")
        }
    }

    /// 今日の服薬記録をロード
    private func loadTodayRecords() {
        guard let modelContext else { return }

        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<MedicationRecord> { record in
            record.scheduledTime >= startOfDay
        }
        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledTime)]
        )

        do {
            todayRecords = try modelContext.fetch(descriptor)
        } catch {
            print("[MedicationVM] 記録ロード失敗: \(error)")
        }

        // 今日の記録がまだない薬があれば作成
        for medication in medications where medication.isActive {
            if !todayRecords.contains(where: { $0.medicationID == medication.id }) {
                createTodayRecord(for: medication)
            }
        }
    }

    /// 今日の服薬記録を作成
    private func createTodayRecord(for medication: Medication) {
        guard let modelContext else { return }

        let calendar = Calendar.current
        let scheduledTime = calendar.date(
            bySettingHour: medication.scheduleHour,
            minute: medication.scheduleMinute,
            second: 0,
            of: .now
        ) ?? .now

        let record = MedicationRecord(
            medicationID: medication.id,
            medicationName: medication.name,
            dosage: medication.dosage,
            scheduledTime: scheduledTime
        )

        modelContext.insert(record)
        try? modelContext.save()
        todayRecords.append(record)
    }

    /// 連続服薬日数を計算
    private func calculateStreak() {
        guard let modelContext else { return }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
            let predicate = #Predicate<MedicationRecord> { record in
                record.scheduledTime >= checkDate && record.scheduledTime < nextDay
            }
            let descriptor = FetchDescriptor<MedicationRecord>(predicate: predicate)

            do {
                let records = try modelContext.fetch(descriptor)
                if records.isEmpty { break }
                let allTaken = records.allSatisfy(\.isTaken)
                if !allTaken && checkDate < calendar.startOfDay(for: .now) {
                    break
                }
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } catch {
                break
            }
        }

        streakDays = streak
    }
}
