import Foundation

/// グリッド料金 × クリーン度の統合データ（EnergyKit 由来）
struct GridPriceData: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// クリーン度 (0.0〜1.0)
    let cleanFraction: Double
    /// TOU 料金レベル
    let priceLevel: PriceLevel
    /// 料金 ($/kWh)
    let ratePerKWh: Double

    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    var shortTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter.string(from: date)
    }

    /// コストとクリーン度の統合スコア（低い方が良い）
    var combinedScore: Double {
        // コスト(0〜1) と ダーティー度(0〜1) の加重平均
        let normalizedCost = ratePerKWh / 0.30 // ピーク料金で正規化
        let dirtyFraction = 1.0 - cleanFraction
        return normalizedCost * 0.6 + dirtyFraction * 0.4
    }
}
