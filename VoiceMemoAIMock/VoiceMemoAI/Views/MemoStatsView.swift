import SwiftUI

// MARK: - MemoStatsView

struct MemoStatsView: View {
    @Bindable var viewModel: VoiceMemoAIViewModel

    private var stats: MemoStatistics { viewModel.statistics }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 概要カード
                    overviewSection

                    // カテゴリ別分布
                    categoryDistributionSection

                    // アクションアイテム進捗
                    actionItemsProgressSection

                    // 利用統計
                    usageSection
                }
                .padding()
            }
            .navigationTitle("統計")
        }
    }

    // MARK: - Overview

    private var overviewSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatBox(
                value: "\(stats.totalCount)",
                label: "総メモ数",
                icon: "doc.text.fill",
                color: .indigo
            )
            StatBox(
                value: "\(stats.thisWeekCount)",
                label: "今週の記録",
                icon: "calendar",
                color: .blue
            )
            StatBox(
                value: stats.formattedAverageDuration,
                label: "平均録音時間",
                icon: "waveform",
                color: .purple
            )
        }
    }

    // MARK: - Category Distribution

    private var categoryDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.orange)
                Text("カテゴリ別分布")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                ForEach(MemoCategory.allCases) { category in
                    let count = stats.categoryCounts[category] ?? 0
                    let ratio = stats.totalCount > 0 ? Double(count) / Double(stats.totalCount) : 0

                    HStack(spacing: 12) {
                        Text(category.emoji)
                            .frame(width: 28)

                        Text(category.displayName)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(category.color)
                                    .frame(width: geometry.size.width * ratio, height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Items Progress

    private var actionItemsProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checklist")
                    .foregroundStyle(.green)
                Text("アクションアイテム")
                    .font(.headline)
            }

            HStack(spacing: 20) {
                // プログレスリング
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: stats.completionRate)
                        .stroke(
                            stats.completionRate > 0.7 ? Color.green : stats.completionRate > 0.4 ? Color.orange : Color.red,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(stats.completionRate * 100))%")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(.green).frame(width: 8, height: 8)
                        Text("完了: \(stats.completedActionItems)")
                            .font(.subheadline)
                    }
                    HStack(spacing: 6) {
                        Circle().fill(.orange).frame(width: 8, height: 8)
                        Text("未完了: \(stats.pendingActionItems)")
                            .font(.subheadline)
                    }
                    Text("合計: \(stats.completedActionItems + stats.pendingActionItems) 件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Usage

    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                Text("AI 構造化エンジン")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "使用フレームワーク", value: "Foundation Models")
                InfoRow(label: "処理方式", value: "完全オンデバイス")
                InfoRow(label: "構造化出力", value: "@Generable マクロ")
                InfoRow(label: "音声認識", value: "Speech Framework")
                InfoRow(label: "プライバシー", value: "データはデバイス内で完結")
            }
        }
        .padding()
        .background(Color.indigo.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .font(.title3)
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - InfoRow

struct InfoRow: View {
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
