import SwiftUI

struct ExpenseListView: View {
    @Bindable var viewModel: KakeiboViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.groupedByDate, id: \.date) { group in
                    Section {
                        ForEach(group.expenses) { expense in
                            expenseRow(expense)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteExpense(expense)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        HStack {
                            Text(group.date)
                            Spacer()
                            let dayTotal = group.expenses.reduce(0) { $0 + $1.amount }
                            Text("¥\(viewModel.formatted(dayTotal))")
                                .font(.caption.bold())
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("支出一覧")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if viewModel.currentMonthExpenses.isEmpty {
                    ContentUnavailableView(
                        "支出データなし",
                        systemImage: "yensign.circle",
                        description: Text("今月の支出を記録しましょう")
                    )
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddExpenseView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Expense Row

    private func expenseRow(_ expense: Expense) -> some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .font(.body)
                .foregroundStyle(expense.category.color)
                .frame(width: 32, height: 32)
                .background(expense.category.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.memo)
                    .font(.subheadline)

                Text(expense.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("¥\(viewModel.formatted(expense.amount))")
                .font(.subheadline.bold())
        }
        .padding(.vertical, 2)
    }
}
