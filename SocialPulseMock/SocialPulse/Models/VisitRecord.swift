import Foundation

/// 1日の訪問記録
struct VisitRecord: Identifiable, Sendable {
    let id = UUID()
    /// 記録日
    let date: Date
    /// 訪問場所数
    let placesVisited: Int
    /// 自宅外で過ごした時間（分）
    let timeOutsideMinutes: Int
    /// 訪問した場所カテゴリの内訳
    let categories: [VisitCategory: Int]
    /// 自宅からの最大移動距離（km）
    let distanceFromHomeKm: Double

    /// 自宅外で過ごした時間（時間単位）
    var timeOutsideHours: Double {
        Double(timeOutsideMinutes) / 60.0
    }

    /// 行動範囲レベル
    var mobilityLevel: MobilityLevel {
        switch placesVisited {
        case 5...: .veryActive
        case 3..<5: .active
        case 1..<3: .moderate
        default: .homebound
        }
    }

    /// 最も多く訪問したカテゴリ
    var primaryCategory: VisitCategory? {
        categories.max(by: { $0.value < $1.value })?.key
    }

    /// カテゴリの多様性スコア（0.0〜1.0）
    var categoryDiversity: Double {
        let activeCategories = categories.filter { $0.value > 0 }.count
        return Double(activeCategories) / Double(VisitCategory.allCases.count)
    }
}

/// 訪問場所のカテゴリ（SRVisit.LocationCategory に対応）
enum VisitCategory: String, Sendable, CaseIterable, Identifiable {
    case home = "自宅"
    case work = "職場"
    case school = "学校"
    case gym = "ジム"
    case shopping = "買い物"
    case restaurant = "飲食店"
    case medical = "医療機関"
    case other = "その他"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .home: "house.fill"
        case .work: "briefcase.fill"
        case .school: "graduationcap.fill"
        case .gym: "figure.run"
        case .shopping: "cart.fill"
        case .restaurant: "fork.knife"
        case .medical: "cross.case.fill"
        case .other: "mappin.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .home: "blue"
        case .work: "purple"
        case .school: "orange"
        case .gym: "green"
        case .shopping: "pink"
        case .restaurant: "red"
        case .medical: "cyan"
        case .other: "gray"
        }
    }
}

/// 行動範囲レベル
enum MobilityLevel: String, Sendable, CaseIterable {
    case veryActive = "非常に活動的"
    case active = "活動的"
    case moderate = "普通"
    case homebound = "在宅中心"

    var colorName: String {
        switch self {
        case .veryActive: "green"
        case .active: "blue"
        case .moderate: "orange"
        case .homebound: "red"
        }
    }

    var systemImageName: String {
        switch self {
        case .veryActive: "figure.walk.motion"
        case .active: "figure.walk"
        case .moderate: "figure.stand"
        case .homebound: "house.fill"
        }
    }
}
