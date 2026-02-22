import SwiftUI

/// 週間レポート画面 — 7日間のスコア推移とトレンド分析
struct WeeklyReportView: View {
    let viewModel: SocialPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if let report = viewModel.weeklyReport {
                    VStack(spacing: 20) {
                        // 週間サマリー
                        WeeklySummaryCard(report: report)

                        // 7日間スコアチャート
                        WeeklyScoreChart(scores: report.dailyScores)

                        // カテゴリ別週間平均
                        CategoryWeeklyCard(report: report)

                        // 日別スコア一覧
                        DailyScoreList(scores: report.dailyScores)

                        // AI生成インサイト
                        InsightsCard(insights: report.insights)
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
    let report: WeeklyReport

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今週のソーシャルパルス")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: report.trend.systemImageName)
                    Text(report.trend.rawValue)
                }
                .font(.caption)
                .foregroundStyle(Color(report.trend.colorName))
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(report.averageScore)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("/ 100")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 16) {
                WeeklyStatBadge(
                    label: "最高",
                    value: "\(report.bestDay?.overallScore ?? 0)",
                    color: .green
                )
                WeeklyStatBadge(
                    label: "最低",
                    value: "\(report.worstDay?.overallScore ?? 0)",
                    color: .orange
                )
                WeeklyStatBadge(
                    label: "変動幅",
                    value: String(format: "%.1f", report.scoreVariance),
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

// MARK: - Weekly Score Chart

private struct WeeklyScoreChart: View {
    let scores: [SocialScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スコア推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(scores) { score in
                    VStack(spacing: 4) {
                        Text("\(score.overallScore)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(score.scoreLevel.colorName))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(score.scoreLevel.colorName).opacity(0.6))
                            .frame(height: CGFloat(score.overallScore) * 1.2)

                        Text(dayLabel(score.date))
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

// MARK: - Category Weekly Card

private struct CategoryWeeklyCard: View {
    let report: WeeklyReport

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("カテゴリ別週間平均")
                .font(.headline)

            HStack(spacing: 16) {
                CategoryAvgItem(
                    category: .phone,
                    average: report.averagePhoneScore
                )
                CategoryAvgItem(
                    category: .message,
                    average: report.averageMessageScore
                )
                CategoryAvgItem(
                    category: .visit,
                    average: report.averageVisitScore
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CategoryAvgItem: View {
    let category: SocialCategory
    let average: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: Double(average) / 100.0)
                    .stroke(
                        Color(category.colorName),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(average)")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
            }
            .frame(width: 56, height: 56)

            Image(systemName: category.systemImageName)
                .font(.caption)
                .foregroundStyle(Color(category.colorName))
            Text(category.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Daily Score List

private struct DailyScoreList: View {
    let scores: [SocialScore]

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

            ForEach(scores) { score in
                HStack {
                    Text(dateFormatter.string(from: score.date))
                        .font(.subheadline)

                    Spacer()

                    // スコアバー
                    GeometryReader { geometry in
                        let width = geometry.size.width * Double(score.overallScore) / 100.0
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(score.scoreLevel.colorName).opacity(0.3))
                            .frame(width: width)
                    }
                    .frame(width: 100, height: 12)

                    Text("\(score.overallScore)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color(score.scoreLevel.colorName))
                        .frame(width: 36, alignment: .trailing)

                    if let change = score.changeFromPrevious {
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
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Insights Card

private struct InsightsCard: View {
    let insights: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.fill")
                    .foregroundStyle(.pink)
                Text("AI分析インサイト")
                    .font(.headline)
            }

            if insights.isEmpty {
                Text("分析データが不足しています")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    InsightRow(index: index + 1, text: insight)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct InsightRow: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.pink, in: Circle())

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
