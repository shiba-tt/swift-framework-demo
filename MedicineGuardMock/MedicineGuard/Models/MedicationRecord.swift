import Foundation
import SwiftData

/// 服薬記録
@Model
final class MedicationRecord {
    var id: UUID
    /// 紐付く薬の ID
    var medicationID: UUID
    /// 薬の名前（スナップショット）
    var medicationName: String
    /// 用量（スナップショット）
    var dosage: String
    /// 予定時刻
    var scheduledTime: Date
    /// 実際の服薬時刻（nil = 未服薬）
    var takenAt: Date?
    /// 服薬済みか
    var isTaken: Bool
    /// スヌーズ回数
    var snoozeCount: Int

    init(
        id: UUID = UUID(),
        medicationID: UUID,
        medicationName: String,
        dosage: String,
        scheduledTime: Date
    ) {
        self.id = id
        self.medicationID = medicationID
        self.medicationName = medicationName
        self.dosage = dosage
        self.scheduledTime = scheduledTime
        self.isTaken = false
        self.snoozeCount = 0
    }

    /// 服薬済みとしてマーク
    func markAsTaken() {
        isTaken = true
        takenAt = .now
    }

    /// スヌーズ回数を増加
    func incrementSnooze() {
        snoozeCount += 1
    }

    /// 予定時刻からの遅延（分）
    var delayMinutes: Int? {
        guard let taken = takenAt else { return nil }
        let diff = taken.timeIntervalSince(scheduledTime)
        guard diff > 60 else { return 0 }
        return Int(diff / 60)
    }
}
