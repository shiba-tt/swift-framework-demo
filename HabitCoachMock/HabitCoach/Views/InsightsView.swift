import SwiftUI

struct InsightsView: View {
    @Bindable var viewModel: HabitCoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weeklyOverviewSection
                    categoryStatsSection
                    siriLearningSection
                    techStackSection
                }
                .padding()
            }
            .navigationTitle("インサイト")
        }
    }

    // MARK: - Weekly Overview

    private var weeklyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週のサマリー")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                insightCard(
                    title: "達成率",
                    value: "\(Int(viewModel.overallCompletionRatio * 100))%",
                    icon: "chart.pie.fill",
                    color: .indigo
                )
                insightCard(
                    title: "完了した習慣",
                    value: "\(viewModel.totalCompletedToday)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                insightCard(
                    title: "最長ストリーク",
                    value: "\(longestCurrentStreak)日",
                    icon: "flame.fill",
                    color: .orange
                )
                insightCard(
                    title: "記録数",
                    value: "\(viewModel.todayLogs.count)件",
                    icon: "doc.text.fill",
                    color: .blue
                )
            }
        }
    }

    private var longestCurrentStreak: Int {
        viewModel.habits.compactMap { viewModel.streak(for: $0)?.currentStreak }.max() ?? 0
    }

    private func insightCard(
        title: String, value: String, icon: String, color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Stats

    private var categoryStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別達成状況")
                .font(.headline)

            ForEach(viewModel.habitsByCategory, id: \.category) { group in
                let completed = group.habits.filter { viewModel.isCompleted($0) }.count
                let total = group.habits.count
                let ratio = total > 0 ? Double(completed) / Double(total) : 0

                HStack(spacing: 12) {
                    Text(group.category.emoji)
                        .frame(width: 28)

                    Text(group.category.rawValue)
                        .font(.subheadline)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(group.category.color)
                                .frame(width: geometry.size.width * ratio)
                        }
                    }
                    .frame(height: 10)

                    Text("\(completed)/\(total)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Siri Learning

    private var siriLearningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI コーチの学習状況")
                    .font(.headline)
                Image(systemName: "brain")
                    .foregroundStyle(.indigo)
            }

            VStack(alignment: .leading, spacing: 8) {
                learningItem(
                    pattern: "朝 6:30 — ストレッチ",
                    confidence: 0.92,
                    detail: "平日の朝に高い確率で実行"
                )
                learningItem(
                    pattern: "通勤中 — 英語の勉強",
                    confidence: 0.78,
                    detail: "電車での移動時間に学習する傾向"
                )
                learningItem(
                    pattern: "昼食後 — 水を飲む",
                    confidence: 0.85,
                    detail: "12:00〜13:00に水分補給する傾向"
                )
                learningItem(
                    pattern: "就寝前 — 読書・日記",
                    confidence: 0.88,
                    detail: "21:00以降に読書と日記を連続して行う傾向"
                )
            }

            Text("※ iOS のコンテキスト学習により、アプリ側でのリマインダーロジックが不要。使用パターンを自動分析し、最適なタイミングで Siri が提案します。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func learningItem(pattern: String, confidence: Double, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkle")
                .foregroundStyle(.indigo)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pattern)
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(Int(confidence * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.gray.opacity(0.1))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.indigo.opacity(0.6))
                            .frame(width: geometry.size.width * confidence)
                    }
                }
                .frame(height: 4)
            }
        }
    }

    // MARK: - Tech Stack

    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用フレームワーク")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                techItem("App Intents", detail: "各習慣を Intent として定義、Siri・Shortcuts から実行")
                techItem("コンテキスト学習", detail: "iOS が使用パターン（時間帯・場所・前後アクション）を自動学習")
                techItem("WidgetKit", detail: "ロック画面に習慣達成状況をリング表示")
                techItem("Live Activity", detail: "進行中の習慣（瞑想タイマー等）をリアルタイム表示")
                techItem("Control Center", detail: "よく使う習慣のトグルボタンを配置")
                techItem("Action Button", detail: "物理ボタンに最頻習慣を割り当て")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func techItem(_ name: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.indigo)
                .frame(width: 12)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    InsightsView(viewModel: HabitCoachViewModel())
}
