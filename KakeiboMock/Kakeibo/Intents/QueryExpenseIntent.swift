import AppIntents
import Foundation

// MARK: - QueryMonthlyTotalIntent

struct QueryMonthlyTotalIntent: AppIntent {
    static var title: LocalizedStringResource = "今月の支出を確認"
    static var description = IntentDescription("今月の合計支出額を確認します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = ExpenseManager.shared
        let total = manager.totalForCurrentMonth()
        let summary = manager.monthlySummary()
        let remaining = manager.budget.remainingBudget(spent: total)

        var message = "今月の支出は ¥\(formatted(total)) です。"
        message += " 残り予算は ¥\(formatted(remaining)) です。"

        if let top = summary.byCategory.first {
            message += " 最も多いのは\(top.category.displayName)で ¥\(formatted(top.amount)) です。"
        }

        return .result(dialog: "\(message)")
    }

    private func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - QueryWeeklyTotalIntent

struct QueryWeeklyTotalIntent: AppIntent {
    static var title: LocalizedStringResource = "今週の支出を確認"
    static var description = IntentDescription("今週の合計支出額を確認します")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = ExpenseManager.shared
        let weeklyExpenses = manager.expensesForCurrentWeek()
        let total = weeklyExpenses.reduce(0) { $0 + $1.amount }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: total)) ?? "\(total)"

        return .result(
            dialog: "今週の支出は ¥\(formatted)（\(weeklyExpenses.count)件）です"
        )
    }
}

// MARK: - QueryCategoryTotalIntent

struct QueryCategoryTotalIntent: AppIntent {
    static var title: LocalizedStringResource = "カテゴリ別支出を確認"
    static var description = IntentDescription("特定カテゴリの今月の支出額を確認します")
    static var openAppWhenRun = false

    @Parameter(title: "カテゴリ")
    var category: ExpenseCategoryAppEnum

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = ExpenseManager.shared
        let total = manager.totalByCategory(for: category.toExpenseCategory)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: total)) ?? "\(total)"

        let categoryName = category.toExpenseCategory.displayName
        return .result(
            dialog: "今月の\(categoryName)は ¥\(formatted) です"
        )
    }
}
