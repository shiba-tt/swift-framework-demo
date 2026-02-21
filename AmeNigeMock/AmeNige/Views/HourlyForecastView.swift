import SwiftUI

/// 時間別降水予報画面（1時間以降の見通し）
struct HourlyForecastView: View {
    @Bindable var viewModel: AmeNigeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hourlyForecasts.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    hourlyContent
                }
            }
            .navigationTitle("時間別予報")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    // MARK: - Content

    private var hourlyContent: some View {
        VStack(spacing: 16) {
            // 降水確率グラフ
            precipitationChanceChart

            // 時間別リスト
            hourlyList
        }
        .padding(16)
    }

    /// 降水確率のバーチャート
    private var precipitationChanceChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("降水確率の推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(viewModel.hourlyForecasts) { hour in
                    VStack(spacing: 4) {
                        // バー
                        RoundedRectangle(cornerRadius: 3)
                            .fill(chanceColor(hour.precipitationChance))
                            .frame(
                                width: 28,
                                height: max(4, CGFloat(hour.precipitationChance) * 100)
                            )

                        // 確率テキスト
                        Text(hour.chanceText)
                            .font(.system(size: 8).monospacedDigit())
                            .foregroundStyle(.secondary)

                        // 時刻
                        Text(hour.timeText)
                            .font(.system(size: 9).monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 時間別リスト
    private var hourlyList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("時間別の詳細")
                .font(.headline)

            ForEach(viewModel.hourlyForecasts) { hour in
                HStack(spacing: 12) {
                    // 天候アイコン
                    Image(systemName: hour.conditionIcon)
                        .font(.title3)
                        .foregroundStyle(iconColor(for: hour))
                        .frame(width: 32)

                    // 時刻
                    Text(hour.timeText)
                        .font(.subheadline.monospacedDigit().bold())
                        .frame(width: 36, alignment: .leading)

                    // 天候
                    Text(hour.conditionDescription)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 降水確率
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(hour.chanceText)
                            .font(.subheadline.monospacedDigit().bold())
                            .foregroundStyle(chanceColor(hour.precipitationChance))
                        if hour.precipitationAmount > 0 {
                            Text(String(format: "%.1fmm", hour.precipitationAmount))
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    hour.precipitationChance > 0.5
                        ? Color.blue.opacity(0.05)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))

                if hour.id != viewModel.hourlyForecasts.last?.id {
                    Divider()
                        .padding(.leading, 44)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 空の状態
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("時間別予報データがありません")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 80)
    }

    // MARK: - Helpers

    private func chanceColor(_ chance: Double) -> Color {
        switch chance {
        case ..<0.2: .green
        case 0.2..<0.5: .cyan
        case 0.5..<0.7: .blue
        case 0.7..<0.9: .orange
        default: .red
        }
    }

    private func iconColor(for hour: HourlyPrecipitation) -> Color {
        if hour.precipitationChance > 0.5 {
            return .blue
        }
        if hour.conditionIcon.contains("sun") {
            return .yellow
        }
        return .secondary
    }
}
