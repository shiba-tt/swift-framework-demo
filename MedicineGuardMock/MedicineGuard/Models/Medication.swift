import Foundation
import SwiftData

/// 薬の情報モデル
@Model
final class Medication {
    var id: UUID
    /// 薬の名前
    var name: String
    /// 用量（例: "5mg"）
    var dosage: String
    /// 服用カテゴリ
    var categoryRawValue: String
    /// アラームスケジュール種別
    var scheduleTypeRawValue: String
    /// 服用時刻（時）
    var scheduleHour: Int
    /// 服用時刻（分）
    var scheduleMinute: Int
    /// 繰り返し曜日（weekly の場合のみ使用）
    var repeatDaysRawValues: [Int]
    /// メモ
    var notes: String
    /// 有効/無効
    var isActive: Bool
    /// 作成日時
    var createdAt: Date
    /// スヌーズ時間（秒）
    var snoozeDuration: TimeInterval

    init(
        id: UUID = UUID(),
        name: String,
        dosage: String,
        category: MedicationCategory = .prescription,
        scheduleType: MedicationScheduleType = .daily,
        scheduleHour: Int = 8,
        scheduleMinute: Int = 0,
        repeatDays: [Int] = [],
        notes: String = "",
        snoozeDuration: TimeInterval = 30 * 60
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.categoryRawValue = category.rawValue
        self.scheduleTypeRawValue = scheduleType.rawValue
        self.scheduleHour = scheduleHour
        self.scheduleMinute = scheduleMinute
        self.repeatDaysRawValues = repeatDays
        self.notes = notes
        self.isActive = true
        self.createdAt = .now
        self.snoozeDuration = snoozeDuration
    }

    var category: MedicationCategory {
        MedicationCategory(rawValue: categoryRawValue) ?? .prescription
    }

    var scheduleType: MedicationScheduleType {
        MedicationScheduleType(rawValue: scheduleTypeRawValue) ?? .daily
    }

    /// 服用時刻の表示文字列
    var scheduleTimeText: String {
        String(format: "%02d:%02d", scheduleHour, scheduleMinute)
    }

    /// スケジュールの説明文
    var scheduleDescription: String {
        switch scheduleType {
        case .daily:
            return "毎日 \(scheduleTimeText)"
        case .weekly:
            let dayNames = repeatDaysRawValues
                .sorted()
                .compactMap { MedicationWeekday(rawValue: $0)?.shortLabel }
                .joined(separator: "・")
            return "毎週 \(dayNames) \(scheduleTimeText)"
        }
    }
}

/// 薬のカテゴリ
enum MedicationCategory: String, Codable, Sendable, CaseIterable, Identifiable {
    case prescription       // 処方薬
    case overTheCounter     // 市販薬
    case supplement         // サプリメント
    case vitamin            // ビタミン

    var id: String { rawValue }

    var label: String {
        switch self {
        case .prescription: "処方薬"
        case .overTheCounter: "市販薬"
        case .supplement: "サプリメント"
        case .vitamin: "ビタミン"
        }
    }

    var systemImageName: String {
        switch self {
        case .prescription: "cross.case.fill"
        case .overTheCounter: "pills.fill"
        case .supplement: "leaf.fill"
        case .vitamin: "drop.fill"
        }
    }

    var emoji: String {
        switch self {
        case .prescription: "💊"
        case .overTheCounter: "💉"
        case .supplement: "🌿"
        case .vitamin: "🫧"
        }
    }
}
