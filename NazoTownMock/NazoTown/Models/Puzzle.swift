import Foundation
import SwiftUI

// MARK: - PuzzleType

enum PuzzleType: String, Sendable, CaseIterable {
    case wordScramble
    case numberSequence
    case imageRiddle
    case cipher
    case logicGate

    var displayName: String {
        switch self {
        case .wordScramble: "文字並べ替え"
        case .numberSequence: "数列推理"
        case .imageRiddle: "画像なぞなぞ"
        case .cipher: "暗号解読"
        case .logicGate: "論理パズル"
        }
    }

    var icon: String {
        switch self {
        case .wordScramble: "textformat.abc"
        case .numberSequence: "number.circle"
        case .imageRiddle: "photo.artframe"
        case .cipher: "lock.shield"
        case .logicGate: "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .wordScramble: .blue
        case .numberSequence: .purple
        case .imageRiddle: .orange
        case .cipher: .red
        case .logicGate: .green
        }
    }
}

// MARK: - PuzzleDifficulty

enum PuzzleDifficulty: Int, Sendable, Comparable {
    case easy = 1
    case medium = 2
    case hard = 3

    static func < (lhs: PuzzleDifficulty, rhs: PuzzleDifficulty) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .easy: "かんたん"
        case .medium: "ふつう"
        case .hard: "むずかしい"
        }
    }

    var stars: Int { rawValue }

    var color: Color {
        switch self {
        case .easy: .green
        case .medium: .orange
        case .hard: .red
        }
    }
}

// MARK: - Puzzle

struct Puzzle: Identifiable, Sendable {
    let id: UUID
    let type: PuzzleType
    let difficulty: PuzzleDifficulty
    let question: String
    let hint: String
    let answer: String
    let choices: [String]
    let timeLimit: TimeInterval

    init(
        id: UUID = UUID(),
        type: PuzzleType,
        difficulty: PuzzleDifficulty,
        question: String,
        hint: String,
        answer: String,
        choices: [String],
        timeLimit: TimeInterval = 120
    ) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.hint = hint
        self.answer = answer
        self.choices = choices
        self.timeLimit = timeLimit
    }
}

// MARK: - PuzzleSpot

struct PuzzleSpot: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let puzzle: Puzzle
    let spotNumber: Int
    let nfcTagID: String

    var coordinate: (latitude: Double, longitude: Double) {
        (latitude, longitude)
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        latitude: Double,
        longitude: Double,
        puzzle: Puzzle,
        spotNumber: Int,
        nfcTagID: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.puzzle = puzzle
        self.spotNumber = spotNumber
        self.nfcTagID = nfcTagID
    }
}
