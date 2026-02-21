import SwiftUI

/// メンタルヘルスのダッシュボードビュー
struct DashboardView: View {
    let viewModel: MindMirrorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // スコアカード
                    ScoreCard(score: viewModel.todayScore)

                    // 記録ステータス
                    RecordingStatusCard(viewModel: viewModel)

                    // HealthKit 統合データ
                    HealthSummaryCard(
                        steps: viewModel.todaySteps,
                        sleepMinutes: viewModel.lastSleepMinutes
                    )

                    // インサイト一覧
                    if !viewModel.todayInsights.isEmpty {
                        InsightsSection(insights: viewModel.todayInsights)
                    }

                    // サブスコア一覧
                    if let score = viewModel.todayScore {
                        SubScoresSection(subScores: score.subScores)
                    }
                }
                .padding()
            }
            .navigationTitle("MindMirror")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Score Card

private struct ScoreCard: View {
    let score: MentalHealthScore?

    var body: some View {
        VStack(spacing: 12) {
            if let score {
                // スコア表示
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: Double(score.overallScore) / 100)
                        .stroke(
                            colorForLevel(score.level).gradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Text("\(score.overallScore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text(score.level.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)

                // トレンド
                HStack(spacing: 4) {
                    Image(systemName: score.trend.systemImageName)
                    Text(score.trend.rawValue)
                }
                .font(.caption)
                .foregroundStyle(colorForTrend(score.trend))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(colorForTrend(score.trend).opacity(0.1))
                .clipShape(Capsule())
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("データを収集中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 120)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorForLevel(_ level: ScoreLevel) -> Color {
        switch level {
        case .excellent: .blue
        case .good: .green
        case .moderate: .yellow
        case .caution: .orange
        case .concern: .red
        }
    }

    private func colorForTrend(_ trend: Trend) -> Color {
        switch trend {
        case .improving: .green
        case .stable: .blue
        case .declining: .orange
        }
    }
}

// MARK: - Recording Status

private struct RecordingStatusCard: View {
    let viewModel: MindMirrorViewModel

    var body: some View {
        HStack {
            Circle()
                .fill(viewModel.isRecording ? .green : .gray)
                .frame(width: 10, height: 10)
            Text(viewModel.isRecording ? "センサー記録中" : "記録停止中")
                .font(.subheadline)

            Spacer()

            Button {
                viewModel.toggleRecording()
            } label: {
                Text(viewModel.isRecording ? "停止" : "開始")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(viewModel.isRecording ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                    .foregroundStyle(viewModel.isRecording ? .red : .green)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Health Summary

private struct HealthSummaryCard: View {
    let steps: Int
    let sleepMinutes: Int

    var body: some View {
        HStack(spacing: 16) {
            HealthMetric(
                icon: "figure.walk",
                value: formatSteps(steps),
                label: "歩数",
                color: .orange
            )
            Divider()
            HealthMetric(
                icon: "bed.double.fill",
                value: formatSleep(sleepMinutes),
                label: "睡眠",
                color: .indigo
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return String(format: "%.1fk", Double(steps) / 1000)
        }
        return "\(steps)"
    }

    private func formatSleep(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h\(mins)m"
    }
}

private struct HealthMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Insights Section

private struct InsightsSection: View {
    let insights: [Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日の気づき")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(insights) { insight in
                InsightRow(insight: insight)
            }
        }
    }
}

private struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: insight.type.systemImageName)
                .foregroundStyle(colorForInsight(insight.type))
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorForInsight(insight.type).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorForInsight(_ type: InsightType) -> Color {
        switch type {
        case .positive: .green
        case .neutral: .blue
        case .warning: .orange
        }
    }
}

// MARK: - Sub Scores Section

private struct SubScoresSection: View {
    let subScores: [SubScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("カテゴリ別スコア")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(subScores) { subScore in
                SubScoreRow(subScore: subScore)
            }
        }
    }
}

private struct SubScoreRow: View {
    let subScore: SubScore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subScore.category.systemImageName)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(subScore.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(subScore.score)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                ProgressView(value: Double(subScore.score), total: 100)
                    .tint(colorForScore(subScore.score))

                Text(subScore.category.description)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 70...: .green
        case 50..<70: .yellow
        case 35..<50: .orange
        default: .red
        }
    }
}
