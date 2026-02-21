import SwiftUI

/// 各センサーの詳細データ表示ビュー
struct SensorDetailView: View {
    let viewModel: MindMirrorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // タイピングメトリクス
                    if let typing = viewModel.todayMetrics?.typing {
                        TypingSection(metrics: typing)
                    }

                    // デバイス使用
                    if let device = viewModel.todayMetrics?.deviceUsage {
                        DeviceUsageSection(metrics: device)
                    }

                    // コミュニケーション
                    if let comm = viewModel.todayMetrics?.communication {
                        CommunicationSection(metrics: comm)
                    }

                    // 移動・訪問
                    if let mobility = viewModel.todayMetrics?.mobility {
                        MobilitySection(metrics: mobility)
                    }

                    // 環境光
                    if let light = viewModel.todayMetrics?.ambientLight {
                        AmbientLightSection(metrics: light)
                    }

                    // データなしの場合
                    if viewModel.todayMetrics == nil {
                        NoDataView()
                    }
                }
                .padding()
            }
            .navigationTitle("センサーデータ")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Typing Section

private struct TypingSection: View {
    let metrics: TypingMetrics

    var body: some View {
        SensorCard(
            title: "キーボードメトリクス",
            icon: "keyboard.fill",
            level: metrics.speedLevel
        ) {
            MetricRow(label: "タイピング速度", value: String(format: "%.0f WPM", metrics.averageWPM))
            MetricRow(label: "エラー率", value: String(format: "%.1f%%", metrics.errorRate * 100))
            MetricRow(label: "リズム変動", value: String(format: "%.2f", metrics.rhythmVariability))
            MetricRow(label: "感情スコア", value: sentimentText(metrics.sentimentScore))
        }
    }

    private func sentimentText(_ score: Double) -> String {
        switch score {
        case 0.3...: "ポジティブ (\(String(format: "%.1f", score)))"
        case -0.3..<0.3: "ニュートラル (\(String(format: "%.1f", score)))"
        default: "ネガティブ (\(String(format: "%.1f", score)))"
        }
    }
}

// MARK: - Device Usage Section

private struct DeviceUsageSection: View {
    let metrics: DeviceUsageMetrics

    var body: some View {
        SensorCard(
            title: "デバイス使用",
            icon: "iphone",
            level: metrics.screenTimeLevel
        ) {
            MetricRow(label: "画面使用時間", value: formatMinutes(metrics.totalScreenTimeMinutes))
            MetricRow(label: "画面起動", value: "\(metrics.screenWakeCount)回")
            MetricRow(label: "アンロック", value: "\(metrics.unlockCount)回")

            if !metrics.categoryUsage.isEmpty {
                Divider()
                ForEach(metrics.categoryUsage) { usage in
                    MetricRow(
                        label: usage.category,
                        value: formatMinutes(usage.usageMinutes)
                    )
                }
            }
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)時間\(mins)分"
        }
        return "\(mins)分"
    }
}

// MARK: - Communication Section

private struct CommunicationSection: View {
    let metrics: CommunicationMetrics

    var body: some View {
        SensorCard(
            title: "コミュニケーション",
            icon: "message.fill",
            level: metrics.socialLevel
        ) {
            MetricRow(label: "発信", value: "\(metrics.outgoingCalls)回")
            MetricRow(label: "着信", value: "\(metrics.incomingCalls)回")
            MetricRow(label: "通話時間", value: "\(metrics.totalCallMinutes)分")
            Divider()
            MetricRow(label: "送信メッセージ", value: "\(metrics.outgoingMessages)通")
            MetricRow(label: "受信メッセージ", value: "\(metrics.incomingMessages)通")
        }
    }
}

// MARK: - Mobility Section

private struct MobilitySection: View {
    let metrics: MobilityMetrics

    var body: some View {
        SensorCard(
            title: "行動・移動",
            icon: "location.fill",
            level: metrics.mobilityLevel
        ) {
            MetricRow(label: "訪問場所数", value: "\(metrics.visitedPlaceCount)箇所")
            MetricRow(label: "外出時間", value: formatMinutes(metrics.awayTimeMinutes))
            MetricRow(label: "自宅滞在", value: formatMinutes(metrics.homeTimeMinutes))
            MetricRow(
                label: "最大移動距離",
                value: String(format: "%.1f km", metrics.maxDistanceFromHomeKm)
            )
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)時間\(mins)分"
        }
        return "\(mins)分"
    }
}

// MARK: - Ambient Light Section

private struct AmbientLightSection: View {
    let metrics: AmbientLightMetrics

    var body: some View {
        SensorCard(
            title: "環境光",
            icon: "sun.max.fill",
            level: metrics.lightLevel
        ) {
            MetricRow(label: "平均照度", value: String(format: "%.0f lux", metrics.averageLux))
            MetricRow(label: "日中ピーク", value: String(format: "%.0f lux", metrics.peakDaytimeLux))
            MetricRow(label: "夜間平均", value: String(format: "%.0f lux", metrics.nighttimeAverageLux))
            MetricRow(label: "明るい環境", value: "\(metrics.brightExposureMinutes)分")
        }
    }
}

// MARK: - Shared Components

private struct SensorCard<Content: View>: View {
    let title: String
    let icon: String
    let level: MetricLevel
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.purple)
                Text(title)
                    .font(.headline)
                Spacer()
                LevelBadge(level: level)
            }

            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct LevelBadge: View {
    let level: MetricLevel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.systemImageName)
                .font(.caption2)
            Text(level.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorForLevel(level).opacity(0.12))
        .foregroundStyle(colorForLevel(level))
        .clipShape(Capsule())
    }

    private func colorForLevel(_ level: MetricLevel) -> Color {
        switch level {
        case .good: .green
        case .moderate: .orange
        case .concern: .red
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - No Data

private struct NoDataView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sensor.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("センサーデータがありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("記録を開始してデータが蓄積されるまで\n24時間以上お待ちください")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}
