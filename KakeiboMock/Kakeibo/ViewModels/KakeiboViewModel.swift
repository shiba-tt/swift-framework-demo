import Foundation

// MARK: - KakeiboViewModel

@MainActor
@Observable
final class KakeiboViewModel {

    // MARK: - State

    var quickInputText = ""
    var showingAddSheet = false
    var addAmount = ""
    var addMemo = ""
    var addCategory: ExpenseCategory = .food
    var selectedTab = 0
    var lastAddedMessage: String?
    var showingMessage = false

    // MARK: - Dependencies

    private let expenseManager = ExpenseManager.shared

    // MARK: - Computed

    var expenses: [Expense] {
        expenseManager.expenses
    }

    var currentMonthExpenses: [Expense] {
        expenseManager.expensesForCurrentMonth()
    }

    var monthlySummary: MonthlySummary {
        expenseManager.monthlySummary()
    }

    var budget: Budget {
        expenseManager.budget
    }

    var monthlyTotal: Int {
        expenseManager.totalForCurrentMonth()
    }

    var budgetUsageRatio: Double {
        budget.usageRatio(spent: monthlyTotal)
    }

    var remainingBudget: Int {
        budget.remainingBudget(spent: monthlyTotal)
    }

    var todayExpenses: [Expense] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDateInToday($0.date) }
    }

    var todayTotal: Int {
        todayExpenses.reduce(0) { $0 + $1.amount }
    }

    var recentExpenses: [Expense] {
        Array(expenses.prefix(10))
    }

    var groupedByDate: [(date: String, expenses: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")

        let grouped = Dictionary(grouping: currentMonthExpenses) { expense in
            formatter.string(from: expense.date)
        }

        return grouped.map { (date: $0.key, expenses: $0.value) }
            .sorted { lhs, rhs in
                guard let lDate = lhs.expenses.first?.date,
                      let rDate = rhs.expenses.first?.date else { return false }
                return lDate > rDate
            }
    }

    // MARK: - Actions

    func quickAdd() {
        guard !quickInputText.isEmpty else { return }

        if let expense = expenseManager.parseAndAddExpense(from: quickInputText) {
            lastAddedMessage = "¥\(formatted(expense.amount)) \(expense.category.displayName)「\(expense.memo)」を記録"
            showingMessage = true
            quickInputText = ""
        } else {
            lastAddedMessage = "金額を読み取れませんでした"
            showingMessage = true
        }
    }

    func addExpense() {
        guard let amount = Int(addAmount), amount > 0 else { return }
        expenseManager.addExpense(amount: amount, category: addCategory, memo: addMemo)
        resetAddForm()
        showingAddSheet = false
    }

    func deleteExpense(_ expense: Expense) {
        expenseManager.deleteExpense(expense)
    }

    func dismissMessage() {
        showingMessage = false
        lastAddedMessage = nil
    }

    // MARK: - Private

    private func resetAddForm() {
        addAmount = ""
        addMemo = ""
        addCategory = .food
    }

    func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
