import Foundation

/// 個別の料理
struct Dish: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let category: DishCategory
    /// 推定カロリー（kcal）
    let calories: Int
    /// タンパク質（g）
    let protein: Double
    /// 脂質（g）
    let fat: Double
    /// 炭水化物（g）
    let carbs: Double
    /// AI の確信度（0.0〜1.0）
    let confidence: Double

    /// カロリーレベル
    var calorieLevel: CalorieLevel {
        switch calories {
        case ..<200: .low
        case 200..<500: .moderate
        case 500..<800: .high
        default: .veryHigh
        }
    }
}

/// 料理のカテゴリ
enum DishCategory: String, Sendable, CaseIterable {
    case japanese = "和食"
    case western = "洋食"
    case chinese = "中華"
    case korean = "韓国料理"
    case other = "その他"

    var emoji: String {
        switch self {
        case .japanese: "🍱"
        case .western: "🍝"
        case .chinese: "🥟"
        case .korean: "🍜"
        case .other: "🍽️"
        }
    }
}

/// カロリーレベル
enum CalorieLevel: String, Sendable {
    case low = "低カロリー"
    case moderate = "適量"
    case high = "高カロリー"
    case veryHigh = "要注意"

    var colorName: String {
        switch self {
        case .low: "green"
        case .moderate: "blue"
        case .high: "orange"
        case .veryHigh: "red"
        }
    }
}
