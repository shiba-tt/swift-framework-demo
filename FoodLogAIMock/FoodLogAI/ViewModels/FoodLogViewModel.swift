import Foundation
import SwiftUI

/// FoodLogAI アプリのメイン ViewModel
@MainActor
@Observable
final class FoodLogViewModel {

    // MARK: - State

    private(set) var todayNutrition: DailyNutrition?
    private(set) var weeklyHistory: [DailyNutrition] = []
    private(set) var latestAnalysis: FoodAnalysisResult?
    private(set) var isLoading = false
    var showingAnalysisResult = false
    var showingCamera = false
    var selectedMealType: MealType = .lunch
    var nutritionTarget = NutritionTarget.defaultMale

    // MARK: - Dependencies

    let cameraManager = CameraManager()
    private let classificationManager = FoodClassificationManager.shared

    // MARK: - Computed Properties

    /// 今日の総カロリー
    var todayCalories: Int {
        todayNutrition?.totalCalories ?? 0
    }

    /// 目標に対するカロリー達成率
    var calorieProgress: Double {
        todayNutrition?.calorieProgress(target: nutritionTarget.calorieTarget) ?? 0
    }

    /// 今日のPFC
    var todayProtein: Double { todayNutrition?.totalProtein ?? 0 }
    var todayFat: Double { todayNutrition?.totalFat ?? 0 }
    var todayCarbs: Double { todayNutrition?.totalCarbs ?? 0 }

    /// 今日の食事記録
    var todayMeals: [Meal] {
        todayNutrition?.meals ?? []
    }

    /// 分析中かどうか
    var isAnalyzing: Bool {
        classificationManager.isAnalyzing
    }

    /// 健康アドバイス
    var healthAdvice: String {
        todayNutrition?.healthAdvice ?? "食事を記録してアドバイスを受けましょう"
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true
        generateMockData()
        isLoading = false
    }

    /// 食事写真を分析する
    func analyzePhoto() async {
        let result = await classificationManager.analyzeFood()
        latestAnalysis = result
        showingAnalysisResult = true
    }

    /// 分析結果から食事を記録する
    func recordMeal(from analysis: FoodAnalysisResult, mealType: MealType) {
        let meal = Meal(
            id: UUID(),
            date: Date(),
            mealType: mealType,
            dishes: analysis.dishes,
            photoId: UUID().uuidString
        )

        if var nutrition = todayNutrition {
            var meals = nutrition.meals
            meals.append(meal)
            todayNutrition = DailyNutrition(
                date: nutrition.date,
                meals: meals
            )
        } else {
            todayNutrition = DailyNutrition(
                date: Date(),
                meals: [meal]
            )
        }

        latestAnalysis = nil
        showingAnalysisResult = false
    }

    /// 食事を削除する
    func removeMeal(_ meal: Meal) {
        guard var nutrition = todayNutrition else { return }
        var meals = nutrition.meals
        meals.removeAll { $0.id == meal.id }
        todayNutrition = DailyNutrition(
            date: nutrition.date,
            meals: meals
        )
    }

    // MARK: - Mock Data Generation

    private func generateMockData() {
        let calendar = Calendar.current
        let today = Date()

        // 今日の食事
        let todayMeals: [Meal] = [
            Meal(
                id: UUID(),
                date: calendar.date(bySettingHour: 7, minute: 30, second: 0, of: today)!,
                mealType: .breakfast,
                dishes: [
                    Dish(name: "トースト", category: .western, calories: 190, protein: 5.5, fat: 3.0, carbs: 35.0, confidence: 0.95),
                    Dish(name: "目玉焼き", category: .western, calories: 90, protein: 6.2, fat: 7.0, carbs: 0.3, confidence: 0.93),
                    Dish(name: "コーヒー", category: .other, calories: 5, protein: 0.2, fat: 0.0, carbs: 0.8, confidence: 0.97),
                ],
                photoId: "breakfast_001"
            ),
            Meal(
                id: UUID(),
                date: calendar.date(bySettingHour: 12, minute: 15, second: 0, of: today)!,
                mealType: .lunch,
                dishes: [
                    Dish(name: "親子丼", category: .japanese, calories: 570, protein: 28.0, fat: 12.5, carbs: 82.0, confidence: 0.92),
                    Dish(name: "味噌汁", category: .japanese, calories: 40, protein: 3.2, fat: 1.2, carbs: 4.5, confidence: 0.90),
                ],
                photoId: "lunch_001"
            ),
        ]

        todayNutrition = DailyNutrition(date: today, meals: todayMeals)

        // 過去7日分の履歴
        weeklyHistory = (1...7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let meals = generateRandomMeals(for: date)
            return DailyNutrition(date: date, meals: meals)
        }
    }

    private func generateRandomMeals(for date: Date) -> [Meal] {
        let calendar = Calendar.current
        var meals: [Meal] = []

        // 朝食
        meals.append(Meal(
            id: UUID(),
            date: calendar.date(bySettingHour: Int.random(in: 6...8), minute: Int.random(in: 0...59), second: 0, of: date)!,
            mealType: .breakfast,
            dishes: [
                Dish(name: ["納豆ご飯", "トースト", "グラノーラ", "おにぎり"].randomElement()!,
                     category: .japanese, calories: Int.random(in: 200...350),
                     protein: Double.random(in: 5...15), fat: Double.random(in: 2...10),
                     carbs: Double.random(in: 30...55), confidence: Double.random(in: 0.85...0.98)),
            ],
            photoId: nil
        ))

        // 昼食
        meals.append(Meal(
            id: UUID(),
            date: calendar.date(bySettingHour: Int.random(in: 11...13), minute: Int.random(in: 0...59), second: 0, of: date)!,
            mealType: .lunch,
            dishes: [
                Dish(name: ["カレーライス", "ラーメン", "定食", "パスタ", "サンドイッチ"].randomElement()!,
                     category: [.japanese, .western, .chinese].randomElement()!, calories: Int.random(in: 450...750),
                     protein: Double.random(in: 15...30), fat: Double.random(in: 10...25),
                     carbs: Double.random(in: 50...90), confidence: Double.random(in: 0.85...0.95)),
            ],
            photoId: nil
        ))

        // 夕食
        meals.append(Meal(
            id: UUID(),
            date: calendar.date(bySettingHour: Int.random(in: 18...20), minute: Int.random(in: 0...59), second: 0, of: date)!,
            mealType: .dinner,
            dishes: [
                Dish(name: ["焼き魚定食", "ハンバーグ", "鍋", "唐揚げ", "刺身定食"].randomElement()!,
                     category: [.japanese, .western].randomElement()!, calories: Int.random(in: 500...800),
                     protein: Double.random(in: 20...35), fat: Double.random(in: 10...30),
                     carbs: Double.random(in: 40...80), confidence: Double.random(in: 0.85...0.95)),
                Dish(name: ["サラダ", "味噌汁", "スープ"].randomElement()!,
                     category: .japanese, calories: Int.random(in: 20...80),
                     protein: Double.random(in: 1...5), fat: Double.random(in: 0.5...5),
                     carbs: Double.random(in: 3...12), confidence: Double.random(in: 0.80...0.95)),
            ],
            photoId: nil
        ))

        return meals
    }
}
