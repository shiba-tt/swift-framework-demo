import SwiftUI

struct NoteDetailView: View {
    @Bindable var viewModel: HandwritingAIViewModel
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var showingMarkdown = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    if let summary = note.summary {
                        summarySection(summary)
                        actionItemsSection(summary)
                        relatedTopicsSection(summary)
                    }
                    originalTextSection
                    metadataSection
                }
                .padding()
            }
            .navigationTitle(note.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingMarkdown = true
                        } label: {
                            Label("Markdownエクスポート", systemImage: "doc.text")
                        }
                        Button {} label: {
                            Label("PDFエクスポート", systemImage: "doc.richtext")
                        }
                        Button {} label: {
                            Label("共有", systemImage: "square.and.arrow.up")
                        }
                        Divider()
                        Button(role: .destructive) {
                            viewModel.deleteNote(note)
                            dismiss()
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingMarkdown) {
                markdownExportView
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(note.noteType.color.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: note.noteType.systemImage)
                        .font(.title2)
                        .foregroundStyle(note.noteType.color)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.title3)
                    .fontWeight(.bold)
                HStack(spacing: 8) {
                    Label(note.noteType.rawValue, systemImage: note.noteType.systemImage)
                    Label(note.layoutType.rawValue, systemImage: note.layoutType.systemImage)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                Text(note.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if let summary = note.summary {
                VStack {
                    Text(String(format: "%.0f%%", summary.confidence * 100))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.teal)
                    Text("精度")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Summary

    @ViewBuilder
    private func summarySection(_ summary: NoteSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI 要約", systemImage: "brain")
                .font(.headline)
                .foregroundStyle(.teal)

            Text(summary.summaryText)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.teal.opacity(0.05), in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Action Items

    @ViewBuilder
    private func actionItemsSection(_ summary: NoteSummary) -> some View {
        if !summary.actionItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("アクションアイテム", systemImage: "checklist")
                        .font(.headline)
                    Spacer()
                    Text("\(summary.completedActionCount)/\(summary.actionItems.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(summary.actionItems) { item in
                    Button {
                        viewModel.toggleActionItem(noteID: note.id, actionItemID: item.id)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isCompleted ? .green : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.text)
                                    .font(.subheadline)
                                    .strikethrough(item.isCompleted)
                                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                                HStack {
                                    if let assignee = item.assignee {
                                        Label(assignee, systemImage: "person")
                                    }
                                    if let due = item.formattedDueDate {
                                        Label(due, systemImage: "calendar")
                                    }
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .tint(.primary)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Related Topics

    @ViewBuilder
    private func relatedTopicsSection(_ summary: NoteSummary) -> some View {
        if !summary.relatedTopics.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("関連トピック", systemImage: "link")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(summary.relatedTopics, id: \.self) { topic in
                        Text(topic)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.teal.opacity(0.1), in: .capsule)
                            .foregroundStyle(.teal)
                    }
                }
            }
        }
    }

    // MARK: - Original Text

    @ViewBuilder
    private var originalTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("認識テキスト", systemImage: "text.alignleft")
                    .font(.headline)
                Spacer()
                Text("\(note.wordCount)文字")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(note.recognizedText)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6), in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Metadata

    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("メタデータ", systemImage: "info.circle")
                .font(.headline)

            if !note.tags.isEmpty {
                HStack {
                    Text("タグ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    ForEach(note.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.1), in: .capsule)
                    }
                }
            }

            HStack {
                Text("レイアウト")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(note.layoutType.rawValue, systemImage: note.layoutType.systemImage)
                    .font(.caption)
            }

            HStack {
                Text("ノートタイプ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(note.noteType.rawValue, systemImage: note.noteType.systemImage)
                    .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    // MARK: - Markdown Export

    @ViewBuilder
    private var markdownExportView: some View {
        NavigationStack {
            ScrollView {
                Text(viewModel.exportMarkdown(for: note))
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Markdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { showingMarkdown = false }
                }
            }
        }
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowMaxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowMaxHeight + spacing
                rowMaxHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowMaxHeight = max(rowMaxHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowMaxHeight)
        }

        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}

#Preview {
    NoteDetailView(
        viewModel: HandwritingAIViewModel(),
        note: Note.samples[0]
    )
}
