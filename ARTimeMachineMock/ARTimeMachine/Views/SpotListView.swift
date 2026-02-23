import SwiftUI

// MARK: - SpotListView

struct SpotListView: View {
    var viewModel: ARTimeMachineViewModel

    var body: some View {
        NavigationStack {
            List {
                filterSection
                spotsSection
            }
            .navigationTitle("歴史スポット")
            .searchable(text: $viewModel.searchText, prompt: "スポットを検索")
            .refreshable {
                await viewModel.refreshSpots()
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        label: "すべて",
                        systemImage: "square.grid.2x2",
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(SpotCategory.allCases, id: \.self) { category in
                        FilterChip(
                            label: category.rawValue,
                            systemImage: category.systemImage,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Toggle("お気に入りのみ", isOn: $viewModel.showFavoritesOnly)
        }
    }

    // MARK: - Spots Section

    private var spotsSection: some View {
        Section("周辺スポット (\(viewModel.filteredSpots.count)件)") {
            if viewModel.filteredSpots.isEmpty {
                ContentUnavailableView(
                    "スポットが見つかりません",
                    systemImage: "magnifyingglass",
                    description: Text("フィルターや検索条件を変更してください")
                )
            } else {
                ForEach(viewModel.filteredSpots) { spot in
                    SpotRow(spot: spot) {
                        viewModel.selectSpot(spot)
                    } onFavoriteToggle: {
                        viewModel.toggleFavorite(spot)
                    }
                }
            }
        }
    }
}

// MARK: - SpotRow

struct SpotRow: View {
    let spot: HistoricalSpot
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(spot.category.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: spot.category.systemImage)
                        .font(.title2)
                        .foregroundStyle(spot.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 8) {
                        Label(spot.category.rawValue, systemImage: spot.category.systemImage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(spot.distanceText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        ForEach(spot.timePeriods.prefix(4)) { period in
                            Text(period.yearText)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(period.era.color.opacity(0.15))
                                .foregroundStyle(period.era.color)
                                .clipShape(Capsule())
                        }
                        if spot.timePeriods.count > 4 {
                            Text("+\(spot.timePeriods.count - 4)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button(action: onFavoriteToggle) {
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(spot.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.indigo : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SpotDetailSheet

struct SpotDetailSheet: View {
    var viewModel: ARTimeMachineViewModel
    let spot: HistoricalSpot

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    descriptionSection
                    timelineSection
                    startARSection
                }
                .padding()
            }
            .navigationTitle(spot.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showingSpotDetail = false
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Label(spot.category.rawValue, systemImage: spot.category.systemImage)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(spot.category.color.opacity(0.15))
                .foregroundStyle(spot.category.color)
                .clipShape(Capsule())

            Spacer()

            Label(spot.distanceText, systemImage: "location.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("概要")
                .font(.headline)
            Text(spot.currentDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タイムライン")
                .font(.headline)

            ForEach(spot.timePeriods) { period in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(period.era.color)
                            .frame(width: 12, height: 12)
                        Rectangle()
                            .fill(period.era.color.opacity(0.3))
                            .frame(width: 2)
                    }
                    .frame(width: 12)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(period.yearText)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Label(period.era.rawValue, systemImage: period.era.systemImage)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(period.era.color.opacity(0.15))
                                .foregroundStyle(period.era.color)
                                .clipShape(Capsule())
                        }
                        Text(period.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(period.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label("\(period.photoCount)枚の資料写真", systemImage: "photo.stack")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }

    private var startARSection: some View {
        Button {
            viewModel.showingSpotDetail = false
            Task {
                await viewModel.startAR()
            }
        } label: {
            Label("タイムトラベルを開始", systemImage: "arkit")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.indigo)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    SpotListView(viewModel: ARTimeMachineViewModel())
}
