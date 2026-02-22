import SwiftUI

struct HourlyView: View {
    @Bindable var viewModel: KiseKaeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("天気データを取得中...")
                            .padding(.top, 40)
                    } else {
                        tempRangeCard
                        hourlyList
                    }
                }
                .padding()
            }
            .navigationTitle("時間別予報")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Temperature Range Card

    private var tempRangeCard: some View {
        VStack(spacing: 12) {
            Text("気温の推移")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.hourlyForecast.isEmpty {
                let temps = viewModel.hourlyForecast.map(\.temperature)
                let minT = temps.min() ?? 0
                let maxT = temps.max() ?? 30

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Image(systemName: "thermometer.low")
                            .foregroundStyle(.blue)
                        Text(String(format: "%.0f°", minT))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Text("最低")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        let diff = maxT - minT
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(diff > 8 ? .orange : .secondary)
                        Text(String(format: "%.0f°差", diff))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(diff > 8 ? .orange : .primary)
                        Text("気温差")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "thermometer.high")
                            .foregroundStyle(.red)
                        Text(String(format: "%.0f°", maxT))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                        Text("最高")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // 気温バー
                HStack(spacing: 2) {
                    ForEach(viewModel.hourlyForecast) { hour in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(tempBarColor(hour.temperature))
                                .frame(height: CGFloat((hour.temperature - minT + 1) / (maxT - minT + 1)) * 60)

                            Text(String(format: "%d", hour.hour))
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 80)

                if maxT - minT > 8 {
                    Label("気温差が大きい日です。脱ぎ着しやすい服装を", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Hourly List

    private var hourlyList: some View {
        VStack(spacing: 12) {
            Text("時間別の天気")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.hourlyForecast) { hour in
                HStack(spacing: 12) {
                    Text(hour.hourText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .leading)

                    Image(systemName: hour.condition.systemImageName)
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 28)

                    Text(hour.temperatureText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(tempBarColor(hour.temperature))
                        .frame(width: 40, alignment: .trailing)

                    Spacer()

                    HStack(spacing: 8) {
                        Label("\(Int(hour.precipitationChance * 100))%", systemImage: "drop.fill")
                            .font(.caption)
                            .foregroundStyle(hour.precipitationChance > 0.5 ? .blue : .secondary)

                        Label("UV\(hour.uvIndex)", systemImage: "sun.max.fill")
                            .font(.caption)
                            .foregroundStyle(hour.uvIndex >= 6 ? .orange : .secondary)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isAlertHour(hour.hour) ? .orange.opacity(0.08) : .clear,
                            in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func tempBarColor(_ temp: Double) -> Color {
        switch temp {
        case 30...: return .red
        case 25...: return .orange
        case 20...: return .yellow
        case 15...: return .green
        case 10...: return .cyan
        default:    return .blue
        }
    }

    private func isAlertHour(_ hour: Int) -> Bool {
        viewModel.weatherAlerts.contains { $0.hour == hour }
    }
}

#Preview {
    HourlyView(viewModel: KiseKaeViewModel())
}
