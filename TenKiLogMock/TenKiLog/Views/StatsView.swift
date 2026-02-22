import SwiftUI

struct StatsView: View {
    let viewModel: TenKiLogViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    let stats = viewModel.statsSummary()
                    overviewSection(stats)
                    weatherBreakdown(stats)
                    temperatureExtremes(stats)
                    moodSummary(stats)
                }
                .padding()
            }
            .navigationTitle("天気統計")
        }
    }

    // MARK: - Overview

    private func overviewSection(_ stats: WeatherStatsSummary) -> some View {
        VStack(spacing: 12) {
            Text("30日間のサマリー")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(
                    icon: "calendar",
                    label: "記録日数",
                    value: "\(stats.totalDays)日",
                    color: .blue
                )
                statCard(
                    icon: "thermometer.medium",
                    label: "平均気温",
                    value: String(format: "%.1f\u{00B0}C", stats.avgTemperature),
                    color: .orange
                )
                statCard(
                    icon: "drop.fill",
                    label: "総降水量",
                    value: String(format: "%.0f mm", stats.totalPrecipitation),
                    color: .blue
                )
                statCard(
                    icon: "face.smiling",
                    label: "平均気分",
                    value: String(format: "%.1f / 5", stats.avgMoodScore),
                    color: .green
                )
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Weather Breakdown

    private func weatherBreakdown(_ stats: WeatherStatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("天気の内訳")
                .font(.headline)

            HStack(spacing: 0) {
                weatherBar(label: "晴", count: stats.clearDays, total: stats.totalDays, color: .orange)
                weatherBar(label: "雨", count: stats.rainyDays, total: stats.totalDays, color: .blue)
                weatherBar(label: "雪", count: stats.snowDays, total: stats.totalDays, color: .cyan)
                let otherDays = stats.totalDays - stats.clearDays - stats.rainyDays - stats.snowDays
                weatherBar(label: "他", count: otherDays, total: stats.totalDays, color: .gray)
            }
            .frame(height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 16) {
                legendItem(emoji: "\u{2600}\u{FE0F}", label: "晴れ", count: stats.clearDays)
                legendItem(emoji: "\u{1F327}\u{FE0F}", label: "雨", count: stats.rainyDays)
                legendItem(emoji: "\u{2744}\u{FE0F}", label: "雪", count: stats.snowDays)
                let otherDays = stats.totalDays - stats.clearDays - stats.rainyDays - stats.snowDays
                legendItem(emoji: "\u{2601}\u{FE0F}", label: "その他", count: otherDays)
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weatherBar(label: String, count: Int, total: Int, color: Color) -> some View {
        let ratio = total > 0 ? CGFloat(count) / CGFloat(total) : 0
        return GeometryReader { geo in
            Rectangle()
                .fill(color)
                .frame(width: geo.size.width * ratio)
        }
    }

    private func legendItem(emoji: String, label: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption)
            Text("\(label) \(count)日")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Temperature Extremes

    private func temperatureExtremes(_ stats: WeatherStatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("気温の記録")
                .font(.headline)

            if let hottest = stats.hottestDay {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最も暑かった日")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(hottest.dateFormatted) \(String(format: "%.1f\u{00B0}C", hottest.temperatureHigh))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text(hottest.condition.emoji)
                        .font(.title3)
                }
            }

            if let coldest = stats.coldestDay {
                HStack {
                    Image(systemName: "snowflake")
                        .foregroundStyle(.cyan)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最も寒かった日")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(coldest.dateFormatted) \(String(format: "%.1f\u{00B0}C", coldest.temperatureLow))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text(coldest.condition.emoji)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Mood Summary

    private func moodSummary(_ stats: WeatherStatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("気分の傾向")
                .font(.headline)

            let logs = WeatherLogManager.shared.logs
            let moodCounts = countMoods(logs)

            ForEach(MoodType.allCases) { mood in
                let count = moodCounts[mood] ?? 0
                let total = moodCounts.values.reduce(0, +)
                let ratio = total > 0 ? Double(count) / Double(total) : 0

                HStack(spacing: 8) {
                    Text(mood.emoji)
                        .font(.title3)
                        .frame(width: 28)
                    Text(mood.displayName)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.fill.secondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(mood.color)
                                .frame(width: geo.size.width * CGFloat(ratio))
                        }
                    }
                    .frame(height: 14)

                    Text("\(count)日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func countMoods(_ logs: [WeatherLog]) -> [MoodType: Int] {
        var counts: [MoodType: Int] = [:]
        for log in logs {
            if let mood = log.mood {
                counts[mood, default: 0] += 1
            }
        }
        return counts
    }
}
