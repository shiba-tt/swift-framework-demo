import SwiftUI

/// 週間レポート・統計画面
struct ReportView: View {
    @Bindable var viewModel: WattWiseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let report = viewModel.weeklyReport {
                        weeklyOverview(report)
                        dailyCleanRateChart(report)
                        achievementsCard(report)
                    }
                    gridDetailCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("レポート")
        }
    }

    // MARK: - 週間概要

    private func weeklyOverview(_ report: WeeklyReport) -> some View {
        VStack(spacing: 16) {
            Text("第 \(report.weekNumber) 週 レポート")
                .font(.headline)

            HStack(spacing: 20) {
                reportBadge(
                    icon: "leaf.fill",
                    value: String(format: "%.1f kg", report.totalCO2Reduction),
                    label: "CO2 削減",
                    color: .green
                )
                reportBadge(
                    icon: "dollarsign.circle.fill",
                    value: String(format: "$%.2f", report.totalCostSaving),
                    label: "コスト削減",
                    color: .blue
                )
                reportBadge(
                    icon: "bolt.fill",
                    value: "\(Int(report.averageCleanRate * 100))%",
                    label: "平均クリーン率",
                    color: .mint
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func reportBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 日別クリーン率チャート

    private func dailyCleanRateChart(_ report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("日別クリーンエネルギー率", systemImage: "chart.bar.fill")
                .font(.headline)

            let dayLabels = ["月", "火", "水", "木", "金", "土", "日"]

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(report.dailyCleanRates.enumerated()), id: \.offset) { index, rate in
                    VStack(spacing: 4) {
                        Text("\(Int(rate * 100))%")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(rateColor(rate))
                            .frame(height: CGFloat(rate) * 120)

                        Text(dayLabels[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 達成バッジ

    private func achievementsCard(_ report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("達成バッジ", systemImage: "medal.fill")
                .font(.headline)
                .foregroundStyle(.yellow)

            let badges: [(String, String, Bool)] = [
                ("🌱", "グリーンウィーク: 平均クリーン率 70% 以上", report.averageCleanRate >= 0.70),
                ("💰", "セーバー: 週間コスト削減 $10 以上", report.totalCostSaving >= 10.0),
                ("🌍", "エコヒーロー: CO2 削減 10kg 以上", report.totalCO2Reduction >= 10.0),
                ("🎯", "チャレンジャー: 週間チャレンジ達成", report.challengeAchieved),
            ]

            ForEach(Array(badges.enumerated()), id: \.offset) { _, badge in
                HStack(spacing: 12) {
                    Text(badge.0)
                        .font(.title2)
                        .opacity(badge.2 ? 1.0 : 0.3)

                    Text(badge.1)
                        .font(.caption)
                        .foregroundStyle(badge.2 ? .primary : .secondary)

                    Spacer()

                    if badge.2 {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - グリッド詳細

    private var gridDetailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("時間帯別グリッド詳細", systemImage: "clock.fill")
                .font(.headline)

            let peakSlots = viewModel.gridTimeSlots.filter {
                if case .dirty = $0.cleanLevel { return true }
                return false
            }
            let cleanSlots = viewModel.gridTimeSlots.filter {
                if case .veryClean = $0.cleanLevel { return true }
                return false
            }

            if !cleanSlots.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("クリーンな時間帯:")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(cleanSlots.map { $0.timeLabel }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !peakSlots.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("ピーク時間帯:")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(peakSlots.map { $0.timeLabel }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("ピーク時間帯を避けてデバイスを使用すると、コスト削減と CO2 削減に貢献できます")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - ヘルパー

    private func rateColor(_ rate: Double) -> Color {
        switch rate {
        case 0.8...: .green
        case 0.7..<0.8: .mint
        case 0.6..<0.7: .yellow
        default: .orange
        }
    }
}
