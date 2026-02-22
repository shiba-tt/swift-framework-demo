import Foundation

/// 概日リズムプロファイル — 24 時間の光環境パターン
struct CircadianProfile: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    /// 1 時間ごとの平均照度（24 要素）
    let hourlyLux: [Double]
    /// 1 時間ごとの平均色温度（24 要素）
    let hourlyColorTemp: [Double]
    /// 概日リズムスコア（0〜100）
    let rhythmScore: Int
    /// 推定起床時刻
    let estimatedWakeTime: Date
    /// 推定就寝時刻
    let estimatedSleepTime: Date

    /// 日中の平均照度
    var daytimeAverageLux: Double {
        guard hourlyLux.count >= 18 else { return 0 }
        let daytimeSlice = Array(hourlyLux[7...17])
        return daytimeSlice.reduce(0, +) / Double(daytimeSlice.count)
    }

    /// 夜間の平均照度
    var nighttimeAverageLux: Double {
        guard hourlyLux.count >= 24 else { return 0 }
        let nightSlice = Array(hourlyLux[22...23]) + Array(hourlyLux[0...5])
        return nightSlice.reduce(0, +) / Double(nightSlice.count)
    }

    /// ブルーライト曝露推定（色温度ベース）
    var blueLightExposureLevel: BlueLightLevel {
        let eveningColorTemp = hourlyColorTemp.count >= 23
            ? Array(hourlyColorTemp[20...22]).reduce(0, +) / 3.0
            : 4000
        if eveningColorTemp > 5500 { return .high }
        if eveningColorTemp > 4500 { return .moderate }
        return .low
    }
}

enum BlueLightLevel: String, Sendable {
    case low = "低"
    case moderate = "中"
    case high = "高"

    var icon: String {
        switch self {
        case .low: return "eye"
        case .moderate: return "eye.trianglebadge.exclamationmark"
        case .high: return "exclamationmark.triangle.fill"
        }
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "red"
        }
    }
}

/// リズム評価
enum RhythmAssessment: String, Sendable {
    case excellent = "非常に安定"
    case good = "良好"
    case fair = "やや不規則"
    case poor = "不規則"
    case disrupted = "昼夜逆転の疑い"

    static func from(score: Int) -> RhythmAssessment {
        switch score {
        case 85...100: return .excellent
        case 70..<85: return .good
        case 55..<70: return .fair
        case 40..<55: return .poor
        default: return .disrupted
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "checkmark.circle"
        case .fair: return "minus.circle"
        case .poor: return "exclamationmark.circle"
        case .disrupted: return "exclamationmark.triangle.fill"
        }
    }
}
