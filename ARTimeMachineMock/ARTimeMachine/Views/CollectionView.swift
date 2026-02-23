import SwiftUI

// MARK: - CollectionView

struct CollectionView: View {
    var viewModel: ARTimeMachineViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsHeader
                    photosSection
                    visitedErasSection
                    favoriteSpotsSection
                }
                .padding()
            }
            .navigationTitle("コレクション")
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatBadge(
                value: "\(viewModel.capturedPhotoCount)",
                label: "AR写真",
                systemImage: "camera.fill",
                color: .indigo
            )
            StatBadge(
                value: "\(viewModel.favoriteCount)",
                label: "お気に入り",
                systemImage: "heart.fill",
                color: .red
            )
            StatBadge(
                value: "\(totalEras)",
                label: "訪問時代",
                systemImage: "clock.fill",
                color: .orange
            )
        }
    }

    private var totalEras: Int {
        Set(viewModel.spots.flatMap { $0.timePeriods.map(\.era) }).count
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AR写真")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.capturedPhotoCount)枚")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.capturedPhotoCount == 0 {
                emptyPhotoPlaceholder
            } else {
                photoGrid
            }
        }
    }

    private var emptyPhotoPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("まだAR写真がありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("タイムトラベル中に写真を撮影しましょう")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 8) {
            ForEach(0..<min(viewModel.capturedPhotoCount, 9), id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fit)

                    VStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.secondary)
                        Text("AR写真 \(index + 1)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    // MARK: - Visited Eras Section

    private var visitedErasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タイムライン")
                .font(.headline)

            ForEach(HistoricalEra.allCases, id: \.self) { era in
                let spotCount = viewModel.spots.filter { spot in
                    spot.timePeriods.contains { $0.era == era }
                }.count

                if spotCount > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: era.systemImage)
                            .foregroundStyle(era.color)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text(era.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        Text("\(spotCount)スポット")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(era.color.opacity(0.15))
                            .foregroundStyle(era.color)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Favorite Spots Section

    private var favoriteSpotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("お気に入りスポット")
                .font(.headline)

            let favorites = viewModel.spots.filter(\.isFavorite)
            if favorites.isEmpty {
                Text("お気に入りのスポットはまだありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(favorites) { spot in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(spot.category.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: spot.category.systemImage)
                                .foregroundStyle(spot.category.color)
                        }

                        VStack(alignment: .leading) {
                            Text(spot.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(spot.timePeriods.count)つの時代")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - StatBadge

struct StatBadge: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - PhotoCaptureSheet

struct PhotoCaptureSheet: View {
    var viewModel: ARTimeMachineViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("AR写真を保存しました")
                    .font(.title2)
                    .fontWeight(.bold)

                if let spot = viewModel.selectedSpot,
                   let period = viewModel.currentTimePeriod {
                    VStack(spacing: 8) {
                        Text(spot.name)
                            .font(.headline)
                        Text("\(period.yearText) — \(period.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text("撮影枚数: \(viewModel.capturedPhotoCount)枚")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.dismissPhotoCapture()
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionView(viewModel: ARTimeMachineViewModel())
}
