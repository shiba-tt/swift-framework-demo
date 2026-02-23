import Foundation

/// 調理セッションとレシピ管理を担当するマネージャー
@MainActor
@Observable
final class CookingManager {
    static let shared = CookingManager()

    // MARK: - Observable State

    private(set) var recipes: [Recipe] = Recipe.samples
    private(set) var activeSession: CookingSession?
    private(set) var recentCommands: [VoiceCommand] = []
    private(set) var favoriteRecipeIds: Set<UUID> = []

    private var timerTask: Task<Void, Never>?

    private init() {
        // 最初の 2 レシピをお気に入りに設定
        for recipe in recipes.prefix(2) {
            favoriteRecipeIds.insert(recipe.id)
        }
    }

    // MARK: - Session Management

    func startCooking(recipe: Recipe, servings: Int? = nil) {
        stopTimer()
        activeSession = CookingSession(recipe: recipe, adjustedServings: servings)
        addCommand(
            command: "「\(recipe.name)」を作り始めて",
            response: "\(recipe.name)の調理を開始します。\(recipe.steps.count)ステップ、約\(recipe.totalTimeText)です。",
            type: .searchRecipe
        )
    }

    func endSession() {
        stopTimer()
        activeSession = nil
    }

    // MARK: - Step Navigation

    func nextStep() {
        guard var session = activeSession, !session.isLastStep else { return }
        stopTimer()
        session.currentStepIndex += 1
        activeSession = session

        if let step = session.currentStep {
            addCommand(
                command: "次のステップ",
                response: "ステップ\(step.order): \(step.instruction)",
                type: .nextStep
            )
            if step.hasTimer {
                startStepTimer()
            }
        }
    }

    func previousStep() {
        guard var session = activeSession, !session.isFirstStep else { return }
        stopTimer()
        session.currentStepIndex -= 1
        activeSession = session

        if let step = session.currentStep {
            addCommand(
                command: "前のステップに戻って",
                response: "ステップ\(step.order)に戻ります: \(step.instruction)",
                type: .previousStep
            )
        }
    }

    func repeatCurrentStep() {
        guard let session = activeSession, let step = session.currentStep else { return }
        addCommand(
            command: "もう一回",
            response: "ステップ\(step.order): \(step.instruction)",
            type: .repeatStep
        )
    }

    // MARK: - Timer

    func startStepTimer() {
        guard var session = activeSession,
              let step = session.currentStep,
              let seconds = step.timerSeconds else { return }

        stopTimer()
        session.timerRemainingSeconds = seconds
        session.isTimerRunning = true
        activeSession = session

        addCommand(
            command: "タイマー\(step.timerText ?? "")",
            response: "タイマーを\(step.timerText ?? "")にセットしました。",
            type: .startTimer
        )

        timerTask = Task { [weak self] in
            while let self, var currentSession = self.activeSession,
                  let remaining = currentSession.timerRemainingSeconds,
                  remaining > 0, currentSession.isTimerRunning {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                currentSession.timerRemainingSeconds = remaining - 1
                if remaining - 1 <= 0 {
                    currentSession.isTimerRunning = false
                    currentSession.timerRemainingSeconds = 0
                }
                self.activeSession = currentSession
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        if var session = activeSession {
            session.isTimerRunning = false
            activeSession = session
        }
    }

    func queryTimer() {
        guard let session = activeSession else { return }
        if let remaining = session.timerRemainingText, session.isTimerRunning {
            addCommand(
                command: "タイマー何分？",
                response: "残り\(remaining)です。",
                type: .askTimer
            )
        } else {
            addCommand(
                command: "タイマー何分？",
                response: "現在タイマーは動いていません。",
                type: .askTimer
            )
        }
    }

    // MARK: - Servings Adjustment

    func adjustServings(_ newServings: Int) {
        guard var session = activeSession else { return }
        let oldServings = session.adjustedServings
        session.adjustedServings = newServings
        activeSession = session

        addCommand(
            command: "\(newServings)人分に変更して",
            response: "\(oldServings)人分 → \(newServings)人分に変更しました。分量が自動調整されます。",
            type: .adjustServings
        )
    }

    // MARK: - Favorites

    func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipeIds.contains(recipe.id) {
            favoriteRecipeIds.remove(recipe.id)
        } else {
            favoriteRecipeIds.insert(recipe.id)
        }
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipeIds.contains(recipe.id)
    }

    // MARK: - Query

    func searchRecipes(keyword: String) -> [Recipe] {
        guard !keyword.isEmpty else { return recipes }
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(keyword) }
    }

    var recipesByCategory: [(category: RecipeCategory, recipes: [Recipe])] {
        let grouped = Dictionary(grouping: recipes, by: \.category)
        return RecipeCategory.allCases.compactMap { category in
            guard let recipes = grouped[category], !recipes.isEmpty else { return nil }
            return (category: category, recipes: recipes)
        }
    }

    // MARK: - Private

    private func addCommand(command: String, response: String, type: VoiceCommand.CommandType) {
        let cmd = VoiceCommand(command: command, response: response, type: type)
        recentCommands.insert(cmd, at: 0)
        if var session = activeSession {
            session.voiceCommandLog.insert(cmd, at: 0)
            activeSession = session
        }
        // 最新 20 件のみ保持
        if recentCommands.count > 20 {
            recentCommands = Array(recentCommands.prefix(20))
        }
    }
}
