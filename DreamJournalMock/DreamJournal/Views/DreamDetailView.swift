import SwiftUI

// MARK: - DreamDetailView（夢の詳細）

struct DreamDetailView: View {
    let dream: DreamEntry
    @Bindable var viewModel: DreamJournalViewModel
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダーカード
                headerCard

                // AI 分析結果
                if dream.isAnalyzed {
                    analysisSection
                    symbolsSection
                    themesSection
                } else {
                    unanalyzedSection
                }

                // 原文
                rawTranscriptionSection

                // メタ情報
                metadataSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(dream.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if viewModel.isModelAvailable {
                        Button {
                            Task { await viewModel.reanalyzeDream(dream) }
                        } label: {
                            Label("再分析", systemImage: "sparkles")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("この夢を削除しますか？", isPresented: $showingDeleteConfirmation) {
            Button("削除", role: .destructive) {
                viewModel.deleteDream(dream)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            // 感情アイコン
            Text(dream.emotionalToneEmoji)
                .font(.system(size: 56))

            // タイトル
            Text(dream.displayTitle)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // 日時
            Text(dream.formattedDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // 感情トーン
            if let tone = dream.emotionalTone {
                Text(tone.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color(tone.colorName).opacity(0.2))
                    .foregroundStyle(Color(tone.colorName))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Analysis Section

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI 分析", icon: "sparkles", color: .purple)

            if let narrative = dream.narrative {
                Text(narrative)
                    .font(.body)
                    .lineSpacing(4)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Symbols Section

    private var symbolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "シンボル", icon: "moon.stars", color: .indigo)

            VStack(spacing: 8) {
                ForEach(dream.symbols) { symbol in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "diamond.fill")
                            .font(.caption)
                            .foregroundStyle(.indigo)
                            .padding(.top, 3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(symbol.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(symbol.interpretation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Themes Section

    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "テーマ", icon: "tag.fill", color: .purple)

            FlowLayout(spacing: 8) {
                ForEach(dream.themes, id: \.self) { theme in
                    Text(theme)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.purple.opacity(0.1))
                        .foregroundStyle(.purple)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Unanalyzed Section

    private var unanalyzedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.purple.opacity(0.5))

            Text("AI 分析がまだ完了していません")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if viewModel.isModelAvailable {
                Button {
                    Task { await viewModel.analyzeDream(dream) }
                } label: {
                    Label("今すぐ分析", systemImage: "sparkles")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.purple)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Raw Transcription

    private var rawTranscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "原文（音声文字起こし）", icon: "mic.fill", color: .blue)

            Text(dream.rawTranscription)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "記録情報", icon: "info.circle", color: .gray)

            HStack(spacing: 24) {
                MetadataItem(title: "明晰度", value: "\(dream.lucidity)/5", icon: "eye")
                MetadataItem(title: "鮮明度", value: "\(dream.vividness)/5", icon: "paintbrush")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }
}

struct MetadataItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
