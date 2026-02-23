import Foundation

/// 調理セッションの状態
struct CookingSession: Identifiable, Sendable {
    let id: UUID
    let recipe: Recipe
    var currentStepIndex: Int
    var adjustedServings: Int
    var startedAt: Date
    var timerRemainingSeconds: Int?
    var isTimerRunning: Bool
    var voiceCommandLog: [VoiceCommand]

    init(
        id: UUID = UUID(),
        recipe: Recipe,
        adjustedServings: Int? = nil
    ) {
        self.id = id
        self.recipe = recipe
        self.currentStepIndex = 0
        self.adjustedServings = adjustedServings ?? recipe.servings
        self.startedAt = Date()
        self.timerRemainingSeconds = nil
        self.isTimerRunning = false
        self.voiceCommandLog = []
    }

    var currentStep: RecipeStep? {
        guard currentStepIndex >= 0, currentStepIndex < recipe.steps.count else { return nil }
        return recipe.steps[currentStepIndex]
    }

    var nextStep: RecipeStep? {
        let nextIndex = currentStepIndex + 1
        guard nextIndex < recipe.steps.count else { return nil }
        return recipe.steps[nextIndex]
    }

    var isFirstStep: Bool {
        currentStepIndex == 0
    }

    var isLastStep: Bool {
        currentStepIndex == recipe.steps.count - 1
    }

    var progressRatio: Double {
        guard !recipe.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(recipe.steps.count)
    }

    var servingsMultiplier: Double {
        Double(adjustedServings) / Double(recipe.servings)
    }

    var timerRemainingText: String? {
        guard let seconds = timerRemainingSeconds else { return nil }
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

/// 音声コマンドのログ
struct VoiceCommand: Identifiable, Sendable {
    let id: UUID
    let command: String
    let response: String
    let timestamp: Date
    let type: CommandType

    init(
        id: UUID = UUID(),
        command: String,
        response: String,
        timestamp: Date = Date(),
        type: CommandType
    ) {
        self.id = id
        self.command = command
        self.response = response
        self.timestamp = timestamp
        self.type = type
    }

    enum CommandType: String, Sendable {
        case nextStep = "次のステップ"
        case previousStep = "前のステップ"
        case repeatStep = "もう一回"
        case startTimer = "タイマー開始"
        case adjustServings = "分量変更"
        case searchRecipe = "レシピ検索"
        case askTimer = "タイマー確認"
    }
}
