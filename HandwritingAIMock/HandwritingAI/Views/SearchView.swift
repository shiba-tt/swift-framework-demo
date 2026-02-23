import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: HandwritingAIViewModel
    @State private var searchText = ""

    private var searchResults: [Note] {
        guard !searchText.isEmpty else { return [] }
        return viewModel.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
            || $0.recognizedText.localizedCaseInsensitiveContains(searchText)
            || $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            || ($0.summary?.summaryText.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    recentTagsSection
                    noteTypeSummarySection
                } else {
                    searchResultsSection
                }
            }
            .navigationTitle("検索")
            .searchable(text: $searchText, prompt: "ノート内容・タグで検索 (Spotlight)")
        }
    }

    // MARK: - Recent Tags

    @ViewBuilder
    private var recentTagsSection: some View {
        Section("よく使われるタグ") {
            let allTags = Array(Set(viewModel.notes.flatMap(\.tags))).sorted()
            if allTags.isEmpty {
                Text("タグがありません")
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(allTags, id: \.self) { tag in
                        Button {
                            searchText = tag
                        } label: {
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.teal.opacity(0.1), in: .capsule)
                                .foregroundStyle(.teal)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
    }

    // MARK: - Note Type Summary

    @ViewBuilder
    private var noteTypeSummarySection: some View {
        Section("ノートタイプ別") {
            ForEach(viewModel.noteTypeStats, id: \.0) { type, count in
                Button {
                    viewModel.selectedNoteTypeFilter = type
                } label: {
                    HStack {
                        Image(systemName: type.systemImage)
                            .foregroundStyle(type.color)
                            .frame(width: 24)
                        Text(type.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(count)件")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsSection: some View {
        Section("\(searchResults.count)件の結果") {
            if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(searchResults) { note in
                    Button {
                        viewModel.selectNote(note)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: note.noteType.systemImage)
                                .foregroundStyle(note.noteType.color)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(highlightedText(note.recognizedText, searchText: searchText))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)

                                Text(note.formattedDate)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func highlightedText(_ text: String, searchText: String) -> String {
        let preview = text.replacingOccurrences(of: "\n", with: " ")
        guard let range = preview.range(of: searchText, options: .caseInsensitive) else {
            return String(preview.prefix(80))
        }
        let start = max(preview.startIndex, preview.index(range.lowerBound, offsetBy: -20, limitedBy: preview.startIndex) ?? preview.startIndex)
        let end = min(preview.endIndex, preview.index(range.upperBound, offsetBy: 30, limitedBy: preview.endIndex) ?? preview.endIndex)
        var result = String(preview[start..<end])
        if start != preview.startIndex { result = "..." + result }
        if end != preview.endIndex { result = result + "..." }
        return result
    }
}

#Preview {
    SearchView(viewModel: HandwritingAIViewModel())
}
