import AppIntents
import Foundation

// MARK: - ExpenseCategoryAppEnum

enum ExpenseCategoryAppEnum: String, AppEnum {
    case food
    case transport
    case entertainment
    case shopping
    case utilities
    case health
    case education
    case other

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "カテゴリ")

    static var caseDisplayRepresentations: [ExpenseCategoryAppEnum: DisplayRepresentation] = [
        .food: "食費",
        .transport: "交通費",
        .entertainment: "娯楽",
        .shopping: "買い物",
        .utilities: "光熱費",
        .health: "医療",
        .education: "教育",
        .other: "その他",
    ]

    var toExpenseCategory: ExpenseCategory {
        switch self {
        case .food: .food
        case .transport: .transport
        case .entertainment: .entertainment
        case .shopping: .shopping
        case .utilities: .utilities
        case .health: .health
        case .education: .education
        case .other: .other
        }
    }
}

// MARK: - AddExpenseIntent

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "支出を記録"
    static var description = IntentDescription("家計簿に支出を追加します")
    static var openAppWhenRun = false

    @Parameter(title: "金額")
    var amount: Int

    @Parameter(title: "メモ")
    var memo: String

    @Parameter(title: "カテゴリ", default: .food)
    var category: ExpenseCategoryAppEnum

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = ExpenseManager.shared
        manager.addExpense(
            amount: amount,
            category: category.toExpenseCategory,
            memo: memo
        )

        let categoryName = category.toExpenseCategory.displayName
        return .result(
            dialog: "¥\(amount) を \(categoryName) として記録しました"
        )
    }
}

// MARK: - QuickAddExpenseIntent

struct QuickAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "かんたん支出記録"
    static var description = IntentDescription("テキストから支出を自動解析して記録します（例: ランチ 850円）")
    static var openAppWhenRun = false

    @Parameter(title: "入力テキスト")
    var inputText: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = ExpenseManager.shared
        guard let expense = manager.parseAndAddExpense(from: inputText) else {
            return .result(dialog: "金額を読み取れませんでした。「ランチ 850円」のように入力してください")
        }

        let categoryName = expense.category.displayName
        return .result(
            dialog: "¥\(expense.amount) を \(categoryName)「\(expense.memo)」として記録しました"
        )
    }
}
