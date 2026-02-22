import Foundation
import SwiftUI

// MARK: - VotingManager

@MainActor
@Observable
final class VotingManager {
    static let shared = VotingManager()

    private(set) var events: [Event] = []
    private(set) var votedSessionIDs: Set<UUID> = []

    private init() {
        events = Self.generateSampleEvents()
    }

    // MARK: - Voting

    func castVote(eventID: UUID, sessionID: UUID, optionID: UUID) -> Bool {
        guard !votedSessionIDs.contains(sessionID) else { return false }

        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }),
              let sessionIndex = events[eventIndex].sessions.firstIndex(where: { $0.id == sessionID }),
              let optionIndex = events[eventIndex].sessions[sessionIndex].options.firstIndex(where: { $0.id == optionID })
        else {
            return false
        }

        events[eventIndex].sessions[sessionIndex].options[optionIndex].voteCount += 1
        votedSessionIDs.insert(sessionID)

        simulateOtherVotes(eventIndex: eventIndex, sessionIndex: sessionIndex)

        return true
    }

    func hasVoted(sessionID: UUID) -> Bool {
        votedSessionIDs.contains(sessionID)
    }

    func closeSession(eventID: UUID, sessionID: UUID) {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }),
              let sessionIndex = events[eventIndex].sessions.firstIndex(where: { $0.id == sessionID })
        else {
            return
        }
        events[eventIndex].sessions[sessionIndex].status = .results
        events[eventIndex].sessions[sessionIndex].endedAt = .now
    }

    // MARK: - Simulation

    private func simulateOtherVotes(eventIndex: Int, sessionIndex: Int) {
        let session = events[eventIndex].sessions[sessionIndex]
        for i in session.options.indices {
            let additionalVotes = Int.random(in: 5...50)
            events[eventIndex].sessions[sessionIndex].options[i].voteCount += additionalVotes
        }
    }

    // MARK: - Sample Data

    private static func generateSampleEvents() -> [Event] {
        [
            Event(
                title: "SUMMER SONIC 2025",
                venue: "幕張メッセ / ZOZOマリンスタジアム",
                eventType: .concert,
                status: .live,
                sessions: generateConcertSessions()
            ),
            Event(
                title: "iOSDC Japan 2025",
                venue: "早稲田大学 理工学術院",
                eventType: .conference,
                status: .live,
                sessions: generateConferenceSessions()
            ),
            Event(
                title: "Jリーグ 第20節",
                venue: "埼玉スタジアム2002",
                eventType: .sports,
                status: .live,
                sessions: generateSportsSessions()
            ),
        ]
    }

    private static func generateConcertSessions() -> [VotingSession] {
        [
            VotingSession(
                title: "次のアンコール曲をリクエスト！",
                description: "あなたの一票でアンコール曲が決まる",
                sessionType: .songRequest,
                options: [
                    VoteOption(label: "Starlight Symphony", subtitle: "最新アルバムリード曲", voteCount: 342, color: .purple),
                    VoteOption(label: "Midnight Runner", subtitle: "デビューシングル", voteCount: 287, color: .blue),
                    VoteOption(label: "Neon Dreams", subtitle: "ファン人気No.1", voteCount: 456, color: .pink),
                    VoteOption(label: "Eternal Wave", subtitle: "夏のアンセム", voteCount: 198, color: .cyan),
                ]
            ),
            VotingSession(
                title: "ライトショー: あなたの色でスタジアムを彩ろう",
                description: "スマホの画面が一斉に同じ色に！",
                sessionType: .lightShow,
                options: LightShowColor.allCases.map { lightColor in
                    VoteOption(
                        label: lightColor.displayName,
                        voteCount: Int.random(in: 100...500),
                        color: lightColor.color
                    )
                }
            ),
        ]
    }

    private static func generateConferenceSessions() -> [VotingSession] {
        [
            VotingSession(
                title: "Q&A: Swift Concurrency の未来",
                description: "スピーカーへの質問をリアルタイム投稿",
                sessionType: .qaQuestion,
                options: [
                    VoteOption(label: "Actorのパフォーマンスは？", subtitle: "パフォーマンス関連", voteCount: 89, color: .orange),
                    VoteOption(label: "既存コードの移行戦略は？", subtitle: "マイグレーション", voteCount: 156, color: .blue),
                    VoteOption(label: "TaskGroupの実践的使い方は？", subtitle: "実装パターン", voteCount: 72, color: .green),
                    VoteOption(label: "デッドロック回避のコツは？", subtitle: "デバッグ", voteCount: 134, color: .red),
                ]
            ),
        ]
    }

    private static func generateSportsSessions() -> [VotingSession] {
        [
            VotingSession(
                title: "本日のMVPを投票しよう！",
                description: "試合終了後に結果発表",
                sessionType: .mvpVote,
                options: [
                    VoteOption(label: "背番号 10 田中 翔", subtitle: "FW - 2ゴール", voteCount: 523, color: .red),
                    VoteOption(label: "背番号 7 佐藤 健太", subtitle: "MF - 1ゴール1アシスト", voteCount: 412, color: .blue),
                    VoteOption(label: "背番号 4 鈴木 大地", subtitle: "DF - クリーンシート", voteCount: 287, color: .green),
                    VoteOption(label: "背番号 1 山田 隼人", subtitle: "GK - PK セーブ", voteCount: 198, color: .yellow),
                ]
            ),
            VotingSession(
                title: "応援カラーを選ぼう！",
                description: "スタジアムを一色に染めよう",
                sessionType: .lightShow,
                options: [
                    VoteOption(label: "レッド", subtitle: "ホームカラー", voteCount: 892, color: .red),
                    VoteOption(label: "ホワイト", subtitle: "セカンドカラー", voteCount: 345, color: .white),
                    VoteOption(label: "ゴールド", subtitle: "勝利の色", voteCount: 567, color: .yellow),
                ]
            ),
        ]
    }
}
