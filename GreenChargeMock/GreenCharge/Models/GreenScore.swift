import Foundation

/// ゲーミフィケーションスコア
struct GreenScore: Sendable {
    /// 累計ポイント
    let totalPoints: Int
    /// 今月のポイント
    let monthlyPoints: Int
    /// クリーン充電率（0.0〜1.0）
    let cleanChargeRate: Double
    /// 累計 CO2 削減量（kg）
    let totalCO2Savings: Double
    /// ランキング順位
    let rank: Int
    /// ランキング参加者数
    let totalParticipants: Int
    /// 現在のレベル
    var level: GreenLevel {
        GreenLevel.from(points: totalPoints)
    }

    /// クリーン率のテキスト
    var cleanRateText: String {
        "\(Int(cleanChargeRate * 100))%"
    }

    /// CO2 削減のテキスト
    var co2Text: String {
        String(format: "%.1f kg", totalCO2Savings)
    }

    /// ランキングのテキスト
    var rankText: String {
        "#\(rank) / \(totalParticipants)人"
    }
}

/// グリーンレベル
enum GreenLevel: String, Sendable, CaseIterable {
    case seedling = "シードリング"
    case sprout = "スプラウト"
    case tree = "ツリー"
    case forest = "フォレスト"
    case earth = "アース"

    static func from(points: Int) -> GreenLevel {
        switch points {
        case 5000...: .earth
        case 2500..<5000: .forest
        case 1000..<2500: .tree
        case 300..<1000: .sprout
        default: .seedling
        }
    }

    var systemImageName: String {
        switch self {
        case .seedling: "leaf.fill"
        case .sprout: "leaf.arrow.circlepath"
        case .tree: "tree.fill"
        case .forest: "tree.fill"
        case .earth: "globe.americas.fill"
        }
    }

    var nextLevel: GreenLevel? {
        switch self {
        case .seedling: .sprout
        case .sprout: .tree
        case .tree: .forest
        case .forest: .earth
        case .earth: nil
        }
    }

    var pointsRequired: Int {
        switch self {
        case .seedling: 0
        case .sprout: 300
        case .tree: 1000
        case .forest: 2500
        case .earth: 5000
        }
    }
}

/// 月次レポート
struct MonthlyReport: Identifiable, Sendable {
    let id = UUID()
    let month: Date
    let totalChargeSessions: Int
    let totalEnergyKWh: Double
    let cleanChargeRate: Double
    let co2Savings: Double
    let costSavings: Double
    let earnedPoints: Int

    var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: month)
    }
}
