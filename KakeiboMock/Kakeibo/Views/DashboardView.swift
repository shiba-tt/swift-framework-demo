import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: KakeiboViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    quickInputSection
                    budgetCard
                    todaySummaryCard
                    recentExpensesSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("かけいぼ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddExpenseView(viewModel: viewModel)
            }
            .overlay(alignment: .top) {
                if viewModel.showingMessage, let message = viewModel.lastAddedMessage {
                    messageToast(message)
                }
            }
        }
    }

    // MARK: - Quick Input

    private var quickInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("かんたん入力")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("ランチ 850円", text: $viewModel.quickInputText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.quickAdd()
                    }

                if !viewModel.quickInputText.isEmpty {
                    Button {
                        viewModel.quickAdd()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(12)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

            Text("Spotlight / Siri: 「かけいぼ でランチ 850円」")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Budget Card

    private var budgetCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.monthlySummary.displayTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("¥\(viewModel.formatted(viewModel.monthlyTotal))")
                        .font(.system(.title, design: .rounded, weight: .bold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("残り予算")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("¥\(viewModel.formatted(viewModel.remainingBudget))")
                        .font(.headline)
                        .foregroundStyle(viewModel.remainingBudget > 0 ? .green : .red)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.gray.opacity(0.15))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(budgetBarColor)
                        .frame(width: geometry.size.width * viewModel.budgetUsageRatio)
                }
            }
            .frame(height: 12)

            HStack {
                Text(String(format: "%.0f%%", viewModel.budgetUsageRatio * 100))
                    .font(.caption.bold())
                    .foregroundStyle(budgetBarColor)
                Spacer()
                Text("予算 ¥\(viewModel.formatted(viewModel.budget.monthlyLimit))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var budgetBarColor: Color {
        switch viewModel.budgetUsageRatio {
        case 0..<0.5: .green
        case 0.5..<0.8: .orange
        default: .red
        }
    }

    // MARK: - Today Summary

    private var todaySummaryCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の支出")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("¥\(viewModel.formatted(viewModel.todayTotal))")
                    .font(.title3.bold())
            }

            Spacer()

            Text("\(viewModel.todayExpenses.count) 件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Recent Expenses

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近の支出")
                    .font(.headline)

                Spacer()

                Button("すべて見る") {
                    viewModel.selectedTab = 1
                }
                .font(.caption)
            }

            ForEach(viewModel.recentExpenses) { expense in
                expenseRow(expense)
            }
        }
    }

    private func expenseRow(_ expense: Expense) -> some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .font(.body)
                .foregroundStyle(expense.category.color)
                .frame(width: 36, height: 36)
                .background(expense.category.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.memo)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(expense.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("¥\(viewModel.formatted(expense.amount))")
                    .font(.subheadline.bold())

                Text(relativeDate(expense.date))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Toast

    private func messageToast(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation {
                        viewModel.dismissMessage()
                    }
                }
            }
    }

    // MARK: - Helpers

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "今日" }
        if calendar.isDateInYesterday(date) { return "昨日" }

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
