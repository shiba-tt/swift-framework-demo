import Foundation

// MARK: - ExpenseManager

@MainActor
@Observable
final class ExpenseManager {
    static let shared = ExpenseManager()

    private(set) var expenses: [Expense] = []
    var budget = Budget()

    private init() {
        expenses = Self.generateSampleExpenses()
    }

    // MARK: - CRUD

    func addExpense(amount: Int, category: ExpenseCategory, memo: String, date: Date = .now) {
        let expense = Expense(amount: amount, category: category, memo: memo, date: date)
        expenses.insert(expense, at: 0)
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }

    // MARK: - Queries

    func expensesForCurrentMonth() -> [Expense] {
        let calendar = Calendar.current
        let now = Date.now
        return expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
    }

    func expensesForCurrentWeek() -> [Expense] {
        let calendar = Calendar.current
        let now = Date.now
        return expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
    }

    func totalForCurrentMonth() -> Int {
        expensesForCurrentMonth().reduce(0) { $0 + $1.amount }
    }

    func totalByCategory(for category: ExpenseCategory) -> Int {
        expensesForCurrentMonth()
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func monthlySummary() -> MonthlySummary {
        let calendar = Calendar.current
        let now = Date.now
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return MonthlySummary(year: year, month: month, expenses: expensesForCurrentMonth())
    }

    // MARK: - Smart Input

    func parseAndAddExpense(from text: String) -> Expense? {
        let components = text.components(separatedBy: CharacterSet.whitespaces)

        var amount: Int?
        var memo = ""

        for component in components {
            let cleaned = component
                .replacingOccurrences(of: "円", with: "")
                .replacingOccurrences(of: "¥", with: "")
                .replacingOccurrences(of: ",", with: "")

            if let parsed = Int(cleaned), parsed > 0 {
                amount = parsed
            } else if !component.isEmpty {
                if !memo.isEmpty { memo += " " }
                memo += component
            }
        }

        guard let finalAmount = amount else { return nil }

        let category = ExpenseCategory.infer(from: memo)
        let expense = Expense(amount: finalAmount, category: category, memo: memo)
        expenses.insert(expense, at: 0)
        return expense
    }

    // MARK: - Sample Data

    private static func generateSampleExpenses() -> [Expense] {
        let calendar = Calendar.current
        let now = Date.now

        let sampleData: [(Int, ExpenseCategory, String, Int)] = [
            (850, .food, "ランチ 定食屋", 0),
            (350, .food, "コンビニ おにぎり", 0),
            (1200, .entertainment, "映画 レイトショー", -1),
            (270, .transport, "電車 通勤", 0),
            (4500, .shopping, "ユニクロ Tシャツ", -1),
            (680, .food, "カフェ コーヒー＆ケーキ", -2),
            (15000, .utilities, "スマホ料金 3月分", -3),
            (1500, .food, "スーパー 食材まとめ買い", -2),
            (540, .transport, "バス 往復", -3),
            (3200, .health, "歯医者 定期検診", -4),
            (980, .food, "ラーメン 味噌", -4),
            (2500, .education, "技術書 Swift入門", -5),
            (450, .food, "コンビニ 夜食", -5),
            (1800, .entertainment, "カラオケ 2時間", -6),
            (270, .transport, "電車 通勤", -6),
            (620, .food, "パン屋 朝食", -7),
            (8500, .shopping, "Amazon ガジェット", -7),
            (750, .food, "弁当 テイクアウト", -8),
            (1100, .food, "ディナー パスタ", -9),
            (350, .food, "自販機 飲料", -10),
        ]

        return sampleData.map { amount, category, memo, dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
            return Expense(amount: amount, category: category, memo: memo, date: date)
        }
    }
}
