import SwiftUI

struct SummaryView: View {
    @Bindable var viewModel: KakeiboViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthlyOverview
                    categoryBreakdown
                    dailyAverageCard
                    intentsInfoCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("レポート")
        }
    }

    // MARK: - Monthly Overview

    private var monthlyOverview: some View {
        VStack(spacing: 16) {
            Text(viewModel.monthlySummary.displayTitle)
                .font(.headline)

            Text("¥\(viewModel.formatted(viewModel.monthlyTotal))")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            Text("\(viewModel.currentMonthExpenses.count) 件の支出")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別内訳")
                .font(.headline)

            let categories = viewModel.monthlySummary.byCategory

            if categories.isEmpty {
                Text("データがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(categories, id: \.category) { item in
                    categoryRow(item.category, amount: item.amount)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func categoryRow(_ category: ExpenseCategory, amount: Int) -> some View {
        let ratio = viewModel.monthlyTotal > 0
            ? Double(amount) / Double(viewModel.monthlyTotal) : 0

        return VStack(spacing: 6) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                    .frame(width: 24)

                Text(category.displayName)
                    .font(.subheadline)

                Spacer()

                Text("¥\(viewModel.formatted(amount))")
                    .font(.subheadline.bold())

                Text(String(format: "%.0f%%", ratio * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.gray.opacity(0.1))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(category.color)
                        .frame(width: geometry.size.width * ratio)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Daily Average

    private var dailyAverageCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("日平均")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("¥\(viewModel.formatted(viewModel.monthlySummary.dailyAverage))")
                    .font(.title3.bold())
            }
            .frame(maxWidth: .infinity)

            Divider()

            VStack(spacing: 4) {
                Text("残り予算")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("¥\(viewModel.formatted(viewModel.remainingBudget))")
                    .font(.title3.bold())
                    .foregroundStyle(viewModel.remainingBudget > 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Intents Info

    private var intentsInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("App Intents 対応", systemImage: "wand.and.stars")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                intentExample(
                    icon: "mic",
                    phrase: "「かけいぼ でランチ 850円」",
                    description: "Siri で音声入力"
                )
                intentExample(
                    icon: "magnifyingglass",
                    phrase: "「かけいぼ で今月いくら使った？」",
                    description: "Spotlight / Siri で確認"
                )
                intentExample(
                    icon: "square.grid.2x2",
                    phrase: "「かけいぼ の食費はいくら？」",
                    description: "カテゴリ別の集計"
                )
                intentExample(
                    icon: "rectangle.on.rectangle",
                    phrase: "Control Center に追加",
                    description: "ワンタップで記録"
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func intentExample(icon: String, phrase: String, description: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(phrase)
                    .font(.caption.bold())
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
