import Foundation

/// 1時間ごとのセンサー読み取り値
struct SensorReading: Identifiable, Sendable {
    let id = UUID()
    /// 時間帯（0〜23）
    let hour: Int
    /// 加速度による身体活動量（0.0〜1.0）
    let activityLevel: Double
    /// 環境光照度（lux）
    let ambientLux: Double
    /// デバイス使用量（分 / 時間）
    let screenTimeMinutes: Int
    /// キーボード操作量（キーストローク / 時間）
    let keystrokes: Int
    /// 歩数（歩 / 時間）
    let steps: Int
    /// 電話・メッセージのインタラクション数
    let socialInteractions: Int
    /// Apple Watch 装着状態
    let isWristOn: Bool

    /// 身体活動レベル
    var activityCategory: ActivityCategory {
        switch activityLevel {
        case 0.6...: .high
        case 0.3..<0.6: .moderate
        case 0.01..<0.3: .low
        default: .rest
        }
    }

    /// 光環境カテゴリ
    var lightCategory: LightCategory {
        switch ambientLux {
        case 10000...: .brightOutdoor
        case 1000..<10000: .outdoor
        case 300..<1000: .brightIndoor
        case 50..<300: .indoor
        default: .dark
        }
    }
}

/// 身体活動カテゴリ
enum ActivityCategory: String, Sendable, CaseIterable {
    case high = "高活動"
    case moderate = "中活動"
    case low = "低活動"
    case rest = "休息"

    var colorName: String {
        switch self {
        case .high: "orange"
        case .moderate: "green"
        case .low: "blue"
        case .rest: "purple"
        }
    }

    var systemImageName: String {
        switch self {
        case .high: "figure.run"
        case .moderate: "figure.walk"
        case .low: "figure.stand"
        case .rest: "bed.double.fill"
        }
    }
}

/// 光環境カテゴリ
enum LightCategory: String, Sendable, CaseIterable {
    case brightOutdoor = "強い日光"
    case outdoor = "屋外"
    case brightIndoor = "明るい室内"
    case indoor = "室内"
    case dark = "暗所"

    var colorName: String {
        switch self {
        case .brightOutdoor: "yellow"
        case .outdoor: "orange"
        case .brightIndoor: "cyan"
        case .indoor: "blue"
        case .dark: "indigo"
        }
    }
}
