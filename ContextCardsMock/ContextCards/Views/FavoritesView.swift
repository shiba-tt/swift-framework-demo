import SwiftUI

/// お気に入り名刺一覧画面
struct FavoritesView: View {
    let viewModel: ContextCardsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteContacts.isEmpty {
                    ContentUnavailableView(
                        "お気に入りがありません",
                        systemImage: "star",
                        description: Text("名刺詳細画面で星マークをタップするとお気に入りに追加されます")
                    )
                } else {
                    List {
                        ForEach(viewModel.favoriteContacts) { card in
                            Button {
                                viewModel.selectedContact = card
                                viewModel.showDetailSheet = true
                            } label: {
                                FavoriteRow(card: card)
                            }
                        }
                    }
                }
            }
            .navigationTitle("お気に入り")
            .sheet(isPresented: Binding(
                get: { viewModel.showDetailSheet },
                set: { viewModel.showDetailSheet = $0 }
            )) {
                if let contact = viewModel.selectedContact {
                    ContactDetailView(
                        viewModel: viewModel,
                        contactId: contact.id
                    )
                }
            }
        }
    }
}

// MARK: - Favorite Row

private struct FavoriteRow: View {
    let card: ContactCard

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.indigo.gradient)
                    .frame(width: 44, height: 44)
                Text(String(card.displayName.prefix(1)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(card.companyAndTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // 会話のきっかけプレビュー
                if let firstStarter = card.analysis.conversationStarters.first {
                    Text(firstStarter)
                        .font(.system(size: 10))
                        .foregroundStyle(.indigo)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.yellow)
        }
        .contentShape(Rectangle())
    }
}
