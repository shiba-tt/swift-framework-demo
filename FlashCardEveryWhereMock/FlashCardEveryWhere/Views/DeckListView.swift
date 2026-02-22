import SwiftUI

struct DeckListView: View {
    @Bindable var viewModel: FlashCardViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.decks) { deck in
                    NavigationLink(value: deck.id) {
                        deckCell(deck)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteDeck(viewModel.decks[index])
                    }
                }
            }
            .navigationTitle("デッキ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingAddDeck = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { deckId in
                DeckDetailView(viewModel: viewModel, deckId: deckId)
            }
            .sheet(isPresented: $viewModel.isShowingAddDeck) {
                addDeckSheet()
            }
        }
    }

    // MARK: - Deck Cell

    private func deckCell(_ deck: Deck) -> some View {
        HStack(spacing: 12) {
            Image(systemName: deck.category.icon)
                .font(.title2)
                .foregroundStyle(deck.category.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Label("\(deck.totalCards)枚", systemImage: "rectangle.stack")
                    if deck.dueCards > 0 {
                        Label("\(deck.dueCards)要復習", systemImage: "clock")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            masteryRing(deck.averageMastery)
        }
        .padding(.vertical, 4)
    }

    private func masteryRing(_ mastery: Double) -> some View {
        ZStack {
            Circle()
                .stroke(.fill.tertiary, lineWidth: 4)
            Circle()
                .trim(from: 0, to: mastery)
                .stroke(masteryColor(mastery), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(mastery * 100))%")
                .font(.system(size: 10, weight: .bold))
        }
        .frame(width: 40, height: 40)
    }

    private func masteryColor(_ mastery: Double) -> Color {
        switch mastery {
        case 0..<0.3: .red
        case 0.3..<0.6: .orange
        case 0.6..<0.85: .yellow
        default: .green
        }
    }

    // MARK: - Add Deck Sheet

    private func addDeckSheet() -> some View {
        NavigationStack {
            Form {
                Section("デッキ情報") {
                    TextField("デッキ名", text: $viewModel.newDeckName)
                    Picker("カテゴリ", selection: $viewModel.newDeckCategory) {
                        ForEach(DeckCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("新しいデッキ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.isShowingAddDeck = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        viewModel.addDeck()
                    }
                    .disabled(viewModel.newDeckName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Deck Detail View

struct DeckDetailView: View {
    @Bindable var viewModel: FlashCardViewModel
    let deckId: UUID

    private var deck: Deck? {
        viewModel.decks.first { $0.id == deckId }
    }

    var body: some View {
        Group {
            if let deck {
                List {
                    Section {
                        deckInfoHeader(deck)
                    }

                    Section("カード一覧（\(deck.cards.count)枚）") {
                        ForEach(deck.cards) { card in
                            cardRow(card)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteCard(deck.cards[index].id)
                            }
                        }
                    }
                }
                .navigationTitle(deck.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Button {
                                viewModel.selectedDeckId = deckId
                                viewModel.isShowingAddCard = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            if deck.dueCards > 0 {
                                Button {
                                    viewModel.startStudy(deckId: deckId)
                                    viewModel.selectedTab = .study
                                } label: {
                                    Image(systemName: "play.fill")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $viewModel.isShowingAddCard) {
                    addCardSheet()
                }
            } else {
                ContentUnavailableView("デッキが見つかりません", systemImage: "questionmark.folder")
            }
        }
    }

    private func deckInfoHeader(_ deck: Deck) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                VStack {
                    Text("\(deck.totalCards)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("総カード数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(deck.dueCards)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    Text("要復習")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(deck.masteredCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("習得済み")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func cardRow(_ card: FlashCard) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(card.front)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: card.difficulty.icon)
                    .foregroundStyle(card.difficulty.color)
                    .font(.caption)
            }
            Text(card.back)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack(spacing: 12) {
                Label("\(card.correctCount)正解", systemImage: "checkmark")
                    .foregroundStyle(.green)
                Label("\(card.incorrectCount)不正解", systemImage: "xmark")
                    .foregroundStyle(.red)
                Spacer()
                Text(card.masteryLevel)
                    .foregroundStyle(card.masteryRate >= 0.85 ? .green : .secondary)
            }
            .font(.caption2)
        }
        .padding(.vertical, 2)
    }

    private func addCardSheet() -> some View {
        NavigationStack {
            Form {
                Section("カード内容") {
                    TextField("表面（問題）", text: $viewModel.newCardFront, axis: .vertical)
                        .lineLimit(3...5)
                    TextField("裏面（答え）", text: $viewModel.newCardBack, axis: .vertical)
                        .lineLimit(3...5)
                }
                Section("難易度") {
                    Picker("難易度", selection: $viewModel.newCardDifficulty) {
                        ForEach(CardDifficulty.allCases) { diff in
                            Label(diff.displayName, systemImage: diff.icon)
                                .tag(diff)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("カードを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.isShowingAddCard = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        viewModel.addCard()
                    }
                    .disabled(viewModel.newCardFront.isEmpty || viewModel.newCardBack.isEmpty)
                }
            }
        }
    }
}
