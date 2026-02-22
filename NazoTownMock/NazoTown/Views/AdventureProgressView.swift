import SwiftUI

struct AdventureProgressView: View {
    @Bindable var viewModel: NazoTownViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallStatsCard
                    adventureHistorySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("記録")
        }
    }

    // MARK: - Overall Stats

    private var overallStatsCard: some View {
        VStack(spacing: 16) {
            Text("全体スコア")
                .font(.headline)

            let allResults = viewModel.availableAdventures.flatMap(\.results)
            let totalScore = allResults.reduce(0) { $0 + $1.scorePoints }
            let solvedCount = allResults.filter(\.isSolved).count

            HStack(spacing: 24) {
                statCircle(
                    value: "\(totalScore)",
                    label: "総ポイント",
                    color: .indigo
                )

                statCircle(
                    value: "\(solvedCount)",
                    label: "正解数",
                    color: .green
                )

                statCircle(
                    value: "\(viewModel.availableAdventures.filter { $0.status == .completed }.count)",
                    label: "完了コース",
                    color: .orange
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func statCircle(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Adventure History

    private var adventureHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("冒険履歴")
                .font(.headline)

            ForEach(viewModel.availableAdventures) { adventure in
                adventureHistoryCard(adventure)
            }
        }
    }

    private func adventureHistoryCard(_ adventure: Adventure) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(adventure.title)
                    .font(.subheadline.bold())

                Spacer()

                Text(adventure.status.displayName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(adventure.status).opacity(0.15))
                    .foregroundStyle(statusColor(adventure.status))
                    .clipShape(Capsule())
            }

            if !adventure.results.isEmpty {
                HStack(spacing: 4) {
                    ForEach(Array(adventure.spots.enumerated()), id: \.element.id) { index, _ in
                        Circle()
                            .fill(spotStatusColor(index: index, adventure: adventure))
                            .frame(width: 12, height: 12)
                    }
                }

                HStack {
                    Text("スコア: \(adventure.totalScore) pt")
                    Spacer()
                    Text("正解: \(adventure.solvedCount) / \(adventure.spots.count)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Text("未挑戦")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func spotStatusColor(index: Int, adventure: Adventure) -> Color {
        guard index < adventure.results.count else {
            return .gray.opacity(0.3)
        }
        return adventure.results[index].isSolved ? .green : .red
    }

    private func statusColor(_ status: AdventureStatus) -> Color {
        switch status {
        case .notStarted: .secondary
        case .inProgress: .blue
        case .completed: .green
        case .expired: .red
        }
    }
}
