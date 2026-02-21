import SwiftUI

/// 週間レポートビュー
struct WeeklyReportView: View {
    let viewModel: MindMirrorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 週間サマリー
                    if let summary = viewModel.weeklySummary {
                        WeeklySummaryCard(summary: summary)
                    }

                    // スコアトレンドグラフ
                    if !viewModel.weeklyReports.isEmpty {
                        ScoreTrendChart(reports: viewModel.weeklyReports)
                    }

                    // 日別レポート一覧
                    if !viewModel.weeklyReports.isEmpty {
                        DailyReportsSection(reports: viewModel.weeklyReports)
                    }
                }
                .padding()
            }
            .navigationTitle("週間レポート")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Weekly Summary Card

private struct WeeklySummaryCard: View {
    let summary: WeeklySummary

    var body: some View {
        VStack(spacing: 12) {
            Text(summary.weekText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(summary.averageScore)")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("週間平均スコア")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                if let best = summary.bestDay {
                    VStack(spacing: 4) {
                        Text("最高")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(best.score.overallScore)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text(best.shortDateText)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Divider()
                    .frame(height: 40)

                if let worst = summary.worstDay {
                    VStack(spacing: 4) {
                        Text("最低")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(worst.score.overallScore)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text(worst.shortDateText)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Score Trend Chart

private struct ScoreTrendChart: View {
    let reports: [DailyReport]

    private var maxScore: Int {
        reports.map(\.score.overallScore).max() ?? 100
    }

    private var minScore: Int {
        reports.map(\.score.overallScore).min() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スコア推移")
                .font(.headline)
                .padding(.leading, 4)

            // 簡易バーグラフ
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(reports) { report in
                    VStack(spacing: 4) {
                        Text("\(report.score.overallScore)")
                            .font(.caption2)
                            .fontWeight(.medium)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(for: report.score.overallScore).gradient)
                            .frame(
                                height: CGFloat(report.score.overallScore) / 100 * 120
                            )

                        Text(report.shortDateText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(for score: Int) -> Color {
        switch score {
        case 70...: .green
        case 50..<70: .yellow
        case 35..<50: .orange
        default: .red
        }
    }
}

// MARK: - Daily Reports Section

private struct DailyReportsSection: View {
    let reports: [DailyReport]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("日別詳細")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(reports.reversed()) { report in
                DailyReportRow(report: report)
            }
        }
    }
}

private struct DailyReportRow: View {
    let report: DailyReport

    var body: some View {
        HStack(spacing: 12) {
            // スコア
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: Double(report.score.overallScore) / 100)
                    .stroke(
                        scoreColor(report.score.overallScore).gradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(report.score.overallScore)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(width: 44, height: 44)

            // 日付と概要
            VStack(alignment: .leading, spacing: 4) {
                Text(report.dateText)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    if let typing = report.metrics.typing {
                        Label(
                            String(format: "%.0f WPM", typing.averageWPM),
                            systemImage: "keyboard.fill"
                        )
                    }
                    if let mobility = report.metrics.mobility {
                        Label(
                            "\(mobility.visitedPlaceCount)箇所",
                            systemImage: "location.fill"
                        )
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // トレンド
            if let change = report.score.changeFromPrevious {
                TrendBadge(change: change)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 70...: .green
        case 50..<70: .yellow
        case 35..<50: .orange
        default: .red
        }
    }
}

private struct TrendBadge: View {
    let change: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change > 0 ? "arrow.up" : change < 0 ? "arrow.down" : "minus")
                .font(.caption2)
            Text("\(abs(change))")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(change > 0 ? .green : change < 0 ? .orange : .secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background((change > 0 ? Color.green : change < 0 ? Color.orange : Color.secondary).opacity(0.1))
        .clipShape(Capsule())
    }
}
