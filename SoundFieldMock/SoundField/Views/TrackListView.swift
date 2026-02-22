import SwiftUI

/// トラック一覧画面
struct TrackListView: View {
    let viewModel: SoundFieldViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tracksByGenre, id: \.genre) { genre, tracks in
                    Section {
                        ForEach(tracks) { track in
                            TrackRow(
                                track: track,
                                isPlaying: viewModel.audioManager.currentTrack?.id == track.id
                                    && viewModel.audioManager.isPlaying
                            ) {
                                viewModel.selectAndPlay(track)
                            }
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: genre.icon)
                                .foregroundStyle(genre.color)
                            Text(genre.rawValue)
                                .foregroundStyle(genre.color)
                        }
                    }
                }
            }
            .navigationTitle("トラック")
        }
    }
}

// MARK: - Track Row

private struct TrackRow: View {
    let track: AudioTrack
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                // ジャンルアイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(track.genre.color.gradient)
                        .frame(width: 40, height: 40)
                    Image(systemName: track.genre.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }

                // トラック情報
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(track.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if isPlaying {
                            Image(systemName: "waveform")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .symbolEffect(.variableColor.iterative)
                        }
                    }

                    Text(track.artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // メタ情報
                VStack(alignment: .trailing, spacing: 4) {
                    Text(track.durationText)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("\(track.bpm) BPM")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
