import SwiftUI

/// 気分を記録するメインビュー
struct MoodInputView: View {
    let viewModel: MoodBoardViewModel
    @State private var noteText = ""
    @State private var showNote = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 今日の気分カード
                    TodayMoodCard(
                        mood: viewModel.todayMood,
                        hasRecorded: viewModel.hasRecordedToday
                    )

                    // 気分選択ボタン
                    MoodSelectionSection(viewModel: viewModel)

                    // 連続記録
                    StreakCard(
                        streak: viewModel.stats.streakDays,
                        longestStreak: viewModel.stats.longestStreak
                    )

                    // 週間ムードグラフ
                    WeeklyMoodGraph(weeklyMoods: viewModel.weeklyMoods)

                    // 直近の記録
                    RecentEntriesSection(entries: viewModel.recentEntries(count: 5))
                }
                .padding()
            }
            .navigationTitle("MoodBoard")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Today Mood Card

private struct TodayMoodCard: View {
    let mood: MoodType?
    let hasRecorded: Bool

    var body: some View {
        VStack(spacing: 12) {
            if let mood {
                Text(mood.emoji)
                    .font(.system(size: 64))

                Text(mood.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("今日の気分を記録しました")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("😊")
                    .font(.system(size: 64))
                    .opacity(0.3)

                Text("今の気分は？")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("下のボタンから気分を選んでください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Mood Selection Section

private struct MoodSelectionSection: View {
    let viewModel: MoodBoardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("気分を選ぶ")
                .font(.headline)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    MoodButton(mood: mood) {
                        viewModel.recordMood(mood)
                    }
                }
            }
        }
    }
}

private struct MoodButton: View {
    let mood: MoodType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                Text(mood.displayName)
                    .font(.system(size: 9))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(mood.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Card

private struct StreakCard: View {
    let streak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(streak)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.pink)
                Text("連続記録")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text("\(longestStreak)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                Text("最長記録")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Weekly Mood Graph

private struct WeeklyMoodGraph: View {
    let weeklyMoods: [(weekday: String, mood: MoodType?)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週のムード")
                .font(.headline)
                .padding(.leading, 4)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weeklyMoods.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 4) {
                        if let mood = item.mood {
                            Text(mood.emoji)
                                .font(.title3)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(mood.color.gradient)
                                .frame(height: CGFloat(mood.score) / 5 * 60)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundStyle(.tertiary)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                        }

                        Text(item.weekday)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Recent Entries Section

private struct RecentEntriesSection: View {
    let entries: [MoodEntry]

    var body: some View {
        if entries.isEmpty { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Text("最近の記録")
                    .font(.headline)
                    .padding(.leading, 4)

                ForEach(entries) { entry in
                    HStack(spacing: 12) {
                        Text(entry.mood.emoji)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.mood.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(entry.dateText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(entry.timeText)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(entry.mood.color.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        )
    }
}
