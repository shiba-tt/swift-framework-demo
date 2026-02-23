import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: AIFormCoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallStatsSection
                    weeklyChart
                    dailyHistorySection
                    techStackSection
                }
                .padding()
            }
            .navigationTitle("トレーニング履歴")
        }
    }

    // MARK: - Overall Stats

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("全体サマリー")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                summaryCard(
                    title: "平均スコア",
                    value: "\(viewModel.overallAverageScore)",
                    icon: "chart.bar.fill",
                    color: .cyan
                )
                summaryCard(
                    title: "総ワークアウト",
                    value: "\(viewModel.totalWorkouts)",
                    icon: "figure.strengthtraining.traditional",
                    color: .green
                )
                summaryCard(
                    title: "総レップ数",
                    value: "\(viewModel.totalRepsAllTime)",
                    icon: "repeat",
                    color: .purple
                )
                summaryCard(
                    title: "トレーニング日数",
                    value: "\(viewModel.history.count)日",
                    icon: "calendar",
                    color: .orange
                )
            }
        }
    }

    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
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

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間スコア推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.history.reversed()) { day in
                    VStack(spacing: 4) {
                        Text("\(day.averageScore)")
                            .font(.system(size: 10, weight: .bold).monospacedDigit())
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(day.averageScore))
                            .frame(height: CGFloat(day.averageScore) * 1.2)

                        Text(shortDateText(day.date))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(_ score: Int) -> Color {
        switch score {
        case 85...100: .green
        case 70..<85: .cyan
        case 55..<70: .yellow
        default: .red
        }
    }

    private func shortDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    // MARK: - Daily History

    private var dailyHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別詳細")
                .font(.headline)

            ForEach(viewModel.history) { day in
                dayCard(day)
            }
        }
    }

    private func dayCard(_ day: DailyWorkoutSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.dateText)
                    .font(.subheadline.bold())
                Spacer()
                HStack(spacing: 4) {
                    Text("平均 \(day.averageScore)")
                        .font(.caption.bold().monospacedDigit())
                        .foregroundStyle(.cyan)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("\(day.totalReps) 回")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(day.exerciseSummaries) { summary in
                HStack(spacing: 10) {
                    Image(systemName: summary.exercise.icon)
                        .font(.caption)
                        .foregroundStyle(summary.exercise.color)
                        .frame(width: 24)

                    Text(summary.exercise.rawValue)
                        .font(.caption)

                    Spacer()

                    HStack(spacing: 12) {
                        HStack(spacing: 2) {
                            Text("\(summary.reps)")
                                .font(.caption.monospacedDigit())
                            Text("回")
                                .font(.system(size: 9))
                        }
                        .foregroundStyle(.secondary)

                        HStack(spacing: 2) {
                            Text("Avg")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            Text("\(summary.averageScore)")
                                .font(.caption.bold().monospacedDigit())
                        }

                        HStack(spacing: 2) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text("\(summary.bestScore)")
                                .font(.caption.bold().monospacedDigit())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tech Stack

    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用フレームワーク")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                techItem("Vision (VNDetectHumanBodyPoseRequest)", detail: "カメラフィードからリアルタイムに 19 の関節点を検出")
                techItem("Core ML (カスタムモデル)", detail: "関節角度の時系列データからフォーム品質を 0-100 でスコアリング")
                techItem("Create ML", detail: "アクティビティ分類で「良いフォーム / 悪いフォーム」のパターンを学習")
                techItem("Foundation Models", detail: "スコアと関節データから自然言語のアドバイスを生成")
                techItem("ARKit (AR オーバーレイ)", detail: "理想の骨格ラインを半透明で重ね、フォームの差を視覚化")
                techItem("App Intents", detail: "「Hey Siri、スクワットのフォームチェック」で即起動")
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
                .foregroundStyle(.cyan)
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
    HistoryView(viewModel: AIFormCoachViewModel())
}
