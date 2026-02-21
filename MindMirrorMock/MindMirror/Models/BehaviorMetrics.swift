import Foundation

/// センサーから取得した行動メトリクス
struct BehaviorMetrics: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let typing: TypingMetrics?
    let deviceUsage: DeviceUsageMetrics?
    let communication: CommunicationMetrics?
    let mobility: MobilityMetrics?
    let ambientLight: AmbientLightMetrics?
}

/// タイピングメトリクス（SRKeyboardMetrics 由来）
struct TypingMetrics: Sendable {
    /// 平均タイピング速度（WPM）
    let averageWPM: Double
    /// エラー率（0.0〜1.0）
    let errorRate: Double
    /// キーストローク間隔の変動係数
    let rhythmVariability: Double
    /// 感情分析スコア（-1.0〜1.0: ネガティブ〜ポジティブ）
    let sentimentScore: Double

    /// タイピング速度のレベル
    var speedLevel: MetricLevel {
        switch averageWPM {
        case 35...: .good
        case 25..<35: .moderate
        default: .concern
        }
    }

    /// エラー率のレベル
    var errorLevel: MetricLevel {
        switch errorRate {
        case ..<0.05: .good
        case 0.05..<0.15: .moderate
        default: .concern
        }
    }
}

/// デバイス使用メトリクス（SRDeviceUsageReport 由来）
struct DeviceUsageMetrics: Sendable {
    /// 総画面オン時間（分）
    let totalScreenTimeMinutes: Int
    /// 画面起動回数
    let screenWakeCount: Int
    /// アンロック回数
    let unlockCount: Int
    /// カテゴリ別使用時間
    let categoryUsage: [AppCategoryUsage]

    /// 画面使用時間のレベル
    var screenTimeLevel: MetricLevel {
        switch totalScreenTimeMinutes {
        case ..<240: .good
        case 240..<480: .moderate
        default: .concern
        }
    }
}

/// アプリカテゴリ別の使用時間
struct AppCategoryUsage: Identifiable, Sendable {
    let id = UUID()
    let category: String
    let usageMinutes: Int
}

/// コミュニケーションメトリクス（電話 + メッセージ）
struct CommunicationMetrics: Sendable {
    /// 発信回数
    let outgoingCalls: Int
    /// 着信回数
    let incomingCalls: Int
    /// 通話合計時間（分）
    let totalCallMinutes: Int
    /// 送信メッセージ数
    let outgoingMessages: Int
    /// 受信メッセージ数
    let incomingMessages: Int

    /// コミュニケーション量の合計
    var totalInteractions: Int {
        outgoingCalls + incomingCalls + outgoingMessages + incomingMessages
    }

    /// ソーシャル活動レベル
    var socialLevel: MetricLevel {
        switch totalInteractions {
        case 20...: .good
        case 8..<20: .moderate
        default: .concern
        }
    }
}

/// 移動・訪問メトリクス（SRVisit 由来）
struct MobilityMetrics: Sendable {
    /// 訪問場所数
    let visitedPlaceCount: Int
    /// 自宅滞在時間（分）
    let homeTimeMinutes: Int
    /// 外出時間（分）
    let awayTimeMinutes: Int
    /// 最大の自宅からの距離（km）
    let maxDistanceFromHomeKm: Double

    /// 行動範囲レベル
    var mobilityLevel: MetricLevel {
        switch visitedPlaceCount {
        case 3...: .good
        case 1..<3: .moderate
        default: .concern
        }
    }
}

/// 環境光メトリクス（SRAmbientLightSensor 由来）
struct AmbientLightMetrics: Sendable {
    /// 平均照度（lux）
    let averageLux: Double
    /// 日中のピーク照度
    let peakDaytimeLux: Double
    /// 夜間の平均照度
    let nighttimeAverageLux: Double
    /// 明るい環境にいた時間（分）
    let brightExposureMinutes: Int

    /// 光環境レベル
    var lightLevel: MetricLevel {
        switch brightExposureMinutes {
        case 120...: .good
        case 60..<120: .moderate
        default: .concern
        }
    }
}

/// メトリクスの評価レベル
enum MetricLevel: String, Sendable, CaseIterable {
    case good = "良好"
    case moderate = "注意"
    case concern = "要観察"

    var systemImageName: String {
        switch self {
        case .good: "checkmark.circle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .concern: "exclamationmark.triangle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .good: "green"
        case .moderate: "orange"
        case .concern: "red"
        }
    }
}
