import Foundation
import FoundationModels

// MARK: - Recipe（Foundation Models による構造化出力）

@Generable
struct GeneratedRecipe {
    @Guide(description: "Name of the dish in Japanese")
    var name: String

    @Guide(description: "Difficulty level of the recipe")
    var difficulty: Difficulty

    @Guide(description: "Cooking time in minutes", .range(5...120))
    var cookingTimeMinutes: Int

    @Guide(description: "List of cooking steps in Japanese (3-6 steps)")
    var steps: [String]

    @Guide(description: "Estimated calories per serving", .range(50...2000))
    var estimatedCalories: Int
}

// MARK: - Difficulty（難易度）

@Generable
enum Difficulty: String, Sendable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"

    var displayName: String {
        switch self {
        case .easy:   "簡単"
        case .medium: "普通"
        case .hard:   "本格的"
        }
    }

    var emoji: String {
        switch self {
        case .easy:   "🟢"
        case .medium: "🟡"
        case .hard:   "🔴"
        }
    }

    var stars: String {
        switch self {
        case .easy:   "★☆☆"
        case .medium: "★★☆"
        case .hard:   "★★★"
        }
    }
}

// MARK: - RecipeEntry（保存用のレシピエントリ）

struct RecipeEntry: Identifiable, Sendable {
    let id = UUID()
    let recipe: GeneratedRecipe
    let ingredients: [Ingredient]
    let createdAt: Date

    var ingredientNames: String {
        ingredients.map(\.name).joined(separator: "、")
    }

    var cookingTimeText: String {
        if recipe.cookingTimeMinutes >= 60 {
            let hours = recipe.cookingTimeMinutes / 60
            let mins = recipe.cookingTimeMinutes % 60
            return mins > 0 ? "\(hours)時間\(mins)分" : "\(hours)時間"
        }
        return "\(recipe.cookingTimeMinutes)分"
    }

    var caloriesText: String {
        "\(recipe.estimatedCalories) kcal"
    }
}
