import SwiftUI

/// メインダッシュボード画面
struct DashboardView: View {
    @Bindable var viewModel: AmeNigeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading && viewModel.lastUpdated == nil {
                    ProgressView("天気データを取得中...")
                        .padding(.top, 80)
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("AmeNige")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Content

    private var dashboardContent: some View {
        VStack(spacing: 16) {
            // アラート（あれば）
            if !viewModel.alerts.isEmpty {
                alertBanner
            }

            // 外出判定カード
            verdictCard

            // 現在の降水状況
            currentWeatherCard

            // 晴れ間ウィンドウ
            if !viewModel.dryWindows.isEmpty {
                dryWindowsCard
            }

            // 分単位プレビュー
            if viewModel.isMinuteForecastAvailable {
                minutePreviewCard
            }

            // 更新情報
            HStack {
                Text(viewModel.lastUpdatedText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(viewModel.locationManager.locationText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
    }

    // MARK: - Cards

    /// 気象アラートバナー
    private var alertBanner: some View {
        ForEach(viewModel.alerts) { alert in
            HStack(spacing: 8) {
                Image(systemName: alert.severity.systemImageName)
                    .foregroundStyle(colorForAlertSeverity(alert.severity))
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.severity.rawValue)
                        .font(.caption.bold())
                    Text(alert.title)
                        .font(.caption)
                }
                Spacer()
            }
            .padding(12)
            .background(colorForAlertSeverity(alert.severity).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    /// 外出判定カード
    private var verdictCard: some View {
        VStack(spacing: 16) {
            // メインアイコン
            Image(systemName: viewModel.verdict.systemImageName)
                .font(.system(size: 48))
                .foregroundStyle(verdictColor)

            // 判定タイトル
            Text(viewModel.verdict.title)
                .font(.title2.bold())
                .foregroundStyle(verdictColor)

            // 判定メッセージ
            Text(viewModel.verdict.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // カウントダウン表示
            if let minutes = viewModel.minutesUntilRain, !viewModel.isCurrentlyRaining {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                    Text("雨まであと約 \(minutes) 分")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.1))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
            }

            if let stopTime = viewModel.rainStopTime {
                HStack(spacing: 4) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.caption)
                    let formatter = DateFormatter()
                    Text("止む予測: \(timeText(stopTime))")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.cyan.opacity(0.1))
                .foregroundStyle(.cyan)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// 現在の降水状況カード
    private var currentWeatherCard: some View {
        HStack(spacing: 16) {
            if let current = viewModel.currentPrecipitation {
                // アイコン
                Image(systemName: current.level.systemImageName)
                    .font(.title2)
                    .foregroundStyle(colorForLevel(current.level))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("現在の降水")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(current.level.rawValue)
                        .font(.subheadline.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("降水強度")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f mm/h", current.intensityMmPerHour))
                        .font(.subheadline.monospacedDigit().bold())
                }
            } else {
                Text("降水データなし")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 晴れ間ウィンドウカード
    private var dryWindowsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
                Text("晴れ間ウィンドウ")
                    .font(.headline)
            }

            ForEach(viewModel.dryWindows) { window in
                HStack(spacing: 12) {
                    // ステータス
                    if window.isAvailableNow {
                        Text("NOW")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    } else {
                        Text("\(window.minutesUntilStart)分後")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(window.timeRangeText)
                            .font(.subheadline.monospacedDigit().bold())
                        Text(window.durationText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if window.isSufficientForOutdoor {
                        Label("外出OK", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                .padding(10)
                .background(.green.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 分単位プレビューカード
    private var minutePreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.cyan)
                Text("次の60分の降水")
                    .font(.headline)
            }

            // 簡易バーグラフ
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(viewModel.minuteForecasts.prefix(60)) { forecast in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(colorForLevel(forecast.level))
                        .frame(
                            height: max(2, CGFloat(forecast.intensityMmPerHour) * 3)
                        )
                }
            }
            .frame(height: 60)

            // 凡例
            HStack(spacing: 12) {
                Text("今")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("60分後")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var verdictColor: Color {
        switch viewModel.verdict {
        case .goNow: .green
        case .waitThenGo: .orange
        case .stayIndoor: .red
        case .unavailable: .gray
        }
    }

    private func colorForLevel(_ level: PrecipitationLevel) -> Color {
        switch level {
        case .none: .green
        case .light: .cyan
        case .moderate: .blue
        case .heavy: .orange
        case .veryHeavy: .red
        case .extreme: .purple
        }
    }

    private func colorForAlertSeverity(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .minor: .yellow
        case .moderate: .orange
        case .severe: .red
        case .extreme: .purple
        }
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
