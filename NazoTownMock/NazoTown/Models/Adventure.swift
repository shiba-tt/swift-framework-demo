import Foundation

// MARK: - AdventureStatus

enum AdventureStatus: String, Sendable {
    case notStarted
    case inProgress
    case completed
    case expired

    var displayName: String {
        switch self {
        case .notStarted: "未開始"
        case .inProgress: "進行中"
        case .completed: "クリア"
        case .expired: "期限切れ"
        }
    }
}

// MARK: - SpotResult

struct SpotResult: Identifiable, Sendable {
    let id: UUID
    let spotID: UUID
    let isSolved: Bool
    let answeredAt: Date
    let timeSpent: TimeInterval
    let hintUsed: Bool

    init(
        id: UUID = UUID(),
        spotID: UUID,
        isSolved: Bool,
        answeredAt: Date = .now,
        timeSpent: TimeInterval,
        hintUsed: Bool
    ) {
        self.id = id
        self.spotID = spotID
        self.isSolved = isSolved
        self.answeredAt = answeredAt
        self.timeSpent = timeSpent
        self.hintUsed = hintUsed
    }

    var scorePoints: Int {
        guard isSolved else { return 0 }
        var base = 100
        if !hintUsed { base += 50 }
        if timeSpent < 30 { base += 30 }
        else if timeSpent < 60 { base += 15 }
        return base
    }
}

// MARK: - Adventure

struct Adventure: Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let areaName: String
    let spots: [PuzzleSpot]
    let timeLimitMinutes: Int
    var startedAt: Date?
    var results: [SpotResult]
    var status: AdventureStatus

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        areaName: String,
        spots: [PuzzleSpot],
        timeLimitMinutes: Int = 120,
        startedAt: Date? = nil,
        results: [SpotResult] = [],
        status: AdventureStatus = .notStarted
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.areaName = areaName
        self.spots = spots
        self.timeLimitMinutes = timeLimitMinutes
        self.startedAt = startedAt
        self.results = results
        self.status = status
    }

    var totalScore: Int {
        results.reduce(0) { $0 + $1.scorePoints }
    }

    var solvedCount: Int {
        results.filter(\.isSolved).count
    }

    var progressRatio: Double {
        guard !spots.isEmpty else { return 0 }
        return Double(results.count) / Double(spots.count)
    }

    var currentSpotIndex: Int {
        min(results.count, spots.count - 1)
    }

    var currentSpot: PuzzleSpot? {
        guard currentSpotIndex < spots.count else { return nil }
        return spots[currentSpotIndex]
    }

    var remainingTime: TimeInterval? {
        guard let startedAt else { return nil }
        let elapsed = Date.now.timeIntervalSince(startedAt)
        let limit = TimeInterval(timeLimitMinutes * 60)
        return max(0, limit - elapsed)
    }

    var isTimeUp: Bool {
        guard let remaining = remainingTime else { return false }
        return remaining <= 0
    }
}
