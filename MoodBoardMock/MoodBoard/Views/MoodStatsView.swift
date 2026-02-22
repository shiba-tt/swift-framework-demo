import SwiftUI

/// 気分の統計ビュー
struct MoodStatsView: View {
    let viewModel: MoodBoardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 週間スコアカード
                    WeeklyScoreCard(stats: viewModel.stats)

                    // 気分の分布
                    MoodDistributionSection(stats: viewModel.stats)

                    // 記録サマリー
                    RecordingSummaryCard(stats: viewModel.stats)

                    // ウィジェット案内
                    WidgetGuideCard()
                }
                .padding()
            }
            .navigationTitle("統計")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Weekly Score Card

private struct WeeklyScoreCard: View {
    let stats: MoodStats

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: stats.weeklyLevel.systemImageName)
                    .foregroundStyle(levelColor)
                Text(stats.weeklyLevel.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(String(format: "%.1f", stats.weeklyAverageScore))
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("週間平均スコア")
                .font(.caption)
                .foregroundStyle(.secondary)

            // 先週比
            if stats.weeklyScoreChange != 0 {
                HStack(spacing: 4) {
                    Image(systemName: stats.weeklyScoreChange > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text(String(format: "%+.1f", stats.weeklyScoreChange))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("先週比")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .foregroundStyle(stats.weeklyScoreChange > 0 ? .green : .orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background((stats.weeklyScoreChange > 0 ? Color.green : .orange).opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var levelColor: Color {
        switch stats.weeklyLevel {
        case .excellent: .yellow
        case .good: .green
        case .average: .gray
        case .low: .blue
        case .concern: .red
        }
    }
}

// MARK: - Mood Distribution

private struct MoodDistributionSection: View {
    let stats: MoodStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("気分の分布")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(MoodType.allCases, id: \.self) { mood in
                MoodDistributionRow(
                    mood: mood,
                    count: stats.moodCounts[mood] ?? 0,
                    distribution: stats.distribution(for: mood),
                    isDominant: mood == stats.dominantMood
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct MoodDistributionRow: View {
    let mood: MoodType
    let count: Int
    let distribution: Double
    let isDominant: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(mood.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mood.displayName)
                        .font(.subheadline)
                        .fontWeight(isDominant ? .bold : .medium)
                    if isDominant {
                        Text("最多")
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.pink.opacity(0.15))
                            .foregroundStyle(.pink)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text("\(count)回")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(mood.color.gradient)
                            .frame(width: geometry.size.width * distribution, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

// MARK: - Recording Summary

private struct RecordingSummaryCard: View {
    let stats: MoodStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録サマリー")
                .font(.headline)
                .padding(.leading, 4)

            HStack(spacing: 16) {
                SummaryMetric(
                    icon: "note.text",
                    value: "\(stats.totalEntries)",
                    label: "総記録数",
                    color: .pink
                )

                Divider()
                    .frame(height: 40)

                SummaryMetric(
                    icon: "flame.fill",
                    value: "\(stats.streakDays)",
                    label: "連続日数",
                    color: .orange
                )

                Divider()
                    .frame(height: 40)

                SummaryMetric(
                    icon: "trophy.fill",
                    value: "\(stats.longestStreak)",
                    label: "最長連続",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct SummaryMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget Guide

private struct WidgetGuideCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "apps.iphone")
                    .foregroundStyle(.pink)
                Text("ウィジェットで記録しよう")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("ホーム画面にウィジェットを追加すると、アプリを開かずに気分を記録できます。ウィジェットの気分ボタンをタップするだけ！")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("ロック画面ウィジェットで連続記録日数と今日の気分もチェックできます。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.pink.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
