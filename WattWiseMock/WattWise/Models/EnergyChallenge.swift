import Foundation
import SwiftUI

/// 節電チャレンジモデル
struct EnergyChallenge: Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let targetReduction: Double
    let durationDays: Int
    let startDate: Date
    var currentProgress: Double
    let icon: String

    var remainingDays: Int {
        let endDate = Calendar.current.date(byAdding: .day, value: durationDays, to: startDate) ?? startDate
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, remaining)
    }

    var isCompleted: Bool {
        currentProgress >= 1.0
    }

    var progressPercent: Int {
        Int(currentProgress * 100)
    }
}

/// 日別インサイト
struct DailyInsight: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let co2Reduction: Double
    let costSaving: Double
    let cleanRate: Double
    let comparedToLastWeek: Double
}

/// 週間レポート
struct WeeklyReport: Identifiable, Sendable {
    let id: UUID
    let weekNumber: Int
    let totalCO2Reduction: Double
    let totalCostSaving: Double
    let averageCleanRate: Double
    let dailyCleanRates: [Double]
    let challengeAchieved: Bool
}

/// グリッド時間帯情報
struct GridTimeSlot: Identifiable, Sendable {
    let id: UUID
    let hour: Int
    let cleanLevel: CleanLevel
    let cost: CostLevel

    var timeLabel: String {
        "\(hour):00"
    }
}

/// クリーン度レベル
enum CleanLevel: Sendable {
    case veryClean
    case clean
    case moderate
    case dirty

    var color: Color {
        switch self {
        case .veryClean: .green
        case .clean: .mint
        case .moderate: .yellow
        case .dirty: .red
        }
    }

    var emoji: String {
        switch self {
        case .veryClean: "🟢"
        case .clean: "🟢"
        case .moderate: "🟡"
        case .dirty: "🔴"
        }
    }

    var label: String {
        switch self {
        case .veryClean: "非常にクリーン"
        case .clean: "クリーン"
        case .moderate: "普通"
        case .dirty: "ピーク"
        }
    }
}

/// コストレベル
enum CostLevel: Sendable {
    case low
    case medium
    case high
    case peak

    var emoji: String {
        switch self {
        case .low: "💰"
        case .medium: "💰💰"
        case .high: "💲💲"
        case .peak: "💲💲💲"
        }
    }
}
