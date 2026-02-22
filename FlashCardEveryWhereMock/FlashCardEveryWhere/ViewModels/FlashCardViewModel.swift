import Foundation

// MARK: - AppTab

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case decks
    case study
    case stats

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .home: "ホーム"
        case .decks: "デッキ"
        case .study: "学習"
        case .stats: "統計"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .decks: "rectangle.stack.fill"
        case .study: "brain.head.profile"
        case .stats: "chart.bar.fill"
        }
    }
}

// MARK: - FlashCardViewModel

@MainActor
@Observable
final class FlashCardViewModel {
    private let manager = StudyManager.shared

    var selectedTab: AppTab = .home
    var isShowingAddDeck = false
    var isShowingAddCard = false
    var selectedDeckId: UUID?
    var isStudying = false
    var currentCardIndex = 0
    var isCardFlipped = false
    var toastMessage: String?

    // Add Deck form
    var newDeckName = ""
    var newDeckCategory: DeckCategory = .english

    // Add Card form
    var newCardFront = ""
    var newCardBack = ""
    var newCardDifficulty: CardDifficulty = .medium

    // MARK: - Computed Properties

    var decks: [Deck] { manager.decks }
    var totalCards: Int { manager.totalCards }
    var totalDueCards: Int { manager.totalDueCards }
    var overallMastery: Double { manager.overallMastery }
    var streakDays: Int { manager.streakDays }
    var todayStudiedCount: Int { manager.todayStudiedCount }
    var dailyStats: DailyStats { manager.dailyStats() }
    var cardsByDifficulty: [(difficulty: CardDifficulty, count: Int)] { manager.cardsByDifficulty() }

    var selectedDeck: Deck? {
        guard let id = selectedDeckId else { return nil }
        return decks.first { $0.id == id }
    }

    var currentStudyCards: [FlashCard] {
        guard let deckId = selectedDeckId else { return manager.allDueCards() }
        return manager.dueCards(for: deckId)
    }

    var currentCard: FlashCard? {
        let cards = currentStudyCards
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }

    var studyProgress: Double {
        let cards = currentStudyCards
        guard !cards.isEmpty else { return 1.0 }
        return Double(currentCardIndex) / Double(cards.count)
    }

    var masteryText: String {
        let percentage = Int(overallMastery * 100)
        return "\(percentage)%"
    }

    // MARK: - Actions

    func addDeck() {
        guard !newDeckName.isEmpty else { return }
        manager.addDeck(name: newDeckName, category: newDeckCategory)
        newDeckName = ""
        newDeckCategory = .english
        isShowingAddDeck = false
        showToast("デッキを作成しました")
    }

    func deleteDeck(_ deck: Deck) {
        manager.deleteDeck(deck)
    }

    func addCard() {
        guard let deckId = selectedDeckId,
              !newCardFront.isEmpty,
              !newCardBack.isEmpty else { return }
        manager.addCard(to: deckId, front: newCardFront, back: newCardBack, difficulty: newCardDifficulty)
        newCardFront = ""
        newCardBack = ""
        newCardDifficulty = .medium
        isShowingAddCard = false
        showToast("カードを追加しました")
    }

    func deleteCard(_ cardId: UUID) {
        guard let deckId = selectedDeckId else { return }
        manager.deleteCard(cardId, from: deckId)
    }

    func startStudy(deckId: UUID? = nil) {
        selectedDeckId = deckId
        currentCardIndex = 0
        isCardFlipped = false
        isStudying = true
    }

    func flipCard() {
        isCardFlipped.toggle()
    }

    func answerCard(isCorrect: Bool) {
        guard let card = currentCard else { return }
        let deckId = selectedDeckId ?? deckForCard(card.id)
        guard let dId = deckId else { return }

        manager.answerCard(card.id, in: dId, isCorrect: isCorrect)

        isCardFlipped = false
        currentCardIndex += 1

        if currentCardIndex >= currentStudyCards.count {
            isStudying = false
            showToast("セッション完了！お疲れ様でした")
        }
    }

    func endStudy() {
        isStudying = false
        isCardFlipped = false
        currentCardIndex = 0
    }

    // MARK: - Helpers

    private func deckForCard(_ cardId: UUID) -> UUID? {
        decks.first { deck in
            deck.cards.contains { $0.id == cardId }
        }?.id
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2))
            toastMessage = nil
        }
    }
}
