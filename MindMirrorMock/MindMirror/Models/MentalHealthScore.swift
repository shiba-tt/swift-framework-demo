import Foundation

/// 複合メンタルヘルススコア
struct MentalHealthScore: Sendable {
    /// 総合スコア（0〜100）
    let overallScore: Int
    /// 各カテゴリのサブスコア
    let subScores: [SubScore]
    /// 前日比の変化
    let changeFromPrevious: Int?
    /// スコアの評価
    var level: ScoreLevel {
        ScoreLevel.from(score: overallScore)
    }

    /// 変化の方向
    var trend: Trend {
        guard let change = changeFromPrevious else { return .stable }
        if change > 3 { return .improving }
        if change < -3 { return .declining }
        return .stable
    }
}

/// サブスコア
struct SubScore: Identifiable, Sendable {
    let id = UUID()
    let category: ScoreCategory
    let score: Int
    let weight: Double

    var level: ScoreLevel {
        ScoreLevel.from(score: score)
    }
}

/// スコアのカテゴリ
enum ScoreCategory: String, Sendable, CaseIterable {
    case activity = "活動量"
    case social = "社会的つながり"
    case cognition = "認知機能"
    case rhythm = "生活リズム"
    case mood = "気分傾向"

    var systemImageName: String {
        switch self {
        case .activity: "figure.walk"
        case .social: "person.2.fill"
        case .cognition: "brain.fill"
        case .rhythm: "clock.fill"
        case .mood: "face.smiling.fill"
        }
    }

    var description: String {
        switch self {
        case .activity: "外出頻度・身体活動量"
        case .social: "電話・メッセージの頻度"
        case .cognition: "タイピング速度・エラー率"
        case .rhythm: "光環境・画面使用パターン"
        case .mood: "キーボード感情分析"
        }
    }
}

/// スコアのレベル
enum ScoreLevel: String, Sendable {
    case excellent = "非常に良好"
    case good = "良好"
    case moderate = "普通"
    case caution = "注意"
    case concern = "要観察"

    static func from(score: Int) -> ScoreLevel {
        switch score {
        case 80...: .excellent
        case 65..<80: .good
        case 50..<65: .moderate
        case 35..<50: .caution
        default: .concern
        }
    }

    var systemImageName: String {
        switch self {
        case .excellent: "star.fill"
        case .good: "checkmark.circle.fill"
        case .moderate: "minus.circle.fill"
        case .caution: "exclamationmark.circle.fill"
        case .concern: "exclamationmark.triangle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .excellent: "blue"
        case .good: "green"
        case .moderate: "yellow"
        case .caution: "orange"
        case .concern: "red"
        }
    }
}

/// トレンドの方向
enum Trend: String, Sendable {
    case improving = "改善傾向"
    case stable = "安定"
    case declining = "低下傾向"

    var systemImageName: String {
        switch self {
        case .improving: "arrow.up.right"
        case .stable: "arrow.right"
        case .declining: "arrow.down.right"
        }
    }

    var colorName: String {
        switch self {
        case .improving: "green"
        case .stable: "blue"
        case .declining: "orange"
        }
    }
}
