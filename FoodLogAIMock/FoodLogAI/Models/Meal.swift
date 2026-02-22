import Foundation

/// 食事記録
struct Meal: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let mealType: MealType
    let dishes: [Dish]
    let photoId: String?

    /// 総カロリー
    var totalCalories: Int {
        dishes.reduce(0) { $0 + $1.calories }
    }

    /// 総タンパク質（g）
    var totalProtein: Double {
        dishes.reduce(0) { $0 + $1.protein }
    }

    /// 総脂質（g）
    var totalFat: Double {
        dishes.reduce(0) { $0 + $1.fat }
    }

    /// 総炭水化物（g）
    var totalCarbs: Double {
        dishes.reduce(0) { $0 + $1.carbs }
    }

    /// PFCバランス（タンパク質:脂質:炭水化物 の比率）
    var pfcRatio: (protein: Double, fat: Double, carbs: Double) {
        let total = totalProtein * 4 + totalFat * 9 + totalCarbs * 4
        guard total > 0 else { return (0.33, 0.33, 0.34) }
        return (
            protein: (totalProtein * 4) / total,
            fat: (totalFat * 9) / total,
            carbs: (totalCarbs * 4) / total
        )
    }

    /// PFCバランスの評価
    var pfcBalance: PFCBalance {
        let ratio = pfcRatio
        // 理想: P 13-20%, F 20-30%, C 50-65%
        let pGood = (0.13...0.20).contains(ratio.protein)
        let fGood = (0.20...0.30).contains(ratio.fat)
        let cGood = (0.50...0.65).contains(ratio.carbs)

        if pGood && fGood && cGood {
            return .excellent
        } else if (pGood && fGood) || (pGood && cGood) || (fGood && cGood) {
            return .good
        } else {
            return .needsImprovement
        }
    }
}

/// 食事タイプ
enum MealType: String, Sendable, CaseIterable, Identifiable {
    case breakfast = "朝食"
    case lunch = "昼食"
    case dinner = "夕食"
    case snack = "間食"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .breakfast: "sun.horizon.fill"
        case .lunch: "sun.max.fill"
        case .dinner: "moon.fill"
        case .snack: "cup.and.saucer.fill"
        }
    }

    var colorName: String {
        switch self {
        case .breakfast: "orange"
        case .lunch: "yellow"
        case .dinner: "indigo"
        case .snack: "pink"
        }
    }
}

/// PFCバランス評価
enum PFCBalance: String, Sendable {
    case excellent = "理想的"
    case good = "良好"
    case needsImprovement = "改善の余地あり"

    var colorName: String {
        switch self {
        case .excellent: "green"
        case .good: "blue"
        case .needsImprovement: "orange"
        }
    }

    var systemImageName: String {
        switch self {
        case .excellent: "star.circle.fill"
        case .good: "checkmark.circle.fill"
        case .needsImprovement: "exclamationmark.circle.fill"
        }
    }
}
