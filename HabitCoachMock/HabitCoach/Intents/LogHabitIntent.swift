import AppIntents

/// 習慣を記録する App Intent
struct LogHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "習慣を記録"
    static var description = IntentDescription("習慣の完了を記録します")
    static var openAppWhenRun = false

    @Parameter(title: "習慣名")
    var habitName: String

    @Parameter(title: "回数", default: 1)
    var count: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = HabitManager.shared
        if let habit = manager.habits.first(where: { $0.name == habitName }) {
            manager.logHabit(habit, value: count)
            let progress = manager.todayProgress(for: habit)
            let completed = manager.isCompleted(habit)

            if completed {
                return .result(dialog: "\(habitName) 完了！今日の目標を達成しました 🎉")
            } else {
                return .result(dialog: "\(habitName) を記録しました（\(progress)/\(habit.targetCount) \(habit.unit)）")
            }
        }
        return .result(dialog: "\(habitName) が見つかりませんでした")
    }
}

/// 習慣カテゴリの AppEnum
enum HabitCategoryAppEnum: String, AppEnum {
    case health
    case exercise
    case mindfulness
    case learning
    case productivity
    case social

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "カテゴリ")

    static var caseDisplayRepresentations: [HabitCategoryAppEnum: DisplayRepresentation] = [
        .health: "健康",
        .exercise: "運動",
        .mindfulness: "マインドフルネス",
        .learning: "学習",
        .productivity: "生産性",
        .social: "社交",
    ]

    var toHabitCategory: HabitCategory {
        switch self {
        case .health: .health
        case .exercise: .exercise
        case .mindfulness: .mindfulness
        case .learning: .learning
        case .productivity: .productivity
        case .social: .social
        }
    }
}
