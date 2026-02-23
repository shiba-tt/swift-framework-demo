import SwiftUI

struct GalleryView: View {
    @Bindable var viewModel: ARMuseumViewModel
    @State private var showingNewExhibition = false
    @State private var newName = ""
    @State private var newDescription = ""
    @State private var newTheme: ExhibitionTheme = .gallery

    var body: some View {
        NavigationStack {
            List {
                statsSection
                exhibitionsSection
            }
            .navigationTitle("AR ミュージアム")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewExhibition = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("新しい展覧会", isPresented: $showingNewExhibition) {
                TextField("展覧会名", text: $newName)
                TextField("説明", text: $newDescription)
                Button("作成") {
                    guard !newName.isEmpty else { return }
                    viewModel.createExhibition(
                        name: newName,
                        description: newDescription,
                        theme: newTheme
                    )
                    newName = ""
                    newDescription = ""
                }
                Button("キャンセル", role: .cancel) {
                    newName = ""
                    newDescription = ""
                }
            }
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsSection: some View {
        Section {
            HStack(spacing: 20) {
                statCard(title: "作品数", value: "\(viewModel.totalArtworks)", icon: "photo.artframe", color: .indigo)
                statCard(title: "展覧会", value: "\(viewModel.totalExhibitions)", icon: "building.columns", color: .orange)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: .rect(cornerRadius: 12))
    }

    // MARK: - Exhibitions

    @ViewBuilder
    private var exhibitionsSection: some View {
        Section("展覧会一覧") {
            if viewModel.exhibitions.isEmpty {
                ContentUnavailableView(
                    "展覧会がありません",
                    systemImage: "building.columns",
                    description: Text("右上の＋ボタンで展覧会を作成しましょう")
                )
            } else {
                ForEach(viewModel.exhibitions) { exhibition in
                    NavigationLink {
                        ExhibitionDetailView(viewModel: viewModel, exhibition: exhibition)
                    } label: {
                        exhibitionRow(exhibition)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteExhibition(viewModel.exhibitions[index])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func exhibitionRow(_ exhibition: Exhibition) -> some View {
        HStack(spacing: 12) {
            Image(systemName: exhibition.theme.systemImage)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 44, height: 44)
                .background(.indigo.opacity(0.1), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exhibition.name)
                        .font(.headline)
                    if exhibition.isPublished {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                Text("\(exhibition.artworkCount)作品 / \(exhibition.theme.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !exhibition.invitedFriends.isEmpty {
                HStack(spacing: -6) {
                    ForEach(exhibition.invitedFriends.prefix(3)) { friend in
                        Circle()
                            .fill(friend.avatarColor)
                            .frame(width: 24, height: 24)
                            .overlay {
                                Text(String(friend.name.prefix(1)))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GalleryView(viewModel: ARMuseumViewModel())
}
