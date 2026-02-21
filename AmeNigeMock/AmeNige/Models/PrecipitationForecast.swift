import Foundation

/// 分単位の降水予報データ
struct PrecipitationForecast: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// 降水強度 (mm/h)
    let intensityMmPerHour: Double

    /// 降水しているかどうか（0.1mm/h 以上）
    var isRaining: Bool {
        intensityMmPerHour > 0.1
    }

    /// 降水強度のレベル
    var level: PrecipitationLevel {
        PrecipitationLevel.from(intensityMmPerHour: intensityMmPerHour)
    }

    /// 時刻の表示テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// 降水強度のレベル分類
enum PrecipitationLevel: String, Sendable, CaseIterable {
    case none = "降水なし"
    case light = "弱い雨"
    case moderate = "雨"
    case heavy = "強い雨"
    case veryHeavy = "非常に強い雨"
    case extreme = "猛烈な雨"

    /// mm/h から降水レベルを判定
    static func from(intensityMmPerHour: Double) -> PrecipitationLevel {
        switch intensityMmPerHour {
        case ..<0.1: .none
        case 0.1..<3.0: .light
        case 3.0..<10.0: .moderate
        case 10.0..<20.0: .heavy
        case 20.0..<50.0: .veryHeavy
        default: .extreme
        }
    }

    /// レベルに対応するアイコン
    var systemImageName: String {
        switch self {
        case .none: "sun.max.fill"
        case .light: "cloud.drizzle.fill"
        case .moderate: "cloud.rain.fill"
        case .heavy: "cloud.heavyrain.fill"
        case .veryHeavy: "cloud.bolt.rain.fill"
        case .extreme: "tornado"
        }
    }

    /// レベルに対応する色名
    var colorName: String {
        switch self {
        case .none: "green"
        case .light: "cyan"
        case .moderate: "blue"
        case .heavy: "orange"
        case .veryHeavy: "red"
        case .extreme: "purple"
        }
    }
}

/// 時間別の降水予報（1時間以降の予報用）
struct HourlyPrecipitation: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// 降水確率 (0.0 - 1.0)
    let precipitationChance: Double
    /// 降水量 (mm)
    let precipitationAmount: Double
    /// 天候状態の説明
    let conditionDescription: String
    /// 天候アイコン
    let conditionIcon: String

    /// 時刻の表示テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter.string(from: date)
    }

    /// 降水確率の表示テキスト
    var chanceText: String {
        "\(Int(precipitationChance * 100))%"
    }
}
