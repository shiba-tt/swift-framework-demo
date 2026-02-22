import SwiftUI

/// 週間リズムレポート画面
struct WeeklyReportView: View {
    let viewModel: ChronoSenseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if let weekly = viewModel.weeklyRhythm {
                    VStack(spacing: 20) {
                        // 週間サマリー
                        WeeklySummaryCard(weekly: weekly, isImproving: viewModel.isImproving)

                        // 日別スコア一覧
                        DailyScoreList(
                            profiles: weekly.profiles,
                            selectedDay: Binding(
                                get: { viewModel.selectedDay },
                                set: { viewModel.selectedDay = $0 }
                            )
                        )

                        // 睡眠リズム
                        SleepRhythmCard(weekly: weekly)

                        // スコア変動
                        ScoreTrendCard(profiles: weekly.profiles)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "データなし",
                        systemImage: "chart.bar",
                        description: Text("週間データがまだ収集されていません")
                    )
                }
            }
            .navigationTitle("週間レポート")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Weekly Summary Card

private struct WeeklySummaryCard: View {
    let weekly: WeeklyRhythm
    let isImproving: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今週のリズムスコア")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: isImproving ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                    Text(isImproving ? "改善傾向" : "低下傾向")
                }
                .font(.caption)
                .foregroundStyle(isImproving ? .green : .orange)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(weekly.averageScore)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("/ 100")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 16) {
                WeeklyStatBadge(
                    label: "最高",
                    value: "\(weekly.mostStableDay?.rhythmScore ?? 0)",
                    color: .green
                )
                WeeklyStatBadge(
                    label: "最低",
                    value: "\(weekly.leastStableDay?.rhythmScore ?? 0)",
                    color: .orange
                )
                WeeklyStatBadge(
                    label: "変動幅",
                    value: String(format: "%.1f", weekly.scoreVariance),
                    color: .blue
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct WeeklyStatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Daily Score List

private struct DailyScoreList: View {
    let profiles: [CircadianProfile]
    @Binding var selectedDay: CircadianProfile?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M/d (E)"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別スコア")
                .font(.headline)

            ForEach(profiles) { profile in
                Button {
                    selectedDay = profile
                } label: {
                    HStack {
                        Text(dateFormatter.string(from: profile.date))
                            .font(.subheadline)

                        Spacer()

                        // スコアバー
                        GeometryReader { geometry in
                            let width = geometry.size.width * Double(profile.rhythmScore) / 100.0
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(profile.scoreLevel.colorName).opacity(0.3))
                                .frame(width: width)
                        }
                        .frame(width: 100, height: 12)

                        Text("\(profile.rhythmScore)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color(profile.scoreLevel.colorName))
                            .frame(width: 36, alignment: .trailing)

                        if let change = profile.changeFromPrevious {
                            HStack(spacing: 1) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                Text("\(abs(change))")
                            }
                            .font(.caption2)
                            .foregroundStyle(change >= 0 ? .green : .red)
                            .frame(width: 32, alignment: .trailing)
                        } else {
                            Spacer()
                                .frame(width: 32)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        selectedDay?.id == profile.id
                            ? Color(.systemGray5)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Sleep Rhythm Card

private struct SleepRhythmCard: View {
    let weekly: WeeklyRhythm

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠リズム")
                .font(.headline)

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    Text("平均就寝")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(weekly.averageSleepOnsetHour):00")
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Image(systemName: "sun.horizon.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("平均起床")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(weekly.averageWakeHour):00")
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Image(systemName: "bed.double.fill")
                        .font(.title2)
                        .foregroundStyle(.indigo)
                    Text("推定睡眠")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let sleepDuration = (weekly.averageWakeHour + 24 - weekly.averageSleepOnsetHour) % 24
                    Text("\(sleepDuration)h")
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Score Trend Card

private struct ScoreTrendCard: View {
    let profiles: [CircadianProfile]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スコア推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(profiles) { profile in
                    VStack(spacing: 4) {
                        Text("\(profile.rhythmScore)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(profile.scoreLevel.colorName))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(profile.scoreLevel.colorName).opacity(0.6))
                            .frame(height: CGFloat(profile.rhythmScore) * 1.2)

                        Text(dayLabel(profile.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
