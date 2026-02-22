import SwiftUI

/// 名刺一覧画面
struct ContactListView: View {
    let viewModel: ContextCardsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.contacts.isEmpty {
                    ContentUnavailableView(
                        "名刺がありません",
                        systemImage: "person.crop.rectangle.stack",
                        description: Text("スキャンタブから名刺を撮影して追加しましょう")
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredContacts) { card in
                            Button {
                                viewModel.selectedContact = card
                                viewModel.showDetailSheet = true
                            } label: {
                                ContactRow(card: card, viewModel: viewModel)
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteContact(at: offsets)
                        }
                    }
                    .searchable(text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.searchText = $0 }
                    ), prompt: "名前・会社・役職で検索")
                }
            }
            .navigationTitle("名刺")
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

// MARK: - Contact Row

private struct ContactRow: View {
    let card: ContactCard
    let viewModel: ContextCardsViewModel

    var body: some View {
        HStack(spacing: 12) {
            // アバター
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
                HStack {
                    Text(card.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    if card.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                    }
                }
                Text(card.companyAndTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(card.scannedAtText)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .contentShape(Rectangle())
    }
}
