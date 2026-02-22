import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(VideoContent.Genre.allCases, id: \.rawValue) { genre in
                    let videos = viewModel.videoLibrary.filter { $0.genre == genre }
                    if !videos.isEmpty {
                        Section {
                            ForEach(videos) { video in
                                VideoRow(video: video) {
                                    viewModel.selectAndPlay(video)
                                }
                            }
                        } header: {
                            Label(genre.rawValue, systemImage: genre.systemImage)
                        }
                    }
                }
            }
            .navigationTitle("ライブラリ")
        }
    }
}

private struct VideoRow: View {
    let video: VideoContent
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.indigo.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 50)
                    Image(systemName: video.thumbnailSystemImage)
                        .foregroundStyle(.indigo)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                    Text(video.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(video.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
