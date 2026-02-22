import SwiftUI

struct ConditionsView: View {
    @Bindable var viewModel: SoraNaviViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("天気データを取得中...")
                            .padding(.top, 40)
                    } else {
                        weatherSummaryCard
                        bestConditionsSection
                        allConditionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("SoraNavi")
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

    // MARK: - Weather Summary

    private var weatherSummaryCard: some View {
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
                    Label(viewModel.currentLightingPhase.rawValue, systemImage: "light.max")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15), in: Capsule())

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
                weatherDetailItem(icon: "humidity.fill", value: viewModel.currentWeather.humidityText, label: "湿度")
                weatherDetailItem(icon: "wind", value: viewModel.currentWeather.windSpeedText, label: "風速")
                weatherDetailItem(icon: "eye.fill", value: viewModel.currentWeather.visibilityText, label: "視程")
                weatherDetailItem(icon: "sun.max.fill", value: "UV \(viewModel.currentWeather.uvIndex)", label: "紫外線")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weatherDetailItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Best Conditions

    private var bestConditionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("今日のベスト撮影時間")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.bestTimeToday)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
            }

            if !viewModel.topConditions.isEmpty {
                ForEach(viewModel.topConditions) { condition in
                    topConditionRow(condition)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func topConditionRow(_ condition: PhotoCondition) -> some View {
        HStack(spacing: 12) {
            Text(condition.type.emoji)
                .font(.title2)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(condition.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(condition.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(condition.scorePercent)%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(colorForScore(condition.score))
                Text(condition.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - All Conditions

    private var allConditionsSection: some View {
        VStack(spacing: 12) {
            Text("撮影条件スコア")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.conditions) { condition in
                    conditionCard(condition)
                }
            }
        }
    }

    private func conditionCard(_ condition: PhotoCondition) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(condition.type.emoji)
                Spacer()
                Text("\(condition.scorePercent)%")
                    .font(.headline)
                    .foregroundStyle(colorForScore(condition.score))
            }

            Text(condition.type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)

            ProgressView(value: condition.score)
                .tint(colorForScore(condition.score))

            Text(condition.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func colorForScore(_ score: Double) -> Color {
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }
}

#Preview {
    ConditionsView(viewModel: SoraNaviViewModel())
}
