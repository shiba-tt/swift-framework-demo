import Foundation
import SwiftUI

// MARK: - ExpenseCategory

enum ExpenseCategory: String, Sendable, CaseIterable, Identifiable {
    case food
    case transport
    case entertainment
    case shopping
    case utilities
    case health
    case education
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .food: "食費"
        case .transport: "交通費"
        case .entertainment: "娯楽"
        case .shopping: "買い物"
        case .utilities: "光熱費"
        case .health: "医療"
        case .education: "教育"
        case .other: "その他"
        }
    }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "tram.fill"
        case .entertainment: "gamecontroller.fill"
        case .shopping: "bag.fill"
        case .utilities: "bolt.fill"
        case .health: "cross.case.fill"
        case .education: "book.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: .orange
        case .transport: .blue
        case .entertainment: .purple
        case .shopping: .pink
        case .utilities: .yellow
        case .health: .red
        case .education: .green
        case .other: .gray
        }
    }

    /// キーワードからカテゴリを推定する
    static func infer(from text: String) -> ExpenseCategory {
        let lowered = text.lowercased()
        let mappings: [(keywords: [String], category: ExpenseCategory)] = [
            (["ランチ", "ディナー", "カフェ", "コンビニ", "レストラン", "スーパー", "弁当", "食事", "コーヒー", "パン"], .food),
            (["電車", "バス", "タクシー", "駐車", "ガソリン", "定期", "交通", "Suica", "PASMO"], .transport),
            (["映画", "ゲーム", "カラオケ", "ライブ", "飲み会", "遊び"], .entertainment),
            (["服", "靴", "雑貨", "Amazon", "家電", "ネット通販", "ショッピング"], .shopping),
            (["電気", "ガス", "水道", "通信", "スマホ", "Wi-Fi", "家賃"], .utilities),
            (["病院", "薬局", "薬", "歯医者", "クリニック", "処方"], .health),
            (["本", "セミナー", "講座", "参考書", "塾", "オンライン学習"], .education),
        ]

        for mapping in mappings {
            if mapping.keywords.contains(where: { lowered.contains($0.lowercased()) }) {
                return mapping.category
            }
        }
        return .other
    }
}

// MARK: - Expense

struct Expense: Identifiable, Sendable {
    let id: UUID
    let amount: Int
    let category: ExpenseCategory
    let memo: String
    let date: Date

    init(
        id: UUID = UUID(),
        amount: Int,
        category: ExpenseCategory,
        memo: String,
        date: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.memo = memo
        self.date = date
    }
}

// MARK: - MonthlySummary

struct MonthlySummary: Sendable {
    let year: Int
    let month: Int
    let expenses: [Expense]

    var totalAmount: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var byCategory: [(category: ExpenseCategory, amount: Int)] {
        let grouped = Dictionary(grouping: expenses, by: \.category)
        return ExpenseCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            let total = items.reduce(0) { $0 + $1.amount }
            return (category, total)
        }
        .sorted { $0.amount > $1.amount }
    }

    var dailyAverage: Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 0
        }
        guard range.count > 0 else { return 0 }
        return totalAmount / range.count
    }

    var displayTitle: String {
        "\(year)年\(month)月"
    }
}

// MARK: - Budget

struct Budget: Sendable {
    let monthlyLimit: Int
    let categoryLimits: [ExpenseCategory: Int]

    init(monthlyLimit: Int = 150_000, categoryLimits: [ExpenseCategory: Int] = [:]) {
        self.monthlyLimit = monthlyLimit
        self.categoryLimits = categoryLimits
    }

    func remainingBudget(spent: Int) -> Int {
        monthlyLimit - spent
    }

    func usageRatio(spent: Int) -> Double {
        guard monthlyLimit > 0 else { return 0 }
        return min(Double(spent) / Double(monthlyLimit), 1.0)
    }
}
