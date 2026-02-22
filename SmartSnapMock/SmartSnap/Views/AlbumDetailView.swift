import SwiftUI

struct AlbumDetailView: View {
    @Bindable var viewModel: SmartSnapViewModel
    let album: Album
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    albumHeader
                    storySection
                    photosGrid
                }
                .padding()
            }
            .navigationTitle(album.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Album Header

    private var albumHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text(album.category.emoji)
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(album.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    HStack(spacing: 8) {
                        Label("\(album.photoCount)枚", systemImage: "photo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !album.dateRange.isEmpty {
                            Label(album.dateRange, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Story Section

    private var storySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI ストーリー", systemImage: "text.book.closed")
                    .font(.headline)
                Spacer()
            }

            if let story = album.story {
                Text(story)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    Task {
                        await viewModel.generateAlbumStory(for: album)
                    }
                } label: {
                    if viewModel.isAnalyzing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text(viewModel.analysisProgress ?? "ストーリーを生成中...")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    } else {
                        Label("ストーリーを生成", systemImage: "wand.and.stars")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(viewModel.isAnalyzing)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Photos Grid

    private var photosGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("写真")
                .font(.headline)

            let albumPhotos = viewModel.photosForAlbum(album)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(albumPhotos) { photo in
                    photoThumbnail(photo)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func photoThumbnail(_ photo: Photo) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.15))
                    .aspectRatio(1, contentMode: .fit)

                VStack(spacing: 4) {
                    Image(systemName: photo.systemImageName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(photo.shortDate)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            if !photo.tags.isEmpty {
                Text(photo.tags.prefix(2).joined(separator: " "))
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    AlbumDetailView(
        viewModel: SmartSnapViewModel(),
        album: Album(
            title: "テストアルバム",
            subtitle: "3枚の写真",
            photoIDs: [],
            category: .travel,
            dateRange: "7/15 - 7/16"
        )
    )
}
