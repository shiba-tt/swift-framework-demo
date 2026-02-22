import SwiftUI

struct ResultsView: View {
    let viewModel: ProximityPartyViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    trophyHeader
                    rankingSection
                    statsSection
                }
                .padding()
            }
            .navigationTitle("結果発表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.resetGame()
                    }
                }
            }
        }
    }

    // MARK: - Components

    private var trophyHeader: some View {
        VStack(spacing: 12) {
            if let winner = viewModel.gameResults.first {
                Text(winner.player.avatarEmoji)
                    .font(.system(size: 64))
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)
                Text("\(winner.player.name) の勝利!")
                    .font(.title2.bold())
                Text(winner.achievement)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)
                Text("ゲーム終了")
                    .font(.title2.bold())
            }
        }
        .padding(.vertical)
    }

    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ランキング")
                .font(.headline)

            ForEach(viewModel.gameResults) { result in
                HStack(spacing: 12) {
                    rankBadge(result.rank)

                    Text(result.player.avatarEmoji)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.player.name)
                            .font(.subheadline.bold())
                        Text(result.achievement)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(result.score) pt")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func rankBadge(_ rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(rankColor(rank))
                .frame(width: 32, height: 32)
            Text("\(rank)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ゲーム統計")
                .font(.headline)

            if let session = viewModel.session {
                HStack(spacing: 16) {
                    statItem(
                        title: "モード",
                        value: session.mode.rawValue,
                        icon: session.mode.icon
                    )
                    statItem(
                        title: "プレイヤー",
                        value: "\(session.players.count)人",
                        icon: "person.3.fill"
                    )
                    statItem(
                        title: "ラウンド",
                        value: "\(session.roundNumber)/\(session.totalRounds)",
                        icon: "arrow.triangle.2.circlepath"
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.subheadline.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
