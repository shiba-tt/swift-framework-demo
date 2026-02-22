import SwiftUI

struct GalleryView: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.artworkHistory.isEmpty {
                    ContentUnavailableView(
                        "作品がありません",
                        systemImage: "photo.stack",
                        description: Text("セッション中に作品を保存すると\nここに表示されます")
                    )
                } else {
                    List {
                        Section("保存済み作品 (\(viewModel.artworkHistory.count))") {
                            ForEach(viewModel.artworkHistory) { artwork in
                                ArtworkRow(artwork: artwork)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deleteArtwork(viewModel.artworkHistory[index])
                                }
                            }
                        }

                        Section("エクスポート形式") {
                            ExportFormatRow(
                                icon: "cube.fill", title: "USDZ",
                                desc: "AR Quick Look で閲覧可能な 3D ファイル"
                            )
                            ExportFormatRow(
                                icon: "camera.fill", title: "スクリーンショット",
                                desc: "現在の視点から PNG で書き出し"
                            )
                            ExportFormatRow(
                                icon: "film", title: "タイムラプス動画",
                                desc: "描画過程のタイムラプス MP4"
                            )
                        }
                    }
                }
            }
            .navigationTitle("ギャラリー")
        }
    }
}

private struct ArtworkRow: View {
    let artwork: ArtworkInfo

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                Image(systemName: "scribble.variable")
                    .font(.title2)
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.body.bold())
                HStack(spacing: 12) {
                    Label("\(artwork.artistCount)人", systemImage: "person.2")
                    Label("\(artwork.totalStrokes)画", systemImage: "scribble")
                    Label(artwork.durationText, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                Text(artwork.dateText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                // mock share
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.cyan)
            }
        }
    }
}

private struct ExportFormatRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.cyan)
                .frame(width: 36, height: 36)
                .background(.cyan.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
