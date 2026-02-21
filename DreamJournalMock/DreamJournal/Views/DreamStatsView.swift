import SwiftUI
import Charts

// MARK: - DreamStatsView（夢の統計画面）

struct DreamStatsView: View {
    @Bindable var viewModel: DreamJournalViewModel

    private var stats: DreamStatistics {
        viewModel.calculateStatistics()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // サマリーカード
                    summaryCard

                    // 感情分布チャート
                    emotionDistributionCard

                    // 曜日別記録チャート
                    weekdayChart

                    // トップテーマ
                    topThemesCard

                    // トップシンボル
                    topSymbolsCard

                    // 明晰度・鮮明度
                    metricsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計")
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(.purple)
                Text("ダッシュボード")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                StatBox(value: "\(stats.totalDreams)", label: "記録数", icon: "book.fill", color: .purple)
                StatBox(value: "\(stats.streakDays)", label: "連続日数", icon: "flame.fill", color: .orange)
                StatBox(
                    value: stats.mostFrequentEmotion?.emoji ?? "—",
                    label: "最多感情",
                    icon: "heart.fill",
                    color: .pink
                )
            }

            // 分析率
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("AI 分析率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(stats.analysisRate * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.purple)
                }
                ProgressView(value: stats.analysisRate)
                    .tint(.purple)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Emotion Distribution

    private var emotionDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.indigo)
                Text("感情トーンの分布")
                    .font(.headline)
            }

            if stats.emotionDistribution.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart {
                    ForEach(
                        stats.emotionDistribution.sorted(by: { $0.value > $1.value }),
                        id: \.key.rawValue
                    ) { tone, count in
                        SectorMark(
                            angle: .value("件数", count),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color(tone.colorName))
                        .annotation(position: .overlay) {
                            Text(tone.emoji)
                                .font(.caption)
                        }
                    }
                }
                .frame(height: 200)

                // 凡例
                FlowLayout(spacing: 8) {
                    ForEach(
                        stats.emotionDistribution.sorted(by: { $0.value > $1.value }),
                        id: \.key.rawValue
                    ) { tone, count in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(tone.colorName))
                                .frame(width: 8, height: 8)
                            Text("\(tone.displayName): \(count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Weekday Chart

    private var weekdayChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("曜日別の記録数")
                    .font(.headline)
            }

            if stats.weeklyCount.allSatisfy({ $0.count == 0 }) {
                emptyChartPlaceholder
            } else {
                Chart {
                    ForEach(stats.weeklyCount) { item in
                        BarMark(
                            x: .value("曜日", item.weekday),
                            y: .value("件数", item.count)
                        )
                        .foregroundStyle(.purple.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Top Themes

    private var topThemesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundStyle(.purple)
                Text("頻出テーマ")
                    .font(.headline)
            }

            if stats.topThemes.isEmpty {
                emptyChartPlaceholder
            } else {
                ForEach(Array(stats.topThemes.enumerated()), id: \.element.theme) { index, item in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        Text(item.theme)
                            .font(.subheadline)

                        Spacer()

                        Text("\(item.count) 回")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // バー
                        let maxCount = stats.topThemes.first?.count ?? 1
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.purple.opacity(0.3))
                            .frame(
                                width: CGFloat(item.count) / CGFloat(maxCount) * 80,
                                height: 8
                            )
                    }
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Top Symbols

    private var topSymbolsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.stars")
                    .foregroundStyle(.indigo)
                Text("頻出シンボル")
                    .font(.headline)
            }

            if stats.topSymbols.isEmpty {
                emptyChartPlaceholder
            } else {
                ForEach(Array(stats.topSymbols.enumerated()), id: \.element.symbol) { index, item in
                    HStack {
                        Image(systemName: "diamond.fill")
                            .font(.caption2)
                            .foregroundStyle(.indigo)

                        Text(item.symbol)
                            .font(.subheadline)

                        Spacer()

                        Text("\(item.count) 回")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Metrics Card

    private var metricsCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "eye")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text(String(format: "%.1f", stats.averageLucidity))
                    .font(.title)
                    .fontWeight(.bold)
                Text("平均明晰度")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(spacing: 8) {
                Image(systemName: "paintbrush")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", stats.averageVividness))
                    .font(.title)
                    .fontWeight(.bold)
                Text("平均鮮明度")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Empty Placeholder

    private var emptyChartPlaceholder: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title3)
                    .foregroundStyle(.quaternary)
                Text("データがありません")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - StatBox

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
