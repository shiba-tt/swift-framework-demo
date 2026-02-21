import SwiftUI

/// グリッド予測の詳細ビュー
struct GridForecastView: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 24時間予測グラフ
                    ForecastChart(forecasts: viewModel.gridForecasts)

                    // クリーンウィンドウ一覧
                    if !viewModel.cleanWindows.isEmpty {
                        CleanWindowsSection(windows: viewModel.cleanWindows)
                    }

                    // 時間別詳細
                    HourlyDetailSection(forecasts: viewModel.gridForecasts)
                }
                .padding()
            }
            .navigationTitle("グリッド予測")
            .refreshable {
                await viewModel.loadGridForecast()
            }
        }
    }
}

// MARK: - Forecast Chart

private struct ForecastChart: View {
    let forecasts: [GridForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24時間クリーンエネルギー予測")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(forecasts) { forecast in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor(for: forecast).gradient)
                            .frame(height: CGFloat(forecast.cleanEnergyFraction) * 120)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)

            // 時刻ラベル
            HStack {
                Text("0")
                Spacer()
                Text("6")
                Spacer()
                Text("12")
                Spacer()
                Text("18")
                Spacer()
                Text("24")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)

            // 凡例
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "推奨 (60%+)")
                LegendItem(color: .yellow, label: "普通 (40-60%)")
                LegendItem(color: .red, label: "非推奨 (<40%)")
            }
            .font(.caption2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(for forecast: GridForecast) -> Color {
        switch forecast.guidanceLevel {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Clean Windows Section

private struct CleanWindowsSection: View {
    let windows: [CleanWindow]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("クリーンウィンドウ")
                .font(.headline)

            ForEach(windows) { window in
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(window.timeRangeText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(window.durationText) / クリーン度 \(Int(window.averageCleanFraction * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if window.startDate > Date() {
                        Text("予定")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.green.opacity(0.12))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    } else if window.endDate > Date() {
                        Text("実施中")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Hourly Detail

private struct HourlyDetailSection: View {
    let forecasts: [GridForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("時間別詳細")
                .font(.headline)

            ForEach(forecasts) { forecast in
                HStack {
                    Text(forecast.shortTimeText)
                        .font(.subheadline)
                        .frame(width: 40, alignment: .leading)

                    ProgressView(value: forecast.cleanEnergyFraction)
                        .tint(progressColor(for: forecast))

                    Text(forecast.cleanPercentText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 40, alignment: .trailing)

                    Image(systemName: forecast.guidanceLevel.systemImageName)
                        .font(.caption)
                        .foregroundStyle(iconColor(for: forecast))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func progressColor(for forecast: GridForecast) -> Color {
        switch forecast.guidanceLevel {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }

    private func iconColor(for forecast: GridForecast) -> Color {
        switch forecast.guidanceLevel {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }
}
