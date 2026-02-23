import SwiftUI

struct ExhibitionDetailView: View {
    @Bindable var viewModel: ARMuseumViewModel
    let exhibition: Exhibition
    @State private var showingArtworkPicker = false

    var body: some View {
        List {
            headerSection
            artworksSection
            settingsSection
            actionsSection
        }
        .navigationTitle(exhibition.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingArtworkPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingArtworkPicker) {
            artworkPickerSheet
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: exhibition.theme.systemImage)
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)
                    VStack(alignment: .leading) {
                        Text(exhibition.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(exhibition.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !exhibition.description.isEmpty {
                    Text(exhibition.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("\(exhibition.artworkCount)作品", systemImage: "photo.artframe")
                    Spacer()
                    Label(exhibition.theme.rawValue, systemImage: exhibition.theme.systemImage)
                    Spacer()
                    Label(
                        exhibition.isPublished ? "公開中" : "非公開",
                        systemImage: exhibition.isPublished ? "globe" : "lock"
                    )
                    .foregroundStyle(exhibition.isPublished ? .green : .secondary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Artworks

    @ViewBuilder
    private var artworksSection: some View {
        Section("展示作品") {
            let exhibitionArtworks = viewModel.artworks(for: exhibition)
            if exhibitionArtworks.isEmpty {
                ContentUnavailableView(
                    "作品を追加しましょう",
                    systemImage: "photo.artframe",
                    description: Text("右上の＋ボタンで作品を展覧会に追加できます")
                )
            } else {
                ForEach(exhibitionArtworks) { artwork in
                    artworkRow(artwork)
                        .onTapGesture {
                            viewModel.selectArtwork(artwork)
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let artwork = exhibitionArtworks[index]
                        viewModel.removeArtworkFromExhibition(artwork.id)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func artworkRow(_ artwork: Artwork) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(artwork.thumbnailColor.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: artwork.category.systemImage)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(artwork.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(artwork.artist)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: artwork.displayType.systemImage)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Settings

    @ViewBuilder
    private var settingsSection: some View {
        Section("招待された友人") {
            if exhibition.invitedFriends.isEmpty {
                Label("招待された友人はいません", systemImage: "person.2")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(exhibition.invitedFriends) { friend in
                    HStack {
                        Circle()
                            .fill(friend.avatarColor)
                            .frame(width: 30, height: 30)
                            .overlay {
                                Text(String(friend.name.prefix(1)))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        Text(friend.name)
                        Spacer()
                        Circle()
                            .fill(friend.isOnline ? .green : .gray)
                            .frame(width: 8, height: 8)
                        Text(friend.isOnline ? "オンライン" : "オフライン")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionsSection: some View {
        Section {
            Button {
                viewModel.enterAR(for: exhibition)
            } label: {
                Label("AR展示を開始", systemImage: "arkit")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .tint(.indigo)

            Button {
                viewModel.togglePublish()
            } label: {
                Label(
                    exhibition.isPublished ? "非公開にする" : "公開する",
                    systemImage: exhibition.isPublished ? "lock" : "globe"
                )
                .frame(maxWidth: .infinity)
            }

            Button {
                viewModel.showingInvite = true
            } label: {
                Label("友人を招待", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Artwork Picker

    @ViewBuilder
    private var artworkPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.artworks) { artwork in
                    let isAdded = exhibition.artworkIDs.contains(artwork.id)
                    Button {
                        if isAdded {
                            viewModel.removeArtworkFromExhibition(artwork.id)
                        } else {
                            viewModel.addArtworkToExhibition(artwork.id)
                        }
                    } label: {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(artwork.thumbnailColor.gradient)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: artwork.category.systemImage)
                                        .foregroundStyle(.white)
                                        .font(.caption)
                                }
                            VStack(alignment: .leading) {
                                Text(artwork.title)
                                    .font(.subheadline)
                                Text(artwork.artist)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if isAdded {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("作品を追加")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { showingArtworkPicker = false }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExhibitionDetailView(
            viewModel: ARMuseumViewModel(),
            exhibition: Exhibition.samples[0]
        )
    }
}
