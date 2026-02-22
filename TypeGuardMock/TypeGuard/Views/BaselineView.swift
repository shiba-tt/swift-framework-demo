import SwiftUI

/// ベースラインプロファイルの管理ビュー
struct BaselineView: View {
    let viewModel: TypeGuardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ベースラインステータス
                    BaselineStatusCard(baseline: viewModel.metricsManager.baseline)

                    // ベースライン値
                    if viewModel.metricsManager.baseline.isEstablished {
                        BaselineValuesSection(baseline: viewModel.metricsManager.baseline)
                    }

                    // メトリクス説明
                    MetricsExplanationSection()

                    // 研究についての注意
                    ResearchNoticeCard()
                }
                .padding()
            }
            .navigationTitle("ベースライン")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Baseline Status Card

private struct BaselineStatusCard: View {
    let baseline: BaselineProfile

    var body: some View {
        VStack(spacing: 16) {
            // プログレス
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: baseline.completionRate)
                    .stroke(
                        baseline.isEstablished ? Color.green.gradient : Color.teal.gradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Image(systemName: baseline.isEstablished ? "checkmark.circle.fill" : "hourglass")
                        .font(.title2)
                        .foregroundStyle(baseline.isEstablished ? .green : .teal)
                    Text(baseline.isEstablished ? "確立済み" : "構築中")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .frame(width: 100, height: 100)

            Text(baseline.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !baseline.isEstablished {
                Text("ベースラインが確立されるまで、日常のタイピングを続けてください。7日間分のデータが集まると、あなたの「普段」のパターンが確立されます。")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Baseline Values

private struct BaselineValuesSection: View {
    let baseline: BaselineProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ベースライン値")
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                BaselineRow(
                    icon: "gauge.with.dots.needle.50percent",
                    label: "タイピング速度",
                    value: String(format: "%.1f WPM", baseline.baselineWPM)
                )
                BaselineRow(
                    icon: "xmark.circle",
                    label: "エラー率",
                    value: String(format: "%.2f%%", baseline.baselineErrorRate * 100)
                )
                BaselineRow(
                    icon: "waveform.path.ecg",
                    label: "リズム変動",
                    value: String(format: "%.3f", baseline.baselineRhythmVariability)
                )
                BaselineRow(
                    icon: "keyboard.badge.exclamationmark",
                    label: "隣接キー誤入力率",
                    value: String(format: "%.2f%%", baseline.baselineAdjacentKeyErrorRate * 100)
                )
                BaselineRow(
                    icon: "hand.tap",
                    label: "押下時間SD",
                    value: String(format: "%.1f ms", baseline.baselinePressureDurationSD)
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct BaselineRow: View {
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
                .monospacedDigit()
        }
    }
}

// MARK: - Metrics Explanation

private struct MetricsExplanationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("バイオマーカーとは")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(TypingMetricType.allCases, id: \.self) { metric in
                ExplanationRow(metric: metric)
            }
        }
    }
}

private struct ExplanationRow: View {
    let metric: TypingMetricType

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: metric.systemImageName)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(metric.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(metric.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Research Notice

private struct ResearchNoticeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.teal)
                Text("研究アプリについて")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("TypeGuard は SensorKit のキーボードメトリクスを活用した研究アプリです。本アプリのデータは医療診断を目的としたものではなく、神経疾患のスクリーニング研究に活用されます。")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("気になる症状がある場合は、必ず医師にご相談ください。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
        .padding()
        .background(.teal.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
