import SwiftUI

struct GalleryView: View {
    @Bindable var viewModel: CineMagicViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.capturedMedia.isEmpty {
                    emptyState
                } else {
                    mediaList
                }
            }
            .navigationTitle("ギャラリー")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("まだ撮影がありません")
                .font(.title3)
                .fontWeight(.semibold)

            Text("撮影タブで映画フィルターを使って撮影しましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.selectedTab = .camera
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("撮影を開始")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.orange)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
    }

    // MARK: - Media List

    private var mediaList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Statistics
                statisticsCard

                // Media items
                ForEach(viewModel.capturedMedia) { media in
                    mediaRow(media)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Statistics

    private var statisticsCard: some View {
        HStack(spacing: 16) {
            statTile(
                title: "写真",
                value: "\(viewModel.photoCount)",
                icon: "camera.fill",
                color: .blue
            )
            statTile(
                title: "動画",
                value: "\(viewModel.videoCount)",
                icon: "video.fill",
                color: .red
            )
            statTile(
                title: "平均スコア",
                value: String(format: "%.0f%%", viewModel.averageScore * 100),
                icon: "star.fill",
                color: .yellow
            )
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Media Row

    private func mediaRow(_ media: CapturedMedia) -> some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(media.filter.color.opacity(0.2))
                    .frame(width: 64, height: 64)

                VStack(spacing: 2) {
                    Text(media.filter.emoji)
                        .font(.title2)
                    Image(systemName: media.mode.icon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(media.filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(media.mode.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(media.mode == .photo ? .blue : .red)
                        .clipShape(Capsule())
                }

                if let duration = media.duration {
                    Text("撮影時間: \(media.formattedDuration)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let _ = duration  // suppress unused warning
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(media.scoreColor)
                    Text(media.scoreLabel)
                        .foregroundStyle(media.scoreColor)
                    Text(String(format: "(%.0f%%)", media.compositionScore * 100))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)

                Text(media.capturedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button(role: .destructive) {
                viewModel.deleteMedia(media)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    GalleryView(viewModel: CineMagicViewModel())
}
