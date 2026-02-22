import SwiftUI

// MARK: - MemoDetailView

struct MemoDetailView: View {
    @Bindable var viewModel: VoiceMemoAIViewModel
    let memo: VoiceMemo

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ヘッダー
                headerSection

                // キーポイント
                if !memo.keyPoints.isEmpty {
                    keyPointsSection
                }

                // アクションアイテム
                if !memo.actionItems.isEmpty {
                    actionItemsSection
                }

                // 要約
                if let summary = memo.summary {
                    summarySection(summary)
                }

                // 元の文字起こし
                transcriptionSection
            }
            .padding()
        }
        .navigationTitle(memo.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            // カテゴリバッジ
            if let category = memo.category {
                HStack(spacing: 6) {
                    Text(category.emoji)
                    Text(category.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(category.color.opacity(0.12))
                .foregroundStyle(category.color)
                .clipShape(Capsule())
            }

            Spacer()

            // メタ情報
            VStack(alignment: .trailing, spacing: 2) {
                Text(memo.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(memo.formattedDuration, systemImage: "waveform")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Key Points

    private var keyPointsSection: some View {
        SectionCard(title: "キーポイント", icon: "star.fill", color: .yellow) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(memo.keyPoints.enumerated()), id: \.offset) { index, point in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(.indigo)
                            .clipShape(Circle())

                        Text(point)
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    // MARK: - Action Items

    private var actionItemsSection: some View {
        SectionCard(title: "アクションアイテム", icon: "checklist", color: .orange) {
            VStack(spacing: 10) {
                ForEach(memo.actionItems) { item in
                    HStack(spacing: 10) {
                        Button {
                            viewModel.toggleActionItem(item, in: memo)
                        } label: {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(item.isCompleted ? .green : .secondary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.content)
                                .font(.subheadline)
                                .strikethrough(item.isCompleted)
                                .foregroundStyle(item.isCompleted ? .secondary : .primary)

                            HStack(spacing: 8) {
                                Text(item.priorityEmoji)
                                    .font(.caption2)

                                if let assignee = item.assignee {
                                    Label(assignee, systemImage: "person.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Summary

    private func summarySection(_ summary: String) -> some View {
        SectionCard(title: "AI 要約", icon: "sparkles", color: .indigo) {
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Transcription

    private var transcriptionSection: some View {
        SectionCard(title: "元の文字起こし", icon: "waveform", color: .gray) {
            Text(memo.rawTranscription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - SectionCard

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
