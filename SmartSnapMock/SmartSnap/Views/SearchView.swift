import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SmartSnapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    searchBar
                    if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty && !viewModel.isAnalyzing {
                        noResultsState
                    } else if !viewModel.searchResults.isEmpty {
                        resultsSection
                    } else {
                        searchSuggestions
                    }
                }
                .padding()
            }
            .navigationTitle("検索")
            .sheet(item: $viewModel.selectedPhoto) { photo in
                PhotoDetailView(viewModel: viewModel, photo: photo)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("写真を自然言語で検索...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task { await viewModel.search() }
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

            // 検索ボタン
            Button {
                Task { await viewModel.search() }
            } label: {
                if viewModel.isAnalyzing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text(viewModel.analysisProgress ?? "検索中...")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                } else {
                    Label("検索", systemImage: "magnifyingglass")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(viewModel.searchQuery.isEmpty || viewModel.isAnalyzing)

            Text("Foundation Models による自然言語理解でタグ・キャプション・場所・OCRテキストを横断検索")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - No Results

    private var noResultsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("該当する写真が見つかりません")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("別のキーワードで検索してみてください")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 40)
    }

    // MARK: - Results Section

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("検索結果")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.searchResults.count) 件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.searchResults) { result in
                searchResultCard(result)
                    .onTapGesture {
                        viewModel.selectPhoto(result.photo)
                    }
            }
        }
    }

    private func searchResultCard(_ result: SearchResult) -> some View {
        HStack(spacing: 12) {
            // サムネイル
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.12))
                    .frame(width: 60, height: 60)

                Image(systemName: result.photo.systemImageName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let caption = result.photo.caption {
                    Text(caption)
                        .font(.subheadline)
                        .lineLimit(2)
                }

                Text(result.matchReason)
                    .font(.caption)
                    .foregroundStyle(.orange)

                Text(result.photo.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // 関連度
            VStack(spacing: 2) {
                Text(String(format: "%.0f%%", result.relevanceScore * 100))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("一致度")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Search Suggestions

    private var searchSuggestions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("検索の例")
                .font(.headline)

            let suggestions = [
                ("沖縄", "場所で検索"),
                ("誕生日", "イベントで検索"),
                ("犬", "オブジェクトで検索"),
                ("ラーメン", "食べ物で検索"),
                ("紅葉", "季節で検索"),
                ("カンファレンス", "仕事の写真を検索"),
            ]

            ForEach(suggestions, id: \.0) { query, description in
                Button {
                    viewModel.searchQuery = query
                    Task { await viewModel.search() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(.orange)

                        Text(query)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SearchView(viewModel: SmartSnapViewModel())
}
