import SwiftUI

struct CoordinateView: View {
    @Bindable var viewModel: KiseKaeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("天気データを取得中...")
                            .padding(.top, 40)
                    } else {
                        weatherCard
                        if let coordinate = viewModel.coordinate {
                            coordinateCard(coordinate)
                            adviceCard(coordinate)
                        }
                        if !viewModel.weatherAlerts.isEmpty {
                            alertsSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("KiseKae")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Weather Card

    private var weatherCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Text(viewModel.currentWeather.condition.emoji)
                            .font(.title)
                        Text(viewModel.currentWeather.temperatureText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Text(viewModel.currentWeather.condition.rawValue)
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("快適度")
                            .font(.caption2)
                        Text("\(viewModel.comfortScorePercent)%")
                            .font(.headline)
                            .foregroundStyle(comfortColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(comfortColor.opacity(0.12), in: Capsule())

                    Text("更新: \(viewModel.lastUpdatedText)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
                GridItem(.flexible()), GridItem(.flexible()),
            ], spacing: 12) {
                weatherDetail(icon: "thermometer.medium", value: "体感 \(viewModel.currentWeather.apparentTemperatureText)", label: "体感温度")
                weatherDetail(icon: "humidity.fill", value: viewModel.currentWeather.humidityText, label: "湿度")
                weatherDetail(icon: "wind", value: viewModel.currentWeather.windSpeedText, label: "風速")
                weatherDetail(icon: "sun.max.fill", value: "UV \(viewModel.currentWeather.uvIndex)", label: "紫外線")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weatherDetail(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.indigo)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Coordinate Card

    private func coordinateCard(_ coordinate: Coordinate) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日のコーディネート")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Text(coordinate.scoreLabel)
                        .font(.caption)
                    Text("\(coordinate.scorePercent)%")
                        .font(.headline)
                        .foregroundStyle(.indigo)
                }
            }

            Text(coordinate.weatherSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(coordinate.itemsByCategory, id: \.category) { group in
                HStack(spacing: 12) {
                    Image(systemName: group.category.systemImageName)
                        .font(.caption)
                        .foregroundStyle(.indigo)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.category.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        ForEach(group.items) { item in
                            HStack(spacing: 6) {
                                Text(item.emoji)
                                    .font(.body)
                                Text(item.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        ForEach(group.items) { item in
                            let score = Int(item.suitability(for: viewModel.currentWeather) * 100)
                            Text("\(score)%")
                                .font(.caption)
                                .foregroundStyle(scoreColor(item.suitability(for: viewModel.currentWeather)))
                        }
                    }
                }
                .padding(.vertical, 4)

                if group.category != coordinate.itemsByCategory.last?.category {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Advice Card

    private func adviceCard(_ coordinate: Coordinate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("今日のアドバイス", systemImage: "lightbulb.fill")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.indigo)

            Text(coordinate.advice)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Alerts Section

    private var alertsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("天気の変化に注意", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
                Spacer()
            }

            ForEach(viewModel.weatherAlerts) { alert in
                HStack(spacing: 12) {
                    Image(systemName: alert.systemImage)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(alert.message)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(alert.suggestion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var comfortColor: Color {
        let score = viewModel.currentWeather.comfortScore
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }
}

#Preview {
    CoordinateView(viewModel: KiseKaeViewModel())
}
