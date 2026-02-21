import SwiftUI

/// 日次サマリー画面
struct SummaryView: View {
    let viewModel: GridPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日の概要
                    if let summary = viewModel.dailySummary {
                        dailyOverviewCard(summary)
                        peakAndLowestCard(summary)
                        renewableBreakdownCard(summary)
                    }

                    // 環境への影響
                    environmentalImpactCard
                }
                .padding()
            }
            .navigationTitle("サマリー")
        }
    }

    // MARK: - Subviews

    private func dailyOverviewCard(_ summary: GridDailySummary) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("今日のエネルギー風景")
                    .font(.headline)
                Spacer()
                Text(summary.dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text(summary.themeName)
                    .font(.title2.bold())

                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: summary.averageCleanFraction)
                        .stroke(
                            averageColor(summary.averageCleanFraction),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 4) {
                        Text(summary.averageCleanText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        Text("平均クリーン度")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 150, height: 150)
            }
        }
        .padding()
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func peakAndLowestCard(_ summary: GridDailySummary) -> some View {
        HStack(spacing: 12) {
            // ピーク
            VStack(spacing: 8) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)

                Text("\(Int(summary.peakCleanFraction * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(.green)

                Text("\(summary.peakCleanHour):00")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                Text("最高クリーン度")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 最低
            VStack(spacing: 8) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                Text("\(Int(summary.lowestCleanFraction * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(.red)

                Text("\(summary.lowestCleanHour):00")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                Text("最低クリーン度")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func renewableBreakdownCard(_ summary: GridDailySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text("再生可能エネルギー内訳")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f h", summary.totalSolarHours))
                        .font(.title3.bold())
                    Text("太陽光")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 60)

                VStack(spacing: 8) {
                    Image(systemName: "wind")
                        .font(.largeTitle)
                        .foregroundStyle(.cyan)
                    Text(String(format: "%.1f h", summary.totalWindHours))
                        .font(.title3.bold())
                    Text("風力")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var environmentalImpactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "globe.americas.fill")
                    .foregroundStyle(.teal)
                Text("環境への影響")
                    .font(.headline)
                Spacer()
            }

            let avgClean = viewModel.dailySummary?.averageCleanFraction ?? 0.5
            let co2Avoided = avgClean * 12.5 // デモ値 kg

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", co2Avoided))
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("kg CO₂ 削減")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    Text(String(format: "%.0f", co2Avoided * 3.2))
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("本の木に相当")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("クリーンエネルギーの活用により、化石燃料に比べて約\(String(format: "%.1f", co2Avoided))kgのCO₂排出を回避できました。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.teal.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func averageColor(_ fraction: Double) -> Color {
        switch fraction {
        case 0.7...: .green
        case 0.5..<0.7: .mint
        case 0.3..<0.5: .yellow
        default: .red
        }
    }
}
