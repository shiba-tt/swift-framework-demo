import Foundation

/// ベースラインプロファイル — ユーザーの「普段のタイピング」のパターン
struct BaselineProfile: Sendable {
    /// ベースラインが確立された日
    let establishedDate: Date
    /// データ収集日数
    let dataCollectionDays: Int

    /// 平均タイピング速度のベースライン（WPM）
    let baselineWPM: Double
    /// 平均エラー率のベースライン
    let baselineErrorRate: Double
    /// 平均リズム変動のベースライン
    let baselineRhythmVariability: Double
    /// 平均隣接キーエラー率のベースライン
    let baselineAdjacentKeyErrorRate: Double
    /// 平均押下時間SDのベースライン
    let baselinePressureDurationSD: Double

    /// ベースラインが十分なデータで確立されているか
    var isEstablished: Bool {
        dataCollectionDays >= 7
    }

    /// 確立度合い（0.0〜1.0）
    var completionRate: Double {
        min(1.0, Double(dataCollectionDays) / 7.0)
    }

    /// 確立度のテキスト
    var statusText: String {
        if isEstablished {
            return "ベースライン確立済み（\(dataCollectionDays)日間のデータ）"
        }
        return "ベースライン構築中（あと\(7 - dataCollectionDays)日）"
    }

    /// デフォルトのベースライン（初期状態）
    static let `default` = BaselineProfile(
        establishedDate: Date(),
        dataCollectionDays: 0,
        baselineWPM: 0,
        baselineErrorRate: 0,
        baselineRhythmVariability: 0,
        baselineAdjacentKeyErrorRate: 0,
        baselinePressureDurationSD: 0
    )
}

// MARK: - DeviationResult

/// ベースラインからの偏差分析結果
struct DeviationResult: Identifiable, Sendable {
    let id = UUID()
    let metricType: TypingMetricType
    let currentValue: Double
    let baselineValue: Double
    let deviationPercent: Double

    /// 偏差のレベル
    var level: DeviationLevel {
        let absDeviation = abs(deviationPercent)
        switch absDeviation {
        case ..<10: return .normal
        case 10..<25: return .mild
        case 25..<40: return .moderate
        default: return .significant
        }
    }
}

/// 偏差レベル
enum DeviationLevel: String, Sendable {
    case normal = "正常範囲"
    case mild = "軽度偏差"
    case moderate = "中度偏差"
    case significant = "有意な偏差"

    var colorName: String {
        switch self {
        case .normal: "green"
        case .mild: "yellow"
        case .moderate: "orange"
        case .significant: "red"
        }
    }
}

// MARK: - AlertRecord

/// アラート履歴
struct AlertRecord: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let title: String
    let description: String
    let severity: AlertSeverity
    let relatedMetrics: [TypingMetricType]

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

/// アラートの深刻度
enum AlertSeverity: String, Sendable {
    case info = "情報"
    case warning = "注意"
    case critical = "重要"

    var systemImageName: String {
        switch self {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .critical: "exclamationmark.octagon.fill"
        }
    }

    var colorName: String {
        switch self {
        case .info: "blue"
        case .warning: "orange"
        case .critical: "red"
        }
    }
}
