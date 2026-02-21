import SwiftUI

/// 分単位降水予報の詳細グラフ画面
struct PrecipitationChartView: View {
    @Bindable var viewModel: AmeNigeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isMinuteForecastAvailable {
                    chartContent
                } else {
                    unavailableView
                }
            }
            .navigationTitle("降水グラフ")
        }
    }

    // MARK: - Content

    private var chartContent: some View {
        VStack(spacing: 20) {
            // メイングラフ
            minuteChartSection

            // 降水レベル凡例
            legendSection

            // 降水詳細リスト
            detailListSection
        }
        .padding(16)
    }

    /// 分単位グラフセクション
    private var minuteChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分単位降水予報")
                .font(.headline)

            // バーチャート
            VStack(spacing: 0) {
                // Y軸ラベル
                HStack(alignment: .top) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("50+")
                            .font(.system(size: 8).monospacedDigit())
                        Spacer()
                        Text("20")
                            .font(.system(size: 8).monospacedDigit())
                        Spacer()
                        Text("3")
                            .font(.system(size: 8).monospacedDigit())
                        Spacer()
                        Text("0")
                            .font(.system(size: 8).monospacedDigit())
                    }
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 120)

                    // バーグラフ
                    HStack(alignment: .bottom, spacing: 0.5) {
                        ForEach(viewModel.minuteForecasts.prefix(60)) { forecast in
                            VStack(spacing: 0) {
                                Spacer()
                                RoundedRectangle(cornerRadius: 0.5)
                                    .fill(colorForLevel(forecast.level))
                                    .frame(height: barHeight(for: forecast.intensityMmPerHour))
                            }
                        }
                    }
                    .frame(height: 120)
                }

                // X軸ラベル
                HStack {
                    Text("現在")
                    Spacer()
                    Text("15分")
                    Spacer()
                    Text("30分")
                    Spacer()
                    Text("45分")
                    Spacer()
                    Text("60分")
                }
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
                .padding(.top, 4)
            }

            // 晴れ間ウィンドウ表示（バー下のタイムライン）
            if !viewModel.dryWindows.isEmpty {
                dryWindowTimeline
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 晴れ間タイムライン
    private var dryWindowTimeline: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("晴れ間")
                .font(.caption2.bold())
                .foregroundStyle(.green)

            ForEach(viewModel.dryWindows) { window in
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("\(window.timeRangeText) (\(window.durationText))")
                        .font(.caption.monospacedDigit())

                    if window.isAvailableNow {
                        Text("NOW")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    /// 凡例セクション
    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("降水強度の目安")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 8) {
                ForEach(PrecipitationLevel.allCases, id: \.self) { level in
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForLevel(level))
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(level.rawValue)
                                .font(.caption)
                            Text(rangeText(for: level))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 降水詳細リスト
    private var detailListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5分ごとの降水予報")
                .font(.headline)

            ForEach(
                Array(viewModel.minuteForecasts.prefix(60).enumerated())
                    .filter { $0.offset % 5 == 0 },
                id: \.element.id
            ) { _, forecast in
                HStack {
                    Image(systemName: forecast.level.systemImageName)
                        .font(.caption)
                        .foregroundStyle(colorForLevel(forecast.level))
                        .frame(width: 24)

                    Text(forecast.timeText)
                        .font(.caption.monospacedDigit())
                        .frame(width: 40, alignment: .leading)

                    ProgressView(
                        value: min(forecast.intensityMmPerHour / 50.0, 1.0)
                    )
                    .tint(colorForLevel(forecast.level))

                    Text(String(format: "%.1f", forecast.intensityMmPerHour))
                        .font(.caption.monospacedDigit())
                        .frame(width: 36, alignment: .trailing)
                    Text("mm/h")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// データ非対応時の表示
    private var unavailableView: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("分単位降水予報は\nこの地域に対応していません")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("分単位降水予報は一部の地域でのみ利用可能です")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 80)
    }

    // MARK: - Helpers

    private func barHeight(for intensity: Double) -> CGFloat {
        let maxHeight: CGFloat = 120
        let normalized = min(intensity / 50.0, 1.0)
        return max(2, maxHeight * CGFloat(normalized))
    }

    private func colorForLevel(_ level: PrecipitationLevel) -> Color {
        switch level {
        case .none: .green.opacity(0.3)
        case .light: .cyan
        case .moderate: .blue
        case .heavy: .orange
        case .veryHeavy: .red
        case .extreme: .purple
        }
    }

    private func rangeText(for level: PrecipitationLevel) -> String {
        switch level {
        case .none: "< 0.1 mm/h"
        case .light: "0.1 - 3 mm/h"
        case .moderate: "3 - 10 mm/h"
        case .heavy: "10 - 20 mm/h"
        case .veryHeavy: "20 - 50 mm/h"
        case .extreme: "50+ mm/h"
        }
    }
}
