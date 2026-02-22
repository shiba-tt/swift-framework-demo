import SwiftUI
import Charts

struct WeeklyTrendView: View {
    let viewModel: LightLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    trendSummaryCard
                    rhythmScoreChart
                    daytimeLuxChart
                    outdoorTimeChart
                    weeklyInsightsCard
                }
                .padding()
            }
            .navigationTitle("週間トレンド")
        }
    }

    // MARK: - Components

    private var trendSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("週間サマリー")
                    .font(.headline)
                Spacer()
            }

            if let trend = viewModel.weeklyTrend {
                HStack(spacing: 16) {
                    trendItem(
                        title: "平均リズムスコア",
                        value: "\(Int(trend.averageRhythmScore))",
                        icon: "clock.arrow.2.circlepath",
                        color: .purple
                    )
                    trendItem(
                        title: "平均日中照度",
                        value: "\(Int(trend.averageDaytimeLux))",
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    trendItem(
                        title: "傾向",
                        value: trend.rhythmScoreTrend.rawValue,
                        icon: trend.rhythmScoreTrend.icon,
                        color: trend.rhythmScoreTrend == .improving ? .green : trend.rhythmScoreTrend == .declining ? .red : .blue
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func trendItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var rhythmScoreChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("リズムスコア推移")
                .font(.headline)

            Chart(viewModel.weeklyReports) { report in
                LineMark(
                    x: .value("日付", report.date, unit: .day),
                    y: .value("スコア", report.profile.rhythmScore)
                )
                .foregroundStyle(.purple)
                .symbol(.circle)

                PointMark(
                    x: .value("日付", report.date, unit: .day),
                    y: .value("スコア", report.profile.rhythmScore)
                )
                .foregroundStyle(.purple)

                RuleMark(y: .value("良好ライン", 70))
                    .lineStyle(StrokeStyle(dash: [5, 3]))
                    .foregroundStyle(.green.opacity(0.4))
            }
            .frame(height: 180)
            .chartYScale(domain: 0...100)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var daytimeLuxChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日中平均照度の推移")
                .font(.headline)

            Chart(viewModel.weeklyReports) { report in
                BarMark(
                    x: .value("日付", report.date, unit: .day),
                    y: .value("照度", report.profile.daytimeAverageLux)
                )
                .foregroundStyle(.orange.gradient)
            }
            .frame(height: 160)

            Text("日中に200lux以上の光曝露が理想的です")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var outdoorTimeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("屋外時間の推移")
                .font(.headline)

            Chart(viewModel.weeklyReports) { report in
                BarMark(
                    x: .value("日付", report.date, unit: .day),
                    y: .value("時間", report.locationSummary.timeOutdoors / 3600)
                )
                .foregroundStyle(.green.gradient)
            }
            .frame(height: 160)

            Text("1日30分以上の屋外活動が概日リズムの安定に寄与します")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var weeklyInsightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.teal)
                Text("週間分析")
                    .font(.headline)
                Spacer()
            }

            if let trend = viewModel.weeklyTrend {
                VStack(alignment: .leading, spacing: 8) {
                    weeklyInsightRow(
                        icon: "sun.max.fill",
                        text: "平均日中照度: \(Int(trend.averageDaytimeLux)) lux",
                        color: trend.averageDaytimeLux > 300 ? .green : .orange
                    )
                    weeklyInsightRow(
                        icon: "figure.walk",
                        text: "平均屋外時間: \(String(format: "%.1f", trend.averageOutdoorTime / 3600))時間/日",
                        color: trend.averageOutdoorTime > 3600 ? .green : .orange
                    )
                    weeklyInsightRow(
                        icon: "arrow.triangle.2.circlepath",
                        text: "リズムスコア: \(trend.rhythmScoreTrend.rawValue)",
                        color: trend.rhythmScoreTrend == .improving ? .green : trend.rhythmScoreTrend == .declining ? .red : .blue
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weeklyInsightRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
