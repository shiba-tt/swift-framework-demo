import Foundation

/// 社会的つながりの総合スコア
struct SocialScore: Identifiable, Sendable {
    let id = UUID()
    /// スコア計算対象の日付
    let date: Date
    /// 総合スコア（0〜100）
    let overallScore: Int
    /// 電話コミュニケーションスコア（0〜100）
    let phoneScore: Int
    /// メッセージスコア（0〜100）
    let messageScore: Int
    /// 訪問・外出スコア（0〜100）
    let visitScore: Int
    /// 前日比の変化
    let changeFromPrevious: Int?

    /// スコアレベル
    var scoreLevel: SocialLevel {
        SocialLevel.from(score: overallScore)
    }

    /// 評価テキスト
    var assessmentText: String {
        switch scoreLevel {
        case .excellent:
            "社会的つながりは非常に良好です"
        case .good:
            "社会的つながりは良好です"
        case .fair:
            "社会的つながりがやや低下しています"
        case .poor:
            "社会的孤立のリスクがあります"
        }
    }

    /// サブスコアの中で最も高いカテゴリ
    var strongestCategory: SocialCategory {
        let scores = [
            (SocialCategory.phone, phoneScore),
            (SocialCategory.message, messageScore),
            (SocialCategory.visit, visitScore),
        ]
        return scores.max(by: { $0.1 < $1.1 })?.0 ?? .phone
    }

    /// サブスコアの中で最も低いカテゴリ
    var weakestCategory: SocialCategory {
        let scores = [
            (SocialCategory.phone, phoneScore),
            (SocialCategory.message, messageScore),
            (SocialCategory.visit, visitScore),
        ]
        return scores.min(by: { $0.1 < $1.1 })?.0 ?? .visit
    }
}

/// 社会的つながりのレベル
enum SocialLevel: String, Sendable, CaseIterable {
    case excellent = "非常に良好"
    case good = "良好"
    case fair = "やや低下"
    case poor = "要注意"

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

    static func from(score: Int) -> SocialLevel {
        switch score {
        case 80...: .excellent
        case 60..<80: .good
        case 40..<60: .fair
        default: .poor
        }
    }
}

/// 社会的つながりのカテゴリ
enum SocialCategory: String, Sendable, CaseIterable, Identifiable {
    case phone = "電話"
    case message = "メッセージ"
    case visit = "外出・訪問"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .phone: "phone.fill"
        case .message: "message.fill"
        case .visit: "mappin.and.ellipse"
        }
    }

    var colorName: String {
        switch self {
        case .phone: "blue"
        case .message: "green"
        case .visit: "orange"
        }
    }

    /// SocialScore からこのカテゴリのスコアを取得
    func score(from socialScore: SocialScore) -> Int {
        switch self {
        case .phone: socialScore.phoneScore
        case .message: socialScore.messageScore
        case .visit: socialScore.visitScore
        }
    }
}
