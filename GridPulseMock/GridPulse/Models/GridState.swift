import Foundation
import SwiftUI

/// 電力グリッドの時間帯別状態
struct GridState: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let cleanEnergyFraction: Double
    let solarFraction: Double
    let windFraction: Double

    /// クリーン度レベル
    var level: GridLevel {
        switch cleanEnergyFraction {
        case 0.7...: return .veryClean
        case 0.5..<0.7: return .clean
        case 0.3..<0.5: return .moderate
        default: return .dirty
        }
    }

    /// クリーン度パーセントテキスト
    var cleanPercentText: String {
        "\(Int(cleanEnergyFraction * 100))%"
    }

    /// 時刻ラベル
    var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H"
        return formatter.string(from: date)
    }

    /// グリッド状態に応じた色
    var color: Color {
        level.color
    }
}

/// グリッドのクリーン度レベル
enum GridLevel: Sendable {
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

    var label: String {
        switch self {
        case .veryClean: "非常にクリーン"
        case .clean: "クリーン"
        case .moderate: "中程度"
        case .dirty: "化石燃料中心"
        }
    }

    var emoji: String {
        switch self {
        case .veryClean: "🌿"
        case .clean: "🍃"
        case .moderate: "🌥"
        case .dirty: "🏭"
        }
    }
}

/// 日次のグリッドサマリー
struct GridDailySummary: Sendable {
    let date: Date
    let averageCleanFraction: Double
    let peakCleanFraction: Double
    let peakCleanHour: Int
    let lowestCleanFraction: Double
    let lowestCleanHour: Int
    let totalSolarHours: Double
    let totalWindHours: Double

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 平均クリーン度テキスト
    var averageCleanText: String {
        "\(Int(averageCleanFraction * 100))%"
    }

    /// その日のテーマ名
    var themeName: String {
        switch averageCleanFraction {
        case 0.7...: return "風と太陽の一日"
        case 0.5..<0.7: return "穏やかな風の一日"
        case 0.3..<0.5: return "曇りがちな一日"
        default: return "静かな工場の一日"
        }
    }
}
