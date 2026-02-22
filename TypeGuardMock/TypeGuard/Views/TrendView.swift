import SwiftUI

/// タイピングメトリクスのトレンド表示ビュー
struct TrendView: View {
    let viewModel: TypeGuardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間サマリー
                    PeriodSummaryCard(history: viewModel.biomarkerHistory)

                    // リスクスコア推移
                    RiskScoreTrendChart(history: viewModel.biomarkerHistory)

                    // タイピング速度推移
                    SpeedTrendChart(history: viewModel.biomarkerHistory)

                    // エラー率推移
                    ErrorRateTrendChart(history: viewModel.biomarkerHistory)

                    // 日別詳細一覧
                    DailyDetailSection(history: viewModel.biomarkerHistory)
                }
                .padding()
            }
            .navigationTitle("トレンド")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Period Summary Card

private struct PeriodSummaryCard: View {
    let history: [TypingBiomarker]

    private var averageWPM: Double {
        guard !history.isEmpty else { return 0 }
        return history.map(\.averageWPM).reduce(0, +) / Double(history.count)
    }

    private var averageErrorRate: Double {
        guard !history.isEmpty else { return 0 }
        return history.map(\.errorRate).reduce(0, +) / Double(history.count)
    }

    private var recentWPMChange: Double {
        guard history.count >= 7 else { return 0 }
        let recent = history.suffix(7).map(\.averageWPM).reduce(0, +) / 7
        let earlier = history.prefix(7).map(\.averageWPM).reduce(0, +) / 7
        guard earlier > 0 else { return 0 }
        return (recent - earlier) / earlier * 100
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("過去\(history.count)日間のサマリー")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", averageWPM))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("平均WPM")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", averageErrorRate * 100))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("平均エラー率")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Image(systemName: recentWPMChange > 0 ? "arrow.up.right" : recentWPMChange < 0 ? "arrow.down.right" : "arrow.right")
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(recentWPMChange)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(recentWPMChange >= 0 ? .green : .orange)
                    Text("速度変化")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Risk Score Trend Chart

private struct RiskScoreTrendChart: View {
    let history: [TypingBiomarker]

    private var recent: [TypingBiomarker] {
        Array(history.suffix(14))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("リスクスコア推移（直近14日）")
                .font(.headline)
                .padding(.leading, 4)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(recent) { biomarker in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(riskColor(biomarker.riskScore).gradient)
                            .frame(
                                height: max(4, CGFloat(biomarker.riskScore) / 100 * 100)
                            )

                        Text(biomarker.shortDateText)
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func riskColor(_ score: Int) -> Color {
        switch score {
        case ..<25: .green
        case 25..<50: .yellow
        case 50..<75: .orange
        default: .red
        }
    }
}

// MARK: - Speed Trend Chart

private struct SpeedTrendChart: View {
    let history: [TypingBiomarker]

    private var recent: [TypingBiomarker] {
        Array(history.suffix(14))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タイピング速度推移（WPM）")
                .font(.headline)
                .padding(.leading, 4)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(recent) { biomarker in
                    VStack(spacing: 2) {
                        Text(String(format: "%.0f", biomarker.averageWPM))
                            .font(.system(size: 7))
                            .fontWeight(.medium)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(.teal.gradient)
                            .frame(
                                height: max(4, CGFloat(biomarker.averageWPM) / 60 * 100)
                            )

                        Text(biomarker.shortDateText)
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Error Rate Trend Chart

private struct ErrorRateTrendChart: View {
    let history: [TypingBiomarker]

    private var recent: [TypingBiomarker] {
        Array(history.suffix(14))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("エラー率推移")
                .font(.headline)
                .padding(.leading, 4)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(recent) { biomarker in
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", biomarker.errorRate * 100))
                            .font(.system(size: 7))
                            .fontWeight(.medium)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(.orange.gradient)
                            .frame(
                                height: max(4, CGFloat(biomarker.errorRate) / 0.2 * 100)
                            )

                        Text(biomarker.shortDateText)
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Daily Detail Section

private struct DailyDetailSection: View {
    let history: [TypingBiomarker]

    private var recentDays: [TypingBiomarker] {
        Array(history.suffix(7).reversed())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("直近7日間の詳細")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(recentDays) { biomarker in
                DailyRow(biomarker: biomarker)
            }
        }
    }
}

private struct DailyRow: View {
    let biomarker: TypingBiomarker

    var body: some View {
        HStack(spacing: 12) {
            // リスクアイコン
            Image(systemName: biomarker.riskLevel.systemImageName)
                .font(.title3)
                .foregroundStyle(riskColor(biomarker.riskLevel))
                .frame(width: 30)

            // 日付と速度
            VStack(alignment: .leading, spacing: 4) {
                Text(biomarker.dateText)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    Label(
                        String(format: "%.0f WPM", biomarker.averageWPM),
                        systemImage: "gauge.with.dots.needle.50percent"
                    )
                    Label(
                        String(format: "%.1f%%", biomarker.errorRate * 100),
                        systemImage: "xmark.circle"
                    )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // リスクスコアバッジ
            VStack(spacing: 2) {
                Text("\(biomarker.riskScore)")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("リスク")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(riskColor(biomarker.riskLevel).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .normal: .green
        case .mild: .yellow
        case .moderate: .orange
        case .significant: .red
        }
    }
}
