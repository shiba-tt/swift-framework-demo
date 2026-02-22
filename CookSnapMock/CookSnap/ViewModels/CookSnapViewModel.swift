import Foundation

/// CookSnap のメイン ViewModel
@MainActor
@Observable
final class CookSnapViewModel {
    private let generator = RecipeGenerator.shared

    // MARK: - UI State

    var selectedTab: AppTab = .scan

    enum AppTab: String, CaseIterable, Sendable {
        case scan = "スキャン"
        case recipe = "レシピ"
        case history = "履歴"

        var systemImageName: String {
            switch self {
            case .scan:    return "camera.fill"
            case .recipe:  return "fork.knife"
            case .history: return "clock.fill"
            }
        }
    }

    // MARK: - State

    var detectedIngredients: [Ingredient] = []
    var selectedIngredients: Set<Ingredient> = []
    var currentRecipe: RecipeEntry?
    var recipeHistory: [RecipeEntry] = []
    var errorMessage: String?

    var isGenerating: Bool { generator.isGenerating }
    var isModelAvailable: Bool { generator.isAvailable }
    var generationProgress: String? { generator.generationProgress }

    var selectedIngredientNames: String {
        selectedIngredients.map(\.name).joined(separator: "、")
    }

    var ingredientsByCategory: [(category: IngredientCategory, ingredients: [Ingredient])] {
        let grouped = Dictionary(grouping: detectedIngredients) { $0.category }
        return grouped
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (category: $0.key, ingredients: $0.value) }
    }

    // MARK: - Actions

    /// カメラ撮影をシミュレーション（Vision による食材認識のモック）
    func scanFridge() async {
        // モック: Vision フレームワークによる食材認識をシミュレーション
        try? await Task.sleep(for: .seconds(1.5))
        detectedIngredients = Ingredient.randomFridgeContents()
        selectedIngredients = Set(detectedIngredients)
    }

    /// 食材の選択/解除を切り替え
    func toggleIngredient(_ ingredient: Ingredient) {
        if selectedIngredients.contains(ingredient) {
            selectedIngredients.remove(ingredient)
        } else {
            selectedIngredients.insert(ingredient)
        }
    }

    /// 全選択/全解除
    func toggleSelectAll() {
        if selectedIngredients.count == detectedIngredients.count {
            selectedIngredients.removeAll()
        } else {
            selectedIngredients = Set(detectedIngredients)
        }
    }

    /// レシピを生成
    func generateRecipe() async {
        guard !selectedIngredients.isEmpty else {
            errorMessage = "食材を選択してください"
            return
        }

        errorMessage = nil
        let ingredients = Array(selectedIngredients)

        do {
            let recipe = try await generator.generateRecipe(from: ingredients)
            let entry = RecipeEntry(
                recipe: recipe,
                ingredients: ingredients,
                createdAt: Date()
            )
            currentRecipe = entry
            recipeHistory.insert(entry, at: 0)
            selectedTab = .recipe
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// モデルのプリウォーム
    func prewarmModel() async {
        await generator.prewarmModel()
    }
}
