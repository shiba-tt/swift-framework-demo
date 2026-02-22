import Foundation

/// ユーザーの快適度プロファイル
struct ComfortProfile: Sendable {
    /// 最低許容温度 (°C)
    var minimumTemperature: Double
    /// 最高許容温度 (°C)
    var maximumTemperature: Double
    /// 目標快適度スコア (0〜100)
    var targetComfortScore: Int
    /// 就寝時の目標温度
    var sleepTemperature: Double
    /// 外出時のエコ温度
    var awayTemperature: Double

    /// 許容温度範囲の表示テキスト
    var temperatureRangeText: String {
        "\(Int(minimumTemperature))°C〜\(Int(maximumTemperature))°C"
    }

    static let `default` = ComfortProfile(
        minimumTemperature: 20.0,
        maximumTemperature: 26.0,
        targetComfortScore: 90,
        sleepTemperature: 22.0,
        awayTemperature: 28.0
    )
}

/// 室温の記録データ
struct TemperatureRecord: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// 実測温度 (°C)
    let temperature: Double
    /// 目標温度 (°C)
    let targetTemperature: Double
    /// 快適度スコア
    let comfortScore: Int

    var hourText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter.string(from: date)
    }

    var shortTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// 月次の節約レポート
struct MonthlySavingsReport: Identifiable, Sendable {
    let id = UUID()
    let month: Date
    /// 節約額
    let totalSavings: Double
    /// 消費電力 (kWh)
    let totalEnergyKWh: Double
    /// 平均快適度
    let averageComfortScore: Int
    /// CO2 削減量 (kg)
    let co2Savings: Double
    /// 運転日数
    let operatingDays: Int

    var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: month)
    }

    var savingsText: String {
        String(format: "$%.2f", totalSavings)
    }
}
