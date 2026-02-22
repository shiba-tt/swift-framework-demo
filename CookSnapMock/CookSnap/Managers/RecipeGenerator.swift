import Foundation
import FoundationModels

// MARK: - RecipeGenerator（Foundation Models によるオンデバイスレシピ生成）

@MainActor
@Observable
final class RecipeGenerator {
    static let shared = RecipeGenerator()

    private(set) var isAvailable = false
    private(set) var isGenerating = false
    private(set) var generationProgress: String?

    private init() {
        checkAvailability()
    }

    // MARK: - 利用可能性チェック

    func checkAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            isAvailable = true
        case .unavailable(let reason):
            isAvailable = false
            switch reason {
            case .deviceNotEligible:
                generationProgress = "このデバイスは Apple Intelligence に対応していません"
            case .appleIntelligenceNotEnabled:
                generationProgress = "Apple Intelligence を有効にしてください"
            case .modelNotReady:
                generationProgress = "モデルをダウンロード中..."
            @unknown default:
                generationProgress = "Foundation Models を利用できません"
            }
        }
    }

    // MARK: - レシピ生成

    /// 食材リストからレシピを生成する
    func generateRecipe(from ingredients: [Ingredient]) async throws -> GeneratedRecipe {
        guard isAvailable else {
            throw RecipeGeneratorError.modelUnavailable
        }

        isGenerating = true
        generationProgress = "レシピを考案中..."
        defer {
            isGenerating = false
            generationProgress = nil
        }

        let ingredientNames = ingredients.map(\.name).joined(separator: ", ")

        let session = LanguageModelSession(
            instructions: """
            You are a creative Japanese home cooking assistant. \
            Given a list of available ingredients, suggest a delicious recipe \
            that can be made using only those ingredients and common seasonings \
            (salt, pepper, soy sauce, mirin, sake, sugar, oil, vinegar, miso). \
            All output text must be in Japanese. \
            Keep steps concise and practical. \
            DO NOT suggest recipes requiring ingredients not in the list.
            """
        )

        let recipe: GeneratedRecipe = try await session.respond(
            to: "以下の食材で作れるレシピを提案してください:\n\n\(ingredientNames)",
            generating: GeneratedRecipe.self
        )

        return recipe
    }

    // MARK: - ストリーミング生成

    /// ストリーミングでレシピを段階的に生成する
    func generateRecipeStreaming(
        from ingredients: [Ingredient],
        onPartialUpdate: @escaping (PartiallyGenerated<GeneratedRecipe>) -> Void
    ) async throws -> GeneratedRecipe {
        guard isAvailable else {
            throw RecipeGeneratorError.modelUnavailable
        }

        isGenerating = true
        generationProgress = "レシピを考案中..."
        defer {
            isGenerating = false
            generationProgress = nil
        }

        let ingredientNames = ingredients.map(\.name).joined(separator: ", ")

        let session = LanguageModelSession(
            instructions: """
            You are a creative Japanese home cooking assistant. \
            Given a list of available ingredients, suggest a delicious recipe \
            that can be made using only those ingredients and common seasonings. \
            All output text must be in Japanese. \
            Keep steps concise and practical.
            """
        )

        let stream = session.streamResponse(
            to: "以下の食材で作れるレシピを提案してください:\n\n\(ingredientNames)",
            generating: GeneratedRecipe.self
        )

        for try await partial in stream {
            onPartialUpdate(partial)

            if let name = partial.name {
                generationProgress = "考案中: \(name)..."
            }
        }

        // 最終結果を一括取得
        let recipe: GeneratedRecipe = try await session.respond(
            to: "以下の食材で作れるレシピを提案してください:\n\n\(ingredientNames)",
            generating: GeneratedRecipe.self
        )

        return recipe
    }

    // MARK: - モデルのプリウォーム

    func prewarmModel() async {
        do {
            let session = LanguageModelSession()
            try await session.prewarm()
        } catch {
            // プリウォーム失敗は無視
        }
    }
}

// MARK: - RecipeGeneratorError

enum RecipeGeneratorError: Error, LocalizedError {
    case modelUnavailable
    case generationFailure
    case noIngredients

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Foundation Models が利用できません。Apple Intelligence 対応デバイスが必要です。"
        case .generationFailure:
            "レシピの生成に失敗しました。もう一度お試しください。"
        case .noIngredients:
            "食材を選択してください。"
        }
    }
}
