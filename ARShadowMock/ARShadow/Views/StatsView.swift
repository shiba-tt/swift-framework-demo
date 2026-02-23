import SwiftUI

struct StatsView: View {
    var viewModel: ARShadowViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    overallStatsCard
                }

                Section("ステージ別記録") {
                    ForEach(viewModel.stages.filter { $0.bestScore != nil }) { stage in
                        stageStatRow(stage)
                    }
                }

                if !viewModel.gameResults.isEmpty {
                    Section("最近のプレイ") {
                        ForEach(viewModel.gameResults.suffix(10).reversed()) { result in
                            recentResultRow(result)
                        }
                    }
                }
            }
            .navigationTitle("記録")
        }
    }

    // MARK: - Overall Stats

    private var overallStatsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                statBadge(
                    icon: "star.fill",
                    value: "\(viewModel.totalStars)",
                    label: "スター",
                    color: .yellow
                )

                statBadge(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.completedStages)",
                    label: "クリア",
                    color: .green
                )

                statBadge(
                    icon: "gamecontroller.fill",
                    value: "\(viewModel.gameResults.count)",
                    label: "プレイ回数",
                    color: .blue
                )
            }

            if !viewModel.stages.filter({ $0.bestScore != nil }).isEmpty {
                let averageScore = viewModel.stages
                    .compactMap(\.bestScore)
                    .reduce(0, +) / max(viewModel.completedStages, 1)

                HStack {
                    Text("平均スコア")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(averageScore)%")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stage Stat Row

    private func stageStatRow(_ stage: PuzzleStage) -> some View {
        HStack(spacing: 12) {
            Image(systemName: stage.targetShape.systemImage)
                .font(.title3)
                .foregroundStyle(stage.targetShape.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .font(.subheadline.bold())
                Text(stage.difficulty.rawValue)
                    .font(.caption)
                    .foregroundStyle(stage.difficulty.color)
            }

            Spacer()

            if let bestScore = stage.bestScore {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(bestScore)%")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { star in
                            Image(systemName: star <= stage.starRating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundStyle(star <= stage.starRating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Result Row

    private func recentResultRow(_ result: GameResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.stage.targetShape.systemImage)
                .font(.body)
                .foregroundStyle(result.stage.targetShape.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.stage.name)
                    .font(.subheadline)
                Text(result.completedDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(result.score)%")
                .font(.subheadline.bold())
                .foregroundStyle(result.score >= 80 ? .green : result.score >= 60 ? .orange : .red)
        }
    }
}

#Preview {
    StatsView(viewModel: ARShadowViewModel())
}
