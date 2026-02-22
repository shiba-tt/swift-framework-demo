import SwiftUI

struct PhotoListView: View {
    @Bindable var viewModel: SmartSnapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.photos.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.photosByMonth, id: \.month) { group in
                            monthSection(month: group.month, photos: group.photos)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("写真")
            .sheet(item: $viewModel.selectedPhoto) { photo in
                PhotoDetailView(viewModel: viewModel, photo: photo)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("写真がありません")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("写真ライブラリから読み込むと\nAIが自動的に分析・分類します")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - Month Section

    private func monthSection(month: String, photos: [Photo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(month)
                    .font(.headline)
                Spacer()
                Text("\(photos.count)枚")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(photos) { photo in
                    photoCard(photo)
                        .onTapGesture {
                            viewModel.selectPhoto(photo)
                        }
                }
            }
        }
    }

    private func photoCard(_ photo: Photo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // サムネイル（モック）
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.12))
                    .frame(height: 100)

                VStack(spacing: 6) {
                    Image(systemName: photo.systemImageName)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    if let location = photo.location {
                        Label(location.name, systemImage: "mappin")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            // キャプション
            if let caption = photo.caption {
                Text(caption)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            }

            // タグ
            HStack(spacing: 4) {
                ForEach(photo.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.1), in: Capsule())
                }
            }

            Text(photo.formattedDate)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PhotoListView(viewModel: SmartSnapViewModel())
}
