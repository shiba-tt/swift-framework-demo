import Foundation

/// HVAC 運転プランの1スロット
struct OperationSlot: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    /// 目標温度 (°C)
    let targetTemperature: Double
    /// 運転モード
    let mode: OperationMode
    /// グリッドのクリーン度
    let cleanFraction: Double
    /// TOU 料金レベル
    let priceLevel: PriceLevel

    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate))〜\(formatter.string(from: endDate))"
    }

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }
}

/// HVAC 運転モード
enum OperationMode: String, Sendable, CaseIterable {
    case preHeat = "事前暖房"
    case preCool = "事前冷房"
    case normal = "通常運転"
    case passive = "パッシブ維持"
    case off = "OFF"

    var systemImageName: String {
        switch self {
        case .preHeat: "flame.fill"
        case .preCool: "snowflake"
        case .normal: "air.conditioner.horizontal.fill"
        case .passive: "pause.circle.fill"
        case .off: "power"
        }
    }

    var badgeColor: String {
        switch self {
        case .preHeat: "orange"
        case .preCool: "cyan"
        case .normal: "green"
        case .passive: "yellow"
        case .off: "red"
        }
    }
}

/// TOU 料金レベル
enum PriceLevel: String, Sendable, CaseIterable {
    case offPeak = "オフピーク"
    case midPeak = "ミッドピーク"
    case onPeak = "ピーク"

    var systemImageName: String {
        switch self {
        case .offPeak: "dollarsign.circle.fill"
        case .midPeak: "dollarsign.circle.fill"
        case .onPeak: "dollarsign.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .offPeak: "green"
        case .midPeak: "yellow"
        case .onPeak: "red"
        }
    }

    /// 概算料金（$/kWh）
    var ratePerKWh: Double {
        switch self {
        case .offPeak: 0.08
        case .midPeak: 0.15
        case .onPeak: 0.30
        }
    }
}

/// 1日の運転プラン全体
struct DailyOperationPlan: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let slots: [OperationSlot]
    /// 予測節約額
    let estimatedSavings: Double
    /// 快適度スコア (0〜100)
    let comfortScore: Int
    /// 予測消費電力 (kWh)
    let estimatedEnergyKWh: Double
}
