import SwiftUI

/// 名刺詳細画面
struct ContactDetailView: View {
    let viewModel: ContextCardsViewModel
    let contactId: UUID
    @State private var meetingContext: String = ""
    @State private var isRegenerating = false
    @Environment(\.dismiss) private var dismiss

    private var card: ContactCard? {
        viewModel.contacts.first(where: { $0.id == contactId })
    }

    var body: some View {
        NavigationStack {
            if let card {
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        ContactHeader(card: card)

                        // 連絡先情報
                        ContactInfoSection(card: card)

                        // 会話のきっかけ
                        ConversationStartersSection(starters: card.analysis.conversationStarters)

                        // フォローアップメール
                        FollowUpSection(
                            card: card,
                            meetingContext: $meetingContext,
                            isRegenerating: isRegenerating,
                            onRegenerate: {
                                isRegenerating = true
                                await viewModel.regenerateFollowUp(
                                    for: contactId,
                                    context: meetingContext
                                )
                                isRegenerating = false
                            }
                        )
                    }
                    .padding()
                }
                .navigationTitle("名刺詳細")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.toggleFavorite(for: contactId)
                        } label: {
                            Image(systemName: card.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(card.isFavorite ? .yellow : .secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Contact Header

private struct ContactHeader: View {
    let card: ContactCard

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.indigo.gradient)
                    .frame(width: 80, height: 80)
                Text(String(card.displayName.prefix(1)))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(card.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(card.analysis.company)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(card.analysis.title)
                    .font(.caption)
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.indigo.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Contact Info Section

private struct ContactInfoSection: View {
    let card: ContactCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "連絡先", icon: "phone.fill")

            VStack(spacing: 8) {
                if !card.phoneNumber.isEmpty {
                    InfoRow(icon: "phone.fill", label: "電話", value: card.phoneNumber, color: .green)
                }
                if !card.email.isEmpty {
                    InfoRow(icon: "envelope.fill", label: "メール", value: card.email, color: .blue)
                }
                InfoRow(
                    icon: "clock.fill",
                    label: "スキャン日時",
                    value: card.scannedAt.formatted(date: .abbreviated, time: .shortened),
                    color: .secondary
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Text(value)
                    .font(.subheadline)
            }
            Spacer()
        }
    }
}

// MARK: - Conversation Starters Section

private struct ConversationStartersSection: View {
    let starters: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "会話のきっかけ", icon: "bubble.left.and.bubble.right.fill")

            VStack(spacing: 8) {
                ForEach(Array(starters.enumerated()), id: \.offset) { index, starter in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(.indigo.gradient)
                            .clipShape(Circle())

                        Text(starter)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 4)

                    if index < starters.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
            .background(.indigo.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Follow Up Section

private struct FollowUpSection: View {
    let card: ContactCard
    @Binding var meetingContext: String
    let isRegenerating: Bool
    let onRegenerate: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "フォローアップメール", icon: "envelope.open.fill")

            // メール本文
            VStack(alignment: .leading, spacing: 8) {
                Text(card.analysis.followUpDraft)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // コピーボタン
                Button {
                    UIPasteboard.general.string = card.analysis.followUpDraft
                } label: {
                    Label("コピー", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.indigo)
            }

            // 出会いのコンテキスト入力
            VStack(alignment: .leading, spacing: 8) {
                Text("出会いの場面を入力して再生成")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("例: WWDC25 ランチミーティング", text: $meetingContext)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)

                Button {
                    Task { await onRegenerate() }
                } label: {
                    Label(
                        isRegenerating ? "再生成中..." : "メールを再生成",
                        systemImage: "sparkles"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(meetingContext.isEmpty || isRegenerating)
            }
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
    }
}
