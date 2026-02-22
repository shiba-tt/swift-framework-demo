import Foundation

/// 週間レポート
struct WeeklyReport: Identifiable, Sendable {
    let id = UUID()
    /// 週の開始日
    let weekStartDate: Date
    /// 日別スコア
    let dailyScores: [SocialScore]
    /// AI生成のインサイト
    let insights: [String]

    /// 週間平均スコア
    var averageScore: Int {
        guard !dailyScores.isEmpty else { return 0 }
        return dailyScores.reduce(0) { $0 + $1.overallScore } / dailyScores.count
    }

    /// 週間平均電話スコア
    var averagePhoneScore: Int {
        guard !dailyScores.isEmpty else { return 0 }
        return dailyScores.reduce(0) { $0 + $1.phoneScore } / dailyScores.count
    }

    /// 週間平均メッセージスコア
    var averageMessageScore: Int {
        guard !dailyScores.isEmpty else { return 0 }
        return dailyScores.reduce(0) { $0 + $1.messageScore } / dailyScores.count
    }

    /// 週間平均訪問スコア
    var averageVisitScore: Int {
        guard !dailyScores.isEmpty else { return 0 }
        return dailyScores.reduce(0) { $0 + $1.visitScore } / dailyScores.count
    }

    /// 最高スコアの日
    var bestDay: SocialScore? {
        dailyScores.max(by: { $0.overallScore < $1.overallScore })
    }

    /// 最低スコアの日
    var worstDay: SocialScore? {
        dailyScores.min(by: { $0.overallScore < $1.overallScore })
    }

    /// トレンド（改善/安定/低下）
    var trend: WeeklyTrend {
        guard dailyScores.count >= 3 else { return .stable }
        let firstHalf = dailyScores.prefix(dailyScores.count / 2)
        let secondHalf = dailyScores.suffix(dailyScores.count / 2)

        let firstAvg = firstHalf.reduce(0) { $0 + $1.overallScore } / max(1, firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + $1.overallScore } / max(1, secondHalf.count)

        let diff = secondAvg - firstAvg
        if diff >= 5 {
            return .improving
        } else if diff <= -5 {
            return .declining
        } else {
            return .stable
        }
    }

    /// スコアの標準偏差
    var scoreVariance: Double {
        guard dailyScores.count > 1 else { return 0 }
        let mean = Double(averageScore)
        let sumOfSquares = dailyScores.reduce(0.0) { $0 + pow(Double($1.overallScore) - mean, 2) }
        return (sumOfSquares / Double(dailyScores.count)).squareRoot()
    }
}

/// 週間トレンド
enum WeeklyTrend: String, Sendable {
    case improving = "改善傾向"
    case stable = "安定"
    case declining = "低下傾向"

    var systemImageName: String {
        switch self {
        case .improving: "arrow.up.right.circle.fill"
        case .stable: "equal.circle.fill"
        case .declining: "arrow.down.right.circle.fill"
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
