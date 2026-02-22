import SwiftUI

struct InsightsView: View {
    let viewModel: TenKiLogViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    moodWeatherChart()
                    correlationCards()
                    pressureTimeline()
                }
                .padding()
            }
            .navigationTitle("天気と体調の分析")
        }
    }

    // MARK: - Mood Weather Chart

    private func moodWeatherChart() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("天気別の気分スコア")
                .font(.headline)

            let moodByWeather = computeMoodByWeather()
            ForEach(moodByWeather, id: \.condition) { item in
                HStack(spacing: 12) {
                    Text(item.condition.emoji)
                        .font(.title3)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.condition.displayName)
                            .font(.caption)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.fill.secondary)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(moodColor(item.avgScore))
                                    .frame(width: geo.size.width * CGFloat(item.avgScore) / 5.0)
                            }
                        }
                        .frame(height: 12)
                    }

                    Text(String(format: "%.1f", item.avgScore))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(moodColor(item.avgScore))
                        .frame(width: 30)
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Correlation Cards

    private func correlationCards() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("発見された相関")
                .font(.headline)

            ForEach(viewModel.correlations) { correlation in
                HStack(spacing: 12) {
                    Image(systemName: correlation.icon)
                        .font(.title2)
                        .foregroundStyle(correlation.correlationColor)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(correlation.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(correlation.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(correlation.correlationLabel)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(correlation.correlationColor)
                            Text("(r = \(String(format: "%.2f", correlation.correlation)))")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Pressure Timeline

    private func pressureTimeline() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("気圧と体調の変化")
                .font(.headline)

            let recent = viewModel.recentLogs(count: 7)
            ForEach(recent) { log in
                HStack(spacing: 8) {
                    Text(log.monthDay)
                        .font(.caption)
                        .frame(width: 36)

                    // Pressure bar
                    let normalizedPressure = (log.pressure - 985) / 40.0
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.fill.secondary)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(pressureColor(log.pressure))
                                .frame(width: geo.size.width * max(0, min(1, CGFloat(normalizedPressure))))
                        }
                    }
                    .frame(height: 10)

                    Text(log.pressureFormatted)
                        .font(.system(size: 9))
                        .frame(width: 50, alignment: .trailing)

                    HStack(spacing: 2) {
                        ForEach(log.healthConditions.filter { $0 != .none }) { condition in
                            Text(condition.emoji)
                                .font(.system(size: 12))
                        }
                        if log.healthConditions.contains(.none) || log.healthConditions.isEmpty {
                            Text("\u{2705}")
                                .font(.system(size: 12))
                        }
                    }
                    .frame(width: 30)
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private struct MoodByWeather {
        let condition: WeatherConditionType
        let avgScore: Double
    }

    private func computeMoodByWeather() -> [MoodByWeather] {
        let logs = WeatherLogManager.shared.logs
        var grouped: [WeatherConditionType: [Int]] = [:]
        for log in logs {
            if let mood = log.mood {
                grouped[log.condition, default: []].append(mood.score)
            }
        }
        return grouped.map { key, scores in
            MoodByWeather(condition: key, avgScore: Double(scores.reduce(0, +)) / Double(scores.count))
        }
        .sorted { $0.avgScore > $1.avgScore }
    }

    private func moodColor(_ score: Double) -> Color {
        if score >= 4.0 { return .green }
        if score >= 3.0 { return .yellow }
        if score >= 2.0 { return .orange }
        return .red
    }

    private func pressureColor(_ pressure: Double) -> Color {
        if pressure >= 1015 { return .green }
        if pressure >= 1005 { return .yellow }
        return .red
    }
}
