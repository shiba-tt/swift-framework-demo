import CoreML
import Foundation
import Vision

/// Core ML + Vision を使った食事画像の分類・栄養素推定
@MainActor
@Observable
final class FoodClassificationManager {
    static let shared = FoodClassificationManager()

    // MARK: - State

    /// 分析中かどうか
    private(set) var isAnalyzing = false

    /// 最新の分析結果
    private(set) var latestResult: FoodAnalysisResult?

    /// エラーメッセージ
    private(set) var errorMessage: String?

    private init() {}

    // MARK: - Analysis

    /// 食事画像を分析して料理を識別し栄養素を推定する
    func analyzeFood() async -> FoodAnalysisResult {
        isAnalyzing = true
        errorMessage = nil

        // モックの分析遅延
        try? await Task.sleep(for: .seconds(1.5))

        let result = generateMockAnalysis()
        latestResult = result
        isAnalyzing = false
        return result
    }

    /// OCR でパッケージの栄養表示を読み取る
    func recognizeNutritionLabel() async -> NutritionLabelResult? {
        isAnalyzing = true

        try? await Task.sleep(for: .seconds(1.0))

        let result = NutritionLabelResult(
            productName: "グリーンサラダ",
            servingSize: "1パック (120g)",
            calories: 85,
            protein: 3.2,
            fat: 4.5,
            carbs: 8.1,
            sodium: 0.3,
            confidence: 0.92
        )

        isAnalyzing = false
        return result
    }

    // MARK: - Mock Data

    private func generateMockAnalysis() -> FoodAnalysisResult {
        let patterns: [(dishes: [Dish], advice: String)] = [
            (
                dishes: [
                    Dish(name: "鮭の塩焼き", category: .japanese, calories: 180, protein: 22.3, fat: 8.5, carbs: 0.1, confidence: 0.95),
                    Dish(name: "白ご飯", category: .japanese, calories: 252, protein: 3.8, fat: 0.5, carbs: 55.7, confidence: 0.98),
                    Dish(name: "味噌汁", category: .japanese, calories: 40, protein: 3.2, fat: 1.2, carbs: 4.5, confidence: 0.90),
                    Dish(name: "ほうれん草のおひたし", category: .japanese, calories: 25, protein: 2.8, fat: 0.3, carbs: 3.1, confidence: 0.85),
                ],
                advice: "バランスの良い和定食です。タンパク質と野菜が十分に摂れています。"
            ),
            (
                dishes: [
                    Dish(name: "ハンバーグ", category: .western, calories: 450, protein: 25.0, fat: 28.5, carbs: 18.2, confidence: 0.93),
                    Dish(name: "ライス", category: .other, calories: 252, protein: 3.8, fat: 0.5, carbs: 55.7, confidence: 0.97),
                    Dish(name: "コーンスープ", category: .western, calories: 95, protein: 2.1, fat: 4.8, carbs: 11.5, confidence: 0.88),
                ],
                advice: "脂質がやや多めです。サラダを追加するとバランスが改善します。"
            ),
            (
                dishes: [
                    Dish(name: "麻婆豆腐", category: .chinese, calories: 280, protein: 15.5, fat: 18.0, carbs: 12.3, confidence: 0.91),
                    Dish(name: "チャーハン", category: .chinese, calories: 520, protein: 12.0, fat: 15.5, carbs: 78.0, confidence: 0.94),
                    Dish(name: "餃子 (5個)", category: .chinese, calories: 250, protein: 10.0, fat: 12.0, carbs: 25.0, confidence: 0.89),
                ],
                advice: "炭水化物と脂質が多めです。次の食事は野菜中心にすると良いでしょう。"
            ),
            (
                dishes: [
                    Dish(name: "アサイーボウル", category: .other, calories: 350, protein: 6.0, fat: 8.0, carbs: 65.0, confidence: 0.87),
                    Dish(name: "グラノーラ", category: .other, calories: 180, protein: 4.5, fat: 6.0, carbs: 28.0, confidence: 0.85),
                ],
                advice: "ビタミンと食物繊維が豊富です。タンパク質を補うためにヨーグルトを追加すると良いでしょう。"
            ),
            (
                dishes: [
                    Dish(name: "ビビンバ", category: .korean, calories: 580, protein: 22.0, fat: 16.0, carbs: 82.0, confidence: 0.92),
                    Dish(name: "キムチ", category: .korean, calories: 15, protein: 1.0, fat: 0.2, carbs: 2.5, confidence: 0.96),
                    Dish(name: "わかめスープ", category: .korean, calories: 30, protein: 2.0, fat: 1.0, carbs: 3.0, confidence: 0.88),
                ],
                advice: "発酵食品（キムチ）が含まれ腸内環境に良い食事です。"
            ),
        ]

        let selected = patterns.randomElement()!
        return FoodAnalysisResult(
            dishes: selected.dishes,
            healthAdvice: selected.advice,
            analysisDate: Date()
        )
    }
}

/// 食事分析結果
struct FoodAnalysisResult: Sendable {
    let dishes: [Dish]
    let healthAdvice: String
    let analysisDate: Date

    var totalCalories: Int {
        dishes.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        dishes.reduce(0) { $0 + $1.protein }
    }

    var totalFat: Double {
        dishes.reduce(0) { $0 + $1.fat }
    }

    var totalCarbs: Double {
        dishes.reduce(0) { $0 + $1.carbs }
    }

    var averageConfidence: Double {
        guard !dishes.isEmpty else { return 0 }
        return dishes.reduce(0) { $0 + $1.confidence } / Double(dishes.count)
    }
}

/// 栄養表示 OCR 結果
struct NutritionLabelResult: Sendable {
    let productName: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let sodium: Double
    let confidence: Double
}
