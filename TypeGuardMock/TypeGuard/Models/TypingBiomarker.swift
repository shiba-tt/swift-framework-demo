import Foundation

/// タイピングバイオマーカーデータ
struct TypingBiomarker: Identifiable, Sendable {
    let id = UUID()
    let date: Date

    /// 平均タイピング速度（WPM）
    let averageWPM: Double
    /// エラー率（0.0〜1.0）
    let errorRate: Double
    /// キーストローク間隔の変動係数
    let rhythmVariability: Double
    /// 隣接キー誤入力率（0.0〜1.0）
    let adjacentKeyErrorRate: Double
    /// 押下時間の標準偏差（ms）
    let pressureDurationSD: Double
    /// 感情分析スコア（-1.0〜1.0）
    let sentimentScore: Double

    /// 総合リスクスコア（0〜100、高いほどリスクが高い）
    var riskScore: Int {
        var score = 0.0

        // 速度低下スコア（遅いほどリスク高）
        score += max(0, (30 - averageWPM) / 30) * 25

        // エラー率スコア
        score += min(1.0, errorRate / 0.2) * 25

        // リズム不規則性スコア
        score += min(1.0, rhythmVariability / 0.4) * 20

        // 隣接キーエラースコア（振戦の指標）
        score += min(1.0, adjacentKeyErrorRate / 0.15) * 20

        // 押下時間ばらつきスコア
        score += min(1.0, pressureDurationSD / 80) * 10

        return min(100, Int(score))
    }

    /// リスクレベル
    var riskLevel: RiskLevel {
        RiskLevel.from(score: riskScore)
    }

    /// 日付の表示テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 短い日付テキスト
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - RiskLevel

/// リスクレベル
enum RiskLevel: String, Sendable {
    case normal = "正常"
    case mild = "軽度変化"
    case moderate = "中度変化"
    case significant = "有意な変化"

    static func from(score: Int) -> RiskLevel {
        switch score {
        case ..<25: .normal
        case 25..<50: .mild
        case 50..<75: .moderate
        default: .significant
        }
    }

    var systemImageName: String {
        switch self {
        case .normal: "checkmark.shield.fill"
        case .mild: "exclamationmark.circle.fill"
        case .moderate: "exclamationmark.triangle.fill"
        case .significant: "xmark.shield.fill"
        }
    }

    var colorName: String {
        switch self {
        case .normal: "green"
        case .mild: "yellow"
        case .moderate: "orange"
        case .significant: "red"
        }
    }
}

// MARK: - TypingMetricType

/// タイピングメトリクスの種類
enum TypingMetricType: String, CaseIterable, Sendable {
    case speed = "タイピング速度"
    case errorRate = "エラー率"
    case rhythm = "リズム規則性"
    case adjacentError = "隣接キー誤入力"
    case pressureSD = "押下時間ばらつき"
    case sentiment = "感情傾向"

    var systemImageName: String {
        switch self {
        case .speed: "gauge.with.dots.needle.50percent"
        case .errorRate: "xmark.circle"
        case .rhythm: "waveform.path.ecg"
        case .adjacentError: "keyboard.badge.exclamationmark"
        case .pressureSD: "hand.tap"
        case .sentiment: "face.smiling"
        }
    }

    var description: String {
        switch self {
        case .speed: "1分あたりの単語入力数"
        case .errorRate: "修正・削除の頻度"
        case .rhythm: "キーストローク間隔の安定性"
        case .adjacentError: "振戦に関連する隣のキーの押し間違い"
        case .pressureSD: "キー押下時間のばらつき"
        case .sentiment: "入力テキストから推定される感情"
        }
    }

    var unit: String {
        switch self {
        case .speed: "WPM"
        case .errorRate: "%"
        case .rhythm: ""
        case .adjacentError: "%"
        case .pressureSD: "ms"
        case .sentiment: ""
        }
    }
}
