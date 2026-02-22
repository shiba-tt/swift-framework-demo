import SwiftUI

struct ForecastView: View {
    @Bindable var viewModel: SoraNaviViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("予報データを取得中...")
                            .padding(.top, 40)
                    } else if viewModel.hourlyForecast.isEmpty {
                        ContentUnavailableView {
                            Label("データなし", systemImage: "chart.bar.xaxis")
                        } description: {
                            Text("天気データを取得してください。")
                        }
                    } else {
                        timelineChart
                        hourlyDetailList
                    }
                }
                .padding()
            }
            .navigationTitle("時間別予報")
        }
    }

    // MARK: - Timeline Chart

    private var timelineChart: some View {
        VStack(spacing: 12) {
            Text("撮影スコア タイムライン")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(viewModel.hourlyForecast) { forecast in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barColor(for: forecast.bestScore))
                                .frame(width: 20, height: max(8, CGFloat(forecast.bestScore) * 100))

                            Text(forecast.condition.emoji)
                                .font(.caption2)

                            Text(shortHourText(forecast.hour))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 140)
                .padding(.horizontal, 4)
            }

            HStack(spacing: 16) {
                legendItem(color: .green, label: "好条件")
                legendItem(color: .orange, label: "まずまず")
                legendItem(color: .red, label: "不向き")
            }
            .font(.caption2)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Hourly Detail

    private var hourlyDetailList: some View {
        VStack(spacing: 12) {
            Text("時間別詳細")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.hourlyForecast.filter { isRelevantHour($0.hour) }) { forecast in
                hourlyRow(forecast)
            }
        }
    }

    private func hourlyRow(_ forecast: HourlyPhotoForecast) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(forecast.hourText)
                    .font(.subheadline.monospaced())
                    .fontWeight(.medium)
                Text(forecast.lightingPhase.emoji)
                    .font(.caption)
            }
            .frame(width: 50)

            Text(forecast.condition.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(forecast.lightingPhase.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    scoreChip(label: "夕焼け", score: forecast.sunsetScore)
                    scoreChip(label: "風景", score: forecast.landscapeScore)
                    scoreChip(label: "人物", score: forecast.portraitScore)
                }
            }

            Spacer()

            Text(String(format: "%.0f°", forecast.temperature))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func scoreChip(label: String, score: Double) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
            Text("\(Int(score * 100))")
                .font(.system(size: 9).monospaced())
                .fontWeight(.bold)
                .foregroundStyle(barColor(for: score))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(.quaternary, in: Capsule())
    }

    // MARK: - Helpers

    private func barColor(for score: Double) -> Color {
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }

    private func shortHourText(_ hour: Int) -> String {
        String(format: "%02d", hour)
    }

    private func isRelevantHour(_ hour: Int) -> Bool {
        // ゴールデンアワー付近 + 日中の主要時間帯のみ表示
        let relevant = [4, 5, 6, 7, 8, 10, 12, 14, 16, 17, 18, 19, 20, 21]
        return relevant.contains(hour)
    }
}

#Preview {
    ForecastView(viewModel: SoraNaviViewModel())
}
