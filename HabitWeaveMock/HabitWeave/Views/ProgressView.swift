import SwiftUI

/// 週間進捗とカレンダーヒートマップ画面
struct ProgressView: View {
    @Bindable var viewModel: HabitWeaveViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weeklyOverviewCard
                    weeklyChartCard
                    habitBreakdownCard
                    calendarInsightsCard
                }
                .padding()
            }
            .navigationTitle("進捗")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Weekly Overview

    private var weeklyOverviewCard: some View {
        HStack(spacing: 16) {
            overviewItem(
                emoji: "✅",
                label: "週間達成率",
                value: viewModel.weeklyProgress?.completionRateText ?? "0%"
            )
            Divider().frame(height: 40)
            overviewItem(
                emoji: "🔥",
                label: "連続達成",
                value: "\(viewModel.currentStreak)日"
            )
            Divider().frame(height: 40)
            overviewItem(
                emoji: "📊",
                label: "アクティブ",
                value: "\(viewModel.activeHabits.count)件"
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func overviewItem(emoji: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間チャート")
                .font(.headline)

            if let progress = viewModel.weeklyProgress {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(progress.dailyRecords) { day in
                        VStack(spacing: 4) {
                            // バー
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 80)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor(for: day.completionRate))
                                    .frame(height: max(4, 80 * day.completionRate))
                            }
                            .frame(maxWidth: .infinity)

                            // 数値
                            Text("\(day.completedHabits)/\(day.totalHabits)")
                                .font(.system(size: 8))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)

                            // 曜日
                            Text(day.dayOfWeekText)
                                .font(.caption2)
                                .fontWeight(Calendar.current.isDateInToday(day.date) ? .bold : .regular)
                                .foregroundStyle(Calendar.current.isDateInToday(day.date) ? .primary : .secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Habit Breakdown

    private var habitBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("習慣別の達成状況")
                .font(.headline)

            ForEach(viewModel.activeHabits) { habit in
                habitProgressRow(habit)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func habitProgressRow(_ habit: Habit) -> some View {
        let weeklyCount = viewModel.weeklyCompletionCount(for: habit)
        let target = habit.frequency.timesPerWeek
        let rate = target > 0 ? Double(weeklyCount) / Double(target) : 0

        return HStack(spacing: 12) {
            Text(habit.category.emoji)
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(weeklyCount)/\(target)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor(for: rate))
                            .frame(width: geometry.size.width * min(1.0, rate), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Calendar Insights

    private var calendarInsightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カレンダー分析")
                .font(.headline)

            VStack(spacing: 8) {
                insightRow(
                    emoji: "📅",
                    label: "今日の予定",
                    value: "\(viewModel.todayEvents.count)件"
                )
                insightRow(
                    emoji: "🕐",
                    label: "空き時間合計",
                    value: viewModel.totalFreeTimeText
                )
                insightRow(
                    emoji: "📋",
                    label: "配置済み習慣",
                    value: "\(viewModel.scheduledHabits.count)件"
                )
                insightRow(
                    emoji: "⚡",
                    label: "空き時間活用率",
                    value: freeTimeUsageText
                )
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func insightRow(emoji: String, label: String, value: String) -> some View {
        HStack {
            Text(emoji)
                .font(.caption)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    private var freeTimeUsageText: String {
        let usedMinutes = viewModel.scheduledHabits.reduce(0) { $0 + $1.habit.durationMinutes }
        let total = viewModel.totalFreeMinutes
        guard total > 0 else { return "0%" }
        let rate = Int(Double(usedMinutes) / Double(total) * 100)
        return "\(rate)%"
    }

    // MARK: - Helpers

    private func barColor(for rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.5 { return .yellow }
        return .orange
    }
}

#Preview {
    ProgressView(viewModel: HabitWeaveViewModel())
}
