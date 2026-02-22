import Foundation
import SwiftUI

// MARK: - EventType

enum EventType: String, Sendable, CaseIterable {
    case concert
    case conference
    case sports

    var displayName: String {
        switch self {
        case .concert: "コンサート"
        case .conference: "カンファレンス"
        case .sports: "スポーツ"
        }
    }

    var icon: String {
        switch self {
        case .concert: "music.mic"
        case .conference: "person.3.fill"
        case .sports: "sportscourt"
        }
    }

    var color: Color {
        switch self {
        case .concert: .purple
        case .conference: .blue
        case .sports: .green
        }
    }
}

// MARK: - EventStatus

enum EventStatus: String, Sendable {
    case upcoming
    case live
    case ended

    var displayName: String {
        switch self {
        case .upcoming: "開始前"
        case .live: "ライブ中"
        case .ended: "終了"
        }
    }
}

// MARK: - Event

struct Event: Identifiable, Sendable {
    let id: UUID
    let title: String
    let venue: String
    let eventType: EventType
    let startDate: Date
    var status: EventStatus
    var sessions: [VotingSession]

    init(
        id: UUID = UUID(),
        title: String,
        venue: String,
        eventType: EventType,
        startDate: Date = .now,
        status: EventStatus = .live,
        sessions: [VotingSession] = []
    ) {
        self.id = id
        self.title = title
        self.venue = venue
        self.eventType = eventType
        self.startDate = startDate
        self.status = status
        self.sessions = sessions
    }

    var activeSessions: [VotingSession] {
        sessions.filter { $0.status == .active }
    }

    var totalParticipants: Int {
        sessions.reduce(0) { $0 + $1.totalVotes }
    }
}

// MARK: - VotingSession

struct VotingSession: Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let sessionType: SessionType
    var options: [VoteOption]
    var status: SessionStatus
    let createdAt: Date
    var endedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        sessionType: SessionType,
        options: [VoteOption],
        status: SessionStatus = .active,
        createdAt: Date = .now,
        endedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.sessionType = sessionType
        self.options = options
        self.status = status
        self.createdAt = createdAt
        self.endedAt = endedAt
    }

    var totalVotes: Int {
        options.reduce(0) { $0 + $1.voteCount }
    }

    var leadingOption: VoteOption? {
        options.max(by: { $0.voteCount < $1.voteCount })
    }
}

// MARK: - SessionType

enum SessionType: String, Sendable {
    case songRequest
    case qaQuestion
    case mvpVote
    case lightShow

    var displayName: String {
        switch self {
        case .songRequest: "リクエスト投票"
        case .qaQuestion: "Q&A"
        case .mvpVote: "MVP投票"
        case .lightShow: "ライトショー"
        }
    }

    var icon: String {
        switch self {
        case .songRequest: "music.note.list"
        case .qaQuestion: "questionmark.bubble"
        case .mvpVote: "star.fill"
        case .lightShow: "lightbulb.fill"
        }
    }
}

// MARK: - SessionStatus

enum SessionStatus: String, Sendable {
    case active
    case closed
    case results

    var displayName: String {
        switch self {
        case .active: "投票受付中"
        case .closed: "投票終了"
        case .results: "結果発表"
        }
    }
}
