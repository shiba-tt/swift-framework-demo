import Foundation

/// 充電セッション
struct ChargingSession: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date?
    /// 充電量 (kWh)
    let energyKWh: Double
    /// セッション中の平均クリーン度
    let averageCleanFraction: Double
    /// ステータス
    let status: ChargingStatus
    /// 獲得ポイント
    let earnedPoints: Int

    /// クリーン度のパーセント表示
    var cleanPercentText: String {
        "\(Int(averageCleanFraction * 100))%"
    }

    /// 充電量の表示テキスト
    var energyText: String {
        String(format: "%.1f kWh", energyKWh)
    }

    /// CO2 削減量の概算（kg）
    var estimatedCO2Savings: Double {
        // クリーン充電分のCO2削減を概算（0.4 kg CO2/kWh が火力のベースライン）
        energyKWh * averageCleanFraction * 0.4
    }
}

/// 充電ステータス
enum ChargingStatus: String, Sendable {
    case scheduled = "予約済み"
    case charging = "充電中"
    case completed = "完了"
    case cancelled = "キャンセル"

    var systemImageName: String {
        switch self {
        case .scheduled: "calendar.badge.clock"
        case .charging: "bolt.fill"
        case .completed: "checkmark.circle.fill"
        case .cancelled: "xmark.circle.fill"
        }
    }
}

/// スマート充電プラン
struct SmartChargePlan: Identifiable, Sendable {
    let id = UUID()
    /// 充電スロット
    let slots: [ChargeSlot]
    /// 出発予定時刻
    let departureDate: Date
    /// 目標充電率（0.0〜1.0）
    let targetChargeLevel: Double
    /// 予測獲得ポイント
    let estimatedPoints: Int
    /// 予測コスト削減額（ドル）
    let estimatedCostSaving: Double
    /// 予測 CO2 削減量（kg）
    let estimatedCO2Saving: Double
}

/// 充電スロット（プラン内の個別充電区間）
struct ChargeSlot: Identifiable, Sendable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let cleanFraction: Double
    let action: SlotAction

    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate))〜\(formatter.string(from: endDate))"
    }
}

/// スロットのアクション
enum SlotAction: String, Sendable {
    case charge = "充電"
    case wait = "待機"

    var systemImageName: String {
        switch self {
        case .charge: "bolt.fill"
        case .wait: "pause.fill"
        }
    }
}
