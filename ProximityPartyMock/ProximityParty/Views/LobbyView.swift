import SwiftUI

struct LobbyView: View {
    let viewModel: ProximityPartyViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                gameModeSection
                playersSection
            }
            .padding()
        }
        .navigationTitle("ProximityParty")
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("空間認識パーティゲーム")
                .font(.title2.bold())

            Text("UWB で物理空間をゲームフィールドに")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !viewModel.isDeviceSupported {
                Label("このデバイスは UWB に対応していません", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical)
    }

    private var gameModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ゲームモード")
                .font(.headline)

            ForEach(GameMode.allCases) { mode in
                gameModeCard(mode)
            }
        }
    }

    private func gameModeCard(_ mode: GameMode) -> some View {
        Button {
            viewModel.startGame(mode: mode)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(modeColor(mode), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text("\(mode.minPlayers)〜\(mode.maxPlayers)人")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("検出されたプレイヤー")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.players.count)人")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.players) { player in
                HStack(spacing: 12) {
                    Text(player.avatarEmoji)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.subheadline.bold())
                        Text(player.distanceText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(player.color.emoji)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .spatialTag: return .red
        case .treasureHunt: return .orange
        case .distanceQuiz: return .blue
        }
    }
}
