import Foundation

/// 概日リズムのプロファイル
struct CircadianProfile: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    /// 24時間分のセンサー読み取り値
    let readings: [SensorReading]
    /// 全センサーのリズム整合度スコア（0〜100）
    let rhythmScore: Int
    /// 前日比の変化
    let changeFromPrevious: Int?

    /// スコアレベル
    var scoreLevel: RhythmLevel {
        RhythmLevel.from(score: rhythmScore)
    }

    /// 活動ピーク時間帯
    var peakActivityHour: Int {
        readings.max(by: { $0.activityLevel < $1.activityLevel })?.hour ?? 12
    }

    /// 光ピーク時間帯
    var peakLightHour: Int {
        readings.max(by: { $0.ambientLux < $1.ambientLux })?.hour ?? 12
    }

    /// 通信ピーク時間帯
    var peakSocialHour: Int {
        readings.max(by: { $0.socialInteractions < $1.socialInteractions })?.hour ?? 14
    }

    /// 総歩数
    var totalSteps: Int {
        readings.reduce(0) { $0 + $1.steps }
    }

    /// 総スクリーンタイム（分）
    var totalScreenTime: Int {
        readings.reduce(0) { $0 + $1.screenTimeMinutes }
    }

    /// 推定睡眠時間帯（hour 配列）
    var sleepHours: [Int] {
        readings.filter { !$0.isWristOn || ($0.activityLevel < 0.05 && $0.ambientLux < 10) }
            .map(\.hour)
    }

    /// 推定活動時間帯（hour 配列）
    var activeHours: [Int] {
        readings.filter { $0.activityLevel >= 0.3 }
            .map(\.hour)
    }
}

/// リズム整合度のレベル
enum RhythmLevel: String, Sendable, CaseIterable {
    case excellent = "優秀"
    case good = "良好"
    case fair = "やや乱れ"
    case poor = "要改善"

    var systemImageName: String {
        switch self {
        case .excellent: "star.circle.fill"
        case .good: "checkmark.circle.fill"
        case .fair: "exclamationmark.circle.fill"
        case .poor: "exclamationmark.triangle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .excellent: "yellow"
        case .good: "green"
        case .fair: "orange"
        case .poor: "red"
        }
    }

    static func from(score: Int) -> RhythmLevel {
        switch score {
        case 85...: .excellent
        case 70..<85: .good
        case 50..<70: .fair
        default: .poor
        }
    }
}

/// センサーチャンネルのタイプ
enum SensorChannel: String, Sendable, CaseIterable, Identifiable {
    case activity = "身体活動"
    case light = "環境光"
    case screenTime = "画面使用"
    case keyboard = "キーボード"
    case steps = "歩数"
    case social = "コミュニケーション"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .activity: "figure.walk"
        case .light: "sun.max.fill"
        case .screenTime: "iphone"
        case .keyboard: "keyboard"
        case .steps: "shoeprints.fill"
        case .social: "message.fill"
        }
    }

    var colorName: String {
        switch self {
        case .activity: "orange"
        case .light: "yellow"
        case .screenTime: "blue"
        case .keyboard: "purple"
        case .steps: "green"
        case .social: "pink"
        }
    }

    /// SensorReading からこのチャンネルの正規化された値を取得
    func normalizedValue(from reading: SensorReading) -> Double {
        switch self {
        case .activity: reading.activityLevel
        case .light: min(1.0, reading.ambientLux / 10000.0)
        case .screenTime: min(1.0, Double(reading.screenTimeMinutes) / 60.0)
        case .keyboard: min(1.0, Double(reading.keystrokes) / 500.0)
        case .steps: min(1.0, Double(reading.steps) / 2000.0)
        case .social: min(1.0, Double(reading.socialInteractions) / 20.0)
        }
    }
}
