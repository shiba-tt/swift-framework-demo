import Foundation

// MARK: - StudyManager

@MainActor
@Observable
final class StudyManager {
    static let shared = StudyManager()

    private(set) var decks: [Deck] = []
    private(set) var studySessions: [StudySession] = []
    private(set) var streakDays: Int = 7

    private init() {
        decks = Self.generateSampleDecks()
        studySessions = Self.generateSampleSessions(decks: decks)
    }

    // MARK: - Deck Operations

    func addDeck(name: String, category: DeckCategory) {
        let deck = Deck(name: name, category: category)
        decks.insert(deck, at: 0)
    }

    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
    }

    func addCard(to deckId: UUID, front: String, back: String, difficulty: CardDifficulty = .medium) {
        guard let index = decks.firstIndex(where: { $0.id == deckId }) else { return }
        let card = FlashCard(front: front, back: back, difficulty: difficulty)
        decks[index].cards.append(card)
    }

    func deleteCard(_ cardId: UUID, from deckId: UUID) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deckId }) else { return }
        decks[deckIndex].cards.removeAll { $0.id == cardId }
    }

    // MARK: - Study Operations

    func dueCards(for deckId: UUID) -> [FlashCard] {
        guard let deck = decks.first(where: { $0.id == deckId }) else { return [] }
        return deck.cards.filter(\.isDue)
    }

    func allDueCards() -> [FlashCard] {
        decks.flatMap { $0.cards.filter(\.isDue) }
    }

    func answerCard(_ cardId: UUID, in deckId: UUID, isCorrect: Bool) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deckId }),
              let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == cardId }) else {
            return
        }

        var card = decks[deckIndex].cards[cardIndex]
        card.lastReviewedAt = .now

        if isCorrect {
            card.correctCount += 1
            card.interval = min(card.interval * 2, 30)
        } else {
            card.incorrectCount += 1
            card.interval = 1
        }

        let calendar = Calendar.current
        card.nextReviewAt = calendar.date(byAdding: .day, value: card.interval, to: .now) ?? .now

        // 正解率に基づいて難易度を自動調整
        if card.masteryRate >= 0.85 {
            card.difficulty = .easy
        } else if card.masteryRate >= 0.5 {
            card.difficulty = .medium
        } else {
            card.difficulty = .hard
        }

        decks[deckIndex].cards[cardIndex] = card
    }

    // MARK: - Statistics

    var totalCards: Int {
        decks.reduce(0) { $0 + $1.totalCards }
    }

    var totalDueCards: Int {
        decks.reduce(0) { $0 + $1.dueCards }
    }

    var overallMastery: Double {
        let allCards = decks.flatMap(\.cards)
        guard !allCards.isEmpty else { return 0 }
        return allCards.reduce(0) { $0 + $1.masteryRate } / Double(allCards.count)
    }

    var todayStudiedCount: Int {
        let calendar = Calendar.current
        return decks.flatMap(\.cards)
            .filter { card in
                guard let reviewed = card.lastReviewedAt else { return false }
                return calendar.isDateInToday(reviewed)
            }
            .count
    }

    func dailyStats() -> DailyStats {
        let todayCards = decks.flatMap(\.cards).filter { card in
            guard let reviewed = card.lastReviewedAt else { return false }
            return Calendar.current.isDateInToday(reviewed)
        }
        let correct = todayCards.filter { $0.masteryRate >= 0.5 }.count
        return DailyStats(
            date: .now,
            cardsStudied: todayCards.count,
            correctAnswers: correct,
            streakDays: streakDays,
            totalStudyTime: Double(todayCards.count) * 8.0
        )
    }

    func cardsByDifficulty() -> [(difficulty: CardDifficulty, count: Int)] {
        let allCards = decks.flatMap(\.cards)
        return CardDifficulty.allCases.map { difficulty in
            let count = allCards.filter { $0.difficulty == difficulty }.count
            return (difficulty, count)
        }
    }

    // MARK: - Quick Study (for Siri / Widget)

    func quickStudyCard() -> (deckId: UUID, card: FlashCard)? {
        for deck in decks {
            if let card = deck.cards.first(where: \.isDue) {
                return (deck.id, card)
            }
        }
        return nil
    }

    // MARK: - Sample Data

    private static func generateSampleDecks() -> [Deck] {
        let calendar = Calendar.current

        let englishCards: [FlashCard] = [
            FlashCard(front: "ubiquitous", back: "至る所にある、遍在する", difficulty: .hard, correctCount: 2, incorrectCount: 3, lastReviewedAt: calendar.date(byAdding: .hour, value: -3, to: .now), nextReviewAt: .now, interval: 1),
            FlashCard(front: "ephemeral", back: "はかない、短命の", difficulty: .hard, correctCount: 1, incorrectCount: 2, lastReviewedAt: calendar.date(byAdding: .day, value: -1, to: .now), nextReviewAt: .now, interval: 1),
            FlashCard(front: "pragmatic", back: "実用的な、現実的な", difficulty: .medium, correctCount: 5, incorrectCount: 2, lastReviewedAt: calendar.date(byAdding: .day, value: -2, to: .now), nextReviewAt: .now, interval: 2),
            FlashCard(front: "serendipity", back: "偶然の幸運、思いがけない発見", difficulty: .medium, correctCount: 4, incorrectCount: 1, nextReviewAt: calendar.date(byAdding: .day, value: 1, to: .now)!, interval: 4),
            FlashCard(front: "resilient", back: "回復力のある、弾力性のある", difficulty: .easy, correctCount: 8, incorrectCount: 1, lastReviewedAt: calendar.date(byAdding: .day, value: -1, to: .now), nextReviewAt: calendar.date(byAdding: .day, value: 3, to: .now)!, interval: 8),
            FlashCard(front: "ambiguous", back: "曖昧な、多義的な", difficulty: .medium, correctCount: 3, incorrectCount: 2, nextReviewAt: .now, interval: 2),
            FlashCard(front: "meticulous", back: "細心の注意を払う、几帳面な", difficulty: .hard, correctCount: 1, incorrectCount: 3, nextReviewAt: .now, interval: 1),
            FlashCard(front: "eloquent", back: "雄弁な、表現力豊かな", difficulty: .easy, correctCount: 7, incorrectCount: 0, lastReviewedAt: calendar.date(byAdding: .day, value: -2, to: .now), nextReviewAt: calendar.date(byAdding: .day, value: 5, to: .now)!, interval: 16),
        ]

        let programmingCards: [FlashCard] = [
            FlashCard(front: "@Observable とは？", back: "SwiftUI で状態監視を行うマクロ。iOS 17+ で Observation フレームワークとともに導入", difficulty: .medium, correctCount: 6, incorrectCount: 1, nextReviewAt: calendar.date(byAdding: .day, value: 2, to: .now)!, interval: 8),
            FlashCard(front: "async/await のメリット", back: "非同期処理を同期的なコードのように記述できる。コールバック地獄を回避し、可読性とエラーハンドリングが向上", difficulty: .easy, correctCount: 9, incorrectCount: 0, nextReviewAt: calendar.date(byAdding: .day, value: 7, to: .now)!, interval: 16),
            FlashCard(front: "Actor とは？", back: "並行処理においてデータ競合を防ぐ参照型。内部状態へのアクセスを直列化して安全性を保証", difficulty: .hard, correctCount: 2, incorrectCount: 4, nextReviewAt: .now, interval: 1),
            FlashCard(front: "MVVM パターン", back: "Model-View-ViewModel。ビューとビジネスロジックを分離し、データバインディングで接続するアーキテクチャ", difficulty: .medium, correctCount: 5, incorrectCount: 1, nextReviewAt: .now, interval: 4),
            FlashCard(front: "Core Data vs SwiftData", back: "SwiftData は Core Data の後継。Swift マクロベースで宣言的にモデル定義。iOS 17+", difficulty: .medium, correctCount: 3, incorrectCount: 2, nextReviewAt: .now, interval: 2),
        ]

        let historyCards: [FlashCard] = [
            FlashCard(front: "明治維新", back: "1868年。江戸幕府が倒れ、天皇を中心とする新政府が誕生。近代化と西洋化が進む", difficulty: .easy, correctCount: 10, incorrectCount: 1, nextReviewAt: calendar.date(byAdding: .day, value: 10, to: .now)!, interval: 30),
            FlashCard(front: "関ヶ原の戦い", back: "1600年。徳川家康率いる東軍と石田三成率いる西軍が激突。家康が勝利し江戸幕府の基盤を築く", difficulty: .medium, correctCount: 5, incorrectCount: 2, nextReviewAt: .now, interval: 4),
            FlashCard(front: "大化の改新", back: "645年。中大兄皇子と中臣鎌足が蘇我氏を倒し、中央集権国家体制を目指した政治改革", difficulty: .hard, correctCount: 2, incorrectCount: 3, nextReviewAt: .now, interval: 1),
            FlashCard(front: "応仁の乱", back: "1467-1477年。室町幕府の後継争いに端を発した大乱。京都が焼け野原になり、戦国時代の幕開け", difficulty: .hard, correctCount: 1, incorrectCount: 4, nextReviewAt: .now, interval: 1),
        ]

        let scienceCards: [FlashCard] = [
            FlashCard(front: "光合成の化学式", back: "6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂\n二酸化炭素と水から糖とO₂を生成", difficulty: .medium, correctCount: 4, incorrectCount: 2, nextReviewAt: .now, interval: 2),
            FlashCard(front: "ニュートンの運動の第三法則", back: "作用・反作用の法則。物体Aが物体Bに力を加えると、Bは同じ大きさで反対向きの力をAに加える", difficulty: .easy, correctCount: 7, incorrectCount: 1, nextReviewAt: calendar.date(byAdding: .day, value: 4, to: .now)!, interval: 8),
            FlashCard(front: "DNA の二重螺旋構造", back: "ワトソンとクリックが1953年に発見。A-T、G-Cの塩基対で結合した2本のポリヌクレオチド鎖", difficulty: .medium, correctCount: 3, incorrectCount: 1, nextReviewAt: .now, interval: 4),
        ]

        return [
            Deck(name: "TOEIC 頻出英単語", category: .english, cards: englishCards, createdAt: calendar.date(byAdding: .day, value: -14, to: .now)!),
            Deck(name: "Swift 基礎概念", category: .programming, cards: programmingCards, createdAt: calendar.date(byAdding: .day, value: -10, to: .now)!),
            Deck(name: "日本史 重要事件", category: .history, cards: historyCards, createdAt: calendar.date(byAdding: .day, value: -21, to: .now)!),
            Deck(name: "理科 基礎知識", category: .science, cards: scienceCards, createdAt: calendar.date(byAdding: .day, value: -7, to: .now)!),
        ]
    }

    private static func generateSampleSessions(decks: [Deck]) -> [StudySession] {
        let calendar = Calendar.current
        guard let firstDeck = decks.first else { return [] }

        return [
            StudySession(deckId: firstDeck.id, startedAt: calendar.date(byAdding: .hour, value: -2, to: .now)!, answeredCount: 8, correctCount: 6, duration: 240),
            StudySession(deckId: decks[1].id, startedAt: calendar.date(byAdding: .day, value: -1, to: .now)!, answeredCount: 5, correctCount: 4, duration: 180),
            StudySession(deckId: firstDeck.id, startedAt: calendar.date(byAdding: .day, value: -2, to: .now)!, answeredCount: 10, correctCount: 7, duration: 420),
        ]
    }
}
