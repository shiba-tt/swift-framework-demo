import Foundation
import SwiftUI

// MARK: - CardDifficulty

enum CardDifficulty: String, Sendable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: "かんたん"
        case .medium: "ふつう"
        case .hard: "むずかしい"
        }
    }

    var color: Color {
        switch self {
        case .easy: .green
        case .medium: .orange
        case .hard: .red
        }
    }

    var icon: String {
        switch self {
        case .easy: "star"
        case .medium: "star.leadinghalf.filled"
        case .hard: "star.fill"
        }
    }
}

// MARK: - DeckCategory

enum DeckCategory: String, Sendable, CaseIterable, Identifiable {
    case english
    case japanese
    case science
    case history
    case programming
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: "英語"
        case .japanese: "国語"
        case .science: "理科"
        case .history: "歴史"
        case .programming: "プログラミング"
        case .other: "その他"
        }
    }

    var icon: String {
        switch self {
        case .english: "textformat.abc"
        case .japanese: "character.ja"
        case .science: "atom"
        case .history: "clock.arrow.circlepath"
        case .programming: "chevron.left.forwardslash.chevron.right"
        case .other: "square.grid.2x2"
        }
    }

    var color: Color {
        switch self {
        case .english: .blue
        case .japanese: .red
        case .science: .green
        case .history: .brown
        case .programming: .purple
        case .other: .gray
        }
    }
}

// MARK: - FlashCard

struct FlashCard: Identifiable, Sendable {
    let id: UUID
    var front: String
    var back: String
    var difficulty: CardDifficulty
    var correctCount: Int
    var incorrectCount: Int
    var lastReviewedAt: Date?
    var nextReviewAt: Date
    var interval: Int // 間隔反復の日数

    init(
        id: UUID = UUID(),
        front: String,
        back: String,
        difficulty: CardDifficulty = .medium,
        correctCount: Int = 0,
        incorrectCount: Int = 0,
        lastReviewedAt: Date? = nil,
        nextReviewAt: Date = .now,
        interval: Int = 1
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.difficulty = difficulty
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.lastReviewedAt = lastReviewedAt
        self.nextReviewAt = nextReviewAt
        self.interval = interval
    }

    var masteryRate: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total)
    }

    var masteryLevel: String {
        switch masteryRate {
        case 0..<0.3: "初学"
        case 0.3..<0.6: "学習中"
        case 0.6..<0.85: "定着中"
        default: "習得済み"
        }
    }

    var isDue: Bool {
        nextReviewAt <= .now
    }
}

// MARK: - Deck

struct Deck: Identifiable, Sendable {
    let id: UUID
    var name: String
    var category: DeckCategory
    var cards: [FlashCard]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: DeckCategory,
        cards: [FlashCard] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.cards = cards
        self.createdAt = createdAt
    }

    var totalCards: Int { cards.count }

    var dueCards: Int {
        cards.filter(\.isDue).count
    }

    var averageMastery: Double {
        guard !cards.isEmpty else { return 0 }
        return cards.reduce(0) { $0 + $1.masteryRate } / Double(cards.count)
    }

    var masteredCount: Int {
        cards.filter { $0.masteryRate >= 0.85 }.count
    }
}

// MARK: - StudySession

struct StudySession: Identifiable, Sendable {
    let id: UUID
    let deckId: UUID
    let startedAt: Date
    var answeredCount: Int
    var correctCount: Int
    var duration: TimeInterval

    init(
        id: UUID = UUID(),
        deckId: UUID,
        startedAt: Date = .now,
        answeredCount: Int = 0,
        correctCount: Int = 0,
        duration: TimeInterval = 0
    ) {
        self.id = id
        self.deckId = deckId
        self.startedAt = startedAt
        self.answeredCount = answeredCount
        self.correctCount = correctCount
        self.duration = duration
    }

    var accuracy: Double {
        guard answeredCount > 0 else { return 0 }
        return Double(correctCount) / Double(answeredCount)
    }
}

// MARK: - DailyStats

struct DailyStats: Sendable {
    let date: Date
    let cardsStudied: Int
    let correctAnswers: Int
    let streakDays: Int
    let totalStudyTime: TimeInterval

    var accuracy: Double {
        guard cardsStudied > 0 else { return 0 }
        return Double(correctAnswers) / Double(cardsStudied)
    }
}
