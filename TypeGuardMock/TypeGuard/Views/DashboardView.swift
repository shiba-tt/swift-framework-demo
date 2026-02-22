import SwiftUI

/// タイピングバイオマーカーのダッシュボードビュー
struct DashboardView: View {
    let viewModel: TypeGuardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // リスクスコアカード
                    RiskScoreCard(biomarker: viewModel.latestBiomarker)

                    // 記録ステータス
                    RecordingStatusCard(viewModel: viewModel)

                    // ベースライン偏差
                    if !viewModel.deviations.isEmpty {
                        DeviationSection(deviations: viewModel.deviations)
                    }

                    // メトリクス詳細
                    if let biomarker = viewModel.latestBiomarker {
                        MetricsDetailSection(biomarker: biomarker)
                    }

                    // アラート一覧
                    if !viewModel.alertHistory.isEmpty {
                        AlertSection(alerts: viewModel.alertHistory)
                    }
                }
                .padding()
            }
            .navigationTitle("TypeGuard")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Risk Score Card

private struct RiskScoreCard: View {
    let biomarker: TypingBiomarker?

    var body: some View {
        VStack(spacing: 12) {
            if let biomarker {
                // リスクスコア表示
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: Double(100 - biomarker.riskScore) / 100)
                        .stroke(
                            colorForRisk(biomarker.riskLevel).gradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Image(systemName: biomarker.riskLevel.systemImageName)
                            .font(.title2)
                            .foregroundStyle(colorForRisk(biomarker.riskLevel))
                        Text(biomarker.riskLevel.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)

                // タイピング速度
                HStack(spacing: 4) {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .font(.caption)
                    Text(String(format: "%.0f WPM", biomarker.averageWPM))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.teal.opacity(0.1))
                .clipShape(Capsule())

                Text(biomarker.dateText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("データを収集中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 120)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorForRisk(_ level: RiskLevel) -> Color {
        switch level {
        case .normal: .green
        case .mild: .yellow
        case .moderate: .orange
        case .significant: .red
        }
    }
}

// MARK: - Recording Status

private struct RecordingStatusCard: View {
    let viewModel: TypeGuardViewModel

    var body: some View {
        HStack {
            Circle()
                .fill(viewModel.isRecording ? .green : .gray)
                .frame(width: 10, height: 10)
            Text(viewModel.isRecording ? "キーボード記録中" : "記録停止中")
                .font(.subheadline)

            Spacer()

            Button {
                viewModel.toggleRecording()
            } label: {
                Text(viewModel.isRecording ? "停止" : "開始")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(viewModel.isRecording ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                    .foregroundStyle(viewModel.isRecording ? .red : .green)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Deviation Section

private struct DeviationSection: View {
    let deviations: [DeviationResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ベースラインとの偏差")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(deviations) { deviation in
                DeviationRow(deviation: deviation)
            }
        }
    }
}

private struct DeviationRow: View {
    let deviation: DeviationResult

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: deviation.metricType.systemImageName)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(deviation.metricType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: deviation.deviationPercent > 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", abs(deviation.deviationPercent)))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(colorForDeviation(deviation.level))
                }

                ProgressView(value: min(abs(deviation.deviationPercent), 50), total: 50)
                    .tint(colorForDeviation(deviation.level))

                Text(deviation.level.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorForDeviation(_ level: DeviationLevel) -> Color {
        switch level {
        case .normal: .green
        case .mild: .yellow
        case .moderate: .orange
        case .significant: .red
        }
    }
}

// MARK: - Metrics Detail Section

private struct MetricsDetailSection: View {
    let biomarker: TypingBiomarker

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タイピングメトリクス")
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                MetricRow(
                    icon: "gauge.with.dots.needle.50percent",
                    label: "タイピング速度",
                    value: String(format: "%.1f WPM", biomarker.averageWPM)
                )
                MetricRow(
                    icon: "xmark.circle",
                    label: "エラー率",
                    value: String(format: "%.1f%%", biomarker.errorRate * 100)
                )
                MetricRow(
                    icon: "waveform.path.ecg",
                    label: "リズム変動",
                    value: String(format: "%.3f", biomarker.rhythmVariability)
                )
                MetricRow(
                    icon: "keyboard.badge.exclamationmark",
                    label: "隣接キー誤入力",
                    value: String(format: "%.1f%%", biomarker.adjacentKeyErrorRate * 100)
                )
                MetricRow(
                    icon: "hand.tap",
                    label: "押下時間SD",
                    value: String(format: "%.1f ms", biomarker.pressureDurationSD)
                )
                MetricRow(
                    icon: "face.smiling",
                    label: "感情傾向",
                    value: sentimentText(biomarker.sentimentScore)
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func sentimentText(_ score: Double) -> String {
        switch score {
        case 0.3...: "ポジティブ"
        case -0.3..<0.3: "ニュートラル"
        default: "ネガティブ"
        }
    }
}

private struct MetricRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.teal)
                .frame(width: 20)
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

// MARK: - Alert Section

private struct AlertSection: View {
    let alerts: [AlertRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("アラート履歴")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(alerts) { alert in
                AlertRow(alert: alert)
            }
        }
    }
}

private struct AlertRow: View {
    let alert: AlertRecord

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: alert.severity.systemImageName)
                .foregroundStyle(colorForSeverity(alert.severity))
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(alert.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(alert.dateText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorForSeverity(alert.severity).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorForSeverity(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .info: .blue
        case .warning: .orange
        case .critical: .red
        }
    }
}
