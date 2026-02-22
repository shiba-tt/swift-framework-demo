import SwiftUI

struct AlbumListView: View {
    @Bindable var viewModel: SmartSnapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.albums.isEmpty {
                        emptyState
                    } else {
                        aiStatusBanner
                        albumGrid
                    }
                }
                .padding()
            }
            .navigationTitle("SmartSnap")
            .sheet(item: $viewModel.selectedAlbum) { album in
                AlbumDetailView(viewModel: viewModel, album: album)
            }
        }
    }

    // MARK: - AI Status Banner

    private var aiStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "apple.intelligence")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("AI による自動分類")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Vision + Foundation Models で写真を分析・整理")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(viewModel.isModelAvailable ? .green : .red)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("アルバムがありません")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("写真を追加するとAIが自動的に\nアルバムを生成します")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - Album Grid

    private var albumGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("自動生成されたアルバム")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.albums) { album in
                    albumCard(album)
                        .onTapGesture {
                            viewModel.selectAlbum(album)
                        }
                }
            }
        }
    }

    private func albumCard(_ album: Album) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // カバー画像（モック）
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(albumColorName(album.category)).opacity(0.15))
                    .frame(height: 120)

                VStack(spacing: 6) {
                    Text(album.category.emoji)
                        .font(.largeTitle)
                    Image(systemName: album.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(album.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !album.dateRange.isEmpty {
                    Text(album.dateRange)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func albumColorName(_ category: AlbumCategory) -> String {
        switch category {
        case .travel:  "blue"
        case .family:  "pink"
        case .work:    "gray"
        case .nature:  "green"
        case .food:    "orange"
        case .pet:     "brown"
        case .event:   "purple"
        }
    }
}

#Preview {
    AlbumListView(viewModel: SmartSnapViewModel())
}
