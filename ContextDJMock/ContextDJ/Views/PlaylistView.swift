import SwiftUI

struct PlaylistView: View {
    @Bindable var viewModel: ContextDJViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recentPlaylists.isEmpty {
                    ContentUnavailableView(
                        "プレイリストがありません",
                        systemImage: "music.note.list",
                        description: Text("DJタブでコンテキスト再生を開始すると、プレイリストが生成されます")
                    )
                } else {
                    playlistList
                }
            }
            .navigationTitle("プレイリスト")
        }
    }

    // MARK: - Playlist List

    private var playlistList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.recentPlaylists) { playlist in
                    playlistCard(playlist)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Playlist Card

    private func playlistCard(_ playlist: Playlist) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: playlist.mood.icon)
                    .font(.title3)
                    .foregroundStyle(playlist.mood.color)
                    .frame(width: 40, height: 40)
                    .background(playlist.mood.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(playlist.name)
                        .font(.headline)

                    Text(playlist.context.contextTag)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(playlist.songs.count)曲")
                        .font(.caption.bold())
                    Text(playlist.totalDurationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(playlist.songs.prefix(5)) { song in
                        songChip(song)
                    }
                    if playlist.songs.count > 5 {
                        Text("+\(playlist.songs.count - 5)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(Array(Set(playlist.songs.map(\.genre))).prefix(3), id: \.rawValue) { genre in
                    Text(genre.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(genre.color.opacity(0.1))
                        .foregroundStyle(genre.color)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(playlist.generatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Song Chip

    private func songChip(_ song: Song) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(song.artworkColor)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: song.genre.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(song.title)
                    .font(.caption2.bold())
                    .lineLimit(1)
                Text(song.artist)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
