import SwiftUI

struct ArtworkListView: View {
    @Bindable var viewModel: ARMuseumViewModel
    @State private var selectedCategory: ArtworkCategory?
    @State private var searchText = ""

    var filteredArtworks: [Artwork] {
        var result = viewModel.artworks
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            List {
                categoryFilter
                artworksList
            }
            .navigationTitle("作品コレクション")
            .searchable(text: $searchText, prompt: "作品名・作者で検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddArtwork = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    // MARK: - Category Filter

    @ViewBuilder
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "すべて", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ArtworkCategory.allCases, id: \.self) { category in
                    filterChip(
                        title: category.rawValue,
                        icon: category.systemImage,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func filterChip(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .indigo : Color(.systemGray5), in: .capsule)
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }

    // MARK: - Artworks

    @ViewBuilder
    private var artworksList: some View {
        Section("\(filteredArtworks.count)件の作品") {
            if filteredArtworks.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(filteredArtworks) { artwork in
                    artworkCard(artwork)
                        .onTapGesture {
                            viewModel.selectArtwork(artwork)
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteArtwork(filteredArtworks[index])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func artworkCard(_ artwork: Artwork) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(artwork.thumbnailColor.gradient)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: artwork.category.systemImage)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                HStack {
                    Text(artwork.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(artwork.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(artwork.category.color.opacity(0.15), in: .capsule)
                        .foregroundStyle(artwork.category.color)
                }
                HStack {
                    Image(systemName: artwork.displayType.systemImage)
                        .font(.caption2)
                    Text(artwork.displayType.rawValue)
                        .font(.caption2)
                    Text("/ \(artwork.formattedDate)")
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ArtworkListView(viewModel: ARMuseumViewModel())
}
