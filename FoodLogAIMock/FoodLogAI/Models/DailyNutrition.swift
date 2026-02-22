import Foundation

/// 1日の栄養摂取サマリー
struct DailyNutrition: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let meals: [Meal]

    /// 1日の総カロリー
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    /// 1日の総タンパク質（g）
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.totalProtein }
    }

    /// 1日の総脂質（g）
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.totalFat }
    }

    /// 1日の総炭水化物（g）
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.totalCarbs }
    }

    /// 目標カロリーに対する達成率
    func calorieProgress(target: Int) -> Double {
        guard target > 0 else { return 0 }
        return min(1.5, Double(totalCalories) / Double(target))
    }

    /// 食事回数
    var mealCount: Int {
        meals.count
    }

    /// 食事タイプ別のカロリー
    func calories(for mealType: MealType) -> Int {
        meals.filter { $0.mealType == mealType }.reduce(0) { $0 + $1.totalCalories }
    }

    /// 健康アドバイス
    var healthAdvice: String {
        if totalCalories < 1200 {
            return "摂取カロリーが少なめです。バランスの良い食事を心がけましょう。"
        } else if totalCalories > 2500 {
            return "摂取カロリーが多めです。間食を控えめにすると良いでしょう。"
        } else if totalProtein < 50 {
            return "タンパク質が不足気味です。肉・魚・大豆製品を積極的に摂りましょう。"
        } else {
            return "バランスの良い食事が取れています。この調子を維持しましょう。"
        }
    }
}

/// 栄養目標
struct NutritionTarget: Sendable {
    let calorieTarget: Int
    let proteinTarget: Double
    let fatTarget: Double
    let carbsTarget: Double

    static let defaultMale = NutritionTarget(
        calorieTarget: 2200,
        proteinTarget: 65,
        fatTarget: 60,
        carbsTarget: 300
    )

    static let defaultFemale = NutritionTarget(
        calorieTarget: 1800,
        proteinTarget: 50,
        fatTarget: 50,
        carbsTarget: 250
    )
}
