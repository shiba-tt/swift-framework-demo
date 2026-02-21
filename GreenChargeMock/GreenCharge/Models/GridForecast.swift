import Foundation

/// グリッドの予測データ（EnergyKit の ElectricityGuidance 由来）
struct GridForecast: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// クリーン度（0.0〜1.0）
    let cleanEnergyFraction: Double
    /// ガイダンスレベル
    let guidanceLevel: GuidanceLevel

    /// 時刻の表示テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// 短い時刻テキスト
    var shortTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter.string(from: date)
    }

    /// クリーン度のパーセント表示
    var cleanPercentText: String {
        "\(Int(cleanEnergyFraction * 100))%"
    }
}

/// EnergyKit の ElectricityGuidanceLevel に対応
enum GuidanceLevel: String, Sendable, CaseIterable {
    case good = "推奨"
    case neutral = "普通"
    case bad = "非推奨"

    var systemImageName: String {
        switch self {
        case .good: "checkmark.circle.fill"
        case .neutral: "minus.circle.fill"
        case .bad: "xmark.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .good: "green"
        case .neutral: "yellow"
        case .bad: "red"
        }
    }
}

/// クリーンエネルギーの窓（充電推奨時間帯）
struct CleanWindow: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let averageCleanFraction: Double

    /// 時間帯の表示テキスト
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate))〜\(formatter.string(from: endDate))"
    }

    /// 期間（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 期間の表示テキスト
    var durationText: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)時間\(mins)分" : "\(hours)時間"
        }
        return "\(mins)分"
    }
}
