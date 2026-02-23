import AppIntents

/// 次のステップへ進む Live Activity Intent
struct NextStepIntent: AppIntent {
    static var title: LocalizedStringResource = "次のステップ"
    static var description = IntentDescription("レシピの次のステップへ進みます")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        manager.nextStep()
        if let step = manager.activeSession?.currentStep {
            return .result(dialog: "ステップ\(step.order): \(step.instruction)")
        }
        return .result(dialog: "最後のステップです")
    }
}

/// 前のステップに戻る Intent
struct PreviousStepIntent: AppIntent {
    static var title: LocalizedStringResource = "前のステップ"
    static var description = IntentDescription("レシピの前のステップに戻ります")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        manager.previousStep()
        if let step = manager.activeSession?.currentStep {
            return .result(dialog: "ステップ\(step.order): \(step.instruction)")
        }
        return .result(dialog: "最初のステップです")
    }
}

/// 現在のステップを読み上げる Intent
struct RepeatStepIntent: AppIntent {
    static var title: LocalizedStringResource = "もう一回"
    static var description = IntentDescription("現在のステップをもう一度読み上げます")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        manager.repeatCurrentStep()
        if let step = manager.activeSession?.currentStep {
            return .result(dialog: "ステップ\(step.order): \(step.instruction)")
        }
        return .result(dialog: "調理中のレシピがありません")
    }
}

/// タイマーをセットする Intent
struct StartTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "タイマーセット"
    static var description = IntentDescription("現在のステップのタイマーを開始します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        if let step = manager.activeSession?.currentStep, let timerText = step.timerText {
            manager.startStepTimer()
            return .result(dialog: "\(timerText)のタイマーを開始しました")
        }
        return .result(dialog: "このステップにはタイマーが設定されていません")
    }
}

/// レシピを検索する Intent
struct SearchRecipeIntent: AppIntent {
    static var title: LocalizedStringResource = "レシピを検索"
    static var description = IntentDescription("キーワードでレシピを検索します")
    static var openAppWhenRun = false

    @Parameter(title: "キーワード")
    var keyword: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        let results = manager.searchRecipes(keyword: keyword)
        if results.isEmpty {
            return .result(dialog: "「\(keyword)」に一致するレシピが見つかりませんでした")
        }
        let names = results.map(\.name).joined(separator: "、")
        return .result(dialog: "見つかったレシピ: \(names)")
    }
}

/// 分量を変更する Intent
struct AdjustServingsIntent: AppIntent {
    static var title: LocalizedStringResource = "分量を変更"
    static var description = IntentDescription("レシピの人数を変更して分量を再計算します")
    static var openAppWhenRun = false

    @Parameter(title: "人数", default: 2)
    var servings: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = CookingManager.shared
        guard manager.activeSession != nil else {
            return .result(dialog: "調理中のレシピがありません")
        }
        manager.adjustServings(servings)
        return .result(dialog: "\(servings)人分に変更しました。分量が自動で調整されます。")
    }
}
