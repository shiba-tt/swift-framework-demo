import SwiftUI

struct NoteListView: View {
    @Bindable var viewModel: HandwritingAIViewModel

    var body: some View {
        NavigationStack {
            List {
                statsSection
                filterSection
                notesSection
            }
            .navigationTitle("手書きノート AI")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingCapture = true
                    } label: {
                        Image(systemName: "camera")
                    }
                }
            }
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsSection: some View {
        Section {
            HStack(spacing: 16) {
                statCard(title: "ノート数", value: "\(viewModel.totalNotes)", icon: "doc.text", color: .teal)
                statCard(title: "処理済み", value: "\(viewModel.processedNotes)", icon: "checkmark.circle", color: .green)
                statCard(title: "タイプ数", value: "\(viewModel.noteTypeStats.count)", icon: "tag", color: .orange)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1), in: .rect(cornerRadius: 10))
    }

    // MARK: - Filter

    @ViewBuilder
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "すべて", isSelected: viewModel.selectedNoteTypeFilter == nil) {
                    viewModel.selectedNoteTypeFilter = nil
                }
                ForEach(NoteType.allCases, id: \.self) { type in
                    filterChip(
                        title: type.rawValue,
                        icon: type.systemImage,
                        isSelected: viewModel.selectedNoteTypeFilter == type
                    ) {
                        viewModel.selectedNoteTypeFilter = type
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
            .background(isSelected ? .teal : Color(.systemGray5), in: .capsule)
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }

    // MARK: - Notes

    @ViewBuilder
    private var notesSection: some View {
        Section("\(viewModel.filteredNotes.count)件のノート") {
            if viewModel.filteredNotes.isEmpty {
                ContentUnavailableView(
                    "ノートがありません",
                    systemImage: "doc.text",
                    description: Text("撮影タブからノートをスキャンしましょう")
                )
            } else {
                ForEach(viewModel.filteredNotes) { note in
                    noteRow(note)
                        .onTapGesture {
                            viewModel.selectNote(note)
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteNote(viewModel.filteredNotes[index])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func noteRow(_ note: Note) -> some View {
        HStack(spacing: 12) {
            // アイコン
            RoundedRectangle(cornerRadius: 8)
                .fill(note.noteType.color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: note.noteType.systemImage)
                        .foregroundStyle(note.noteType.color)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: note.layoutType.systemImage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(note.recognizedText.prefix(60).replacingOccurrences(of: "\n", with: " "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(note.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if !note.tags.isEmpty {
                        ForEach(note.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(.teal.opacity(0.1), in: .capsule)
                                .foregroundStyle(.teal)
                        }
                    }

                    if let summary = note.summary, summary.pendingActionCount > 0 {
                        Spacer()
                        Label("\(summary.pendingActionCount)", systemImage: "checklist.unchecked")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NoteListView(viewModel: HandwritingAIViewModel())
}
