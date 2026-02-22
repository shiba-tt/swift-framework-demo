import Foundation

struct Reaction: Identifiable, Sendable {
    let id: UUID
    let emoji: String
    let participantName: String
    let timestamp: TimeInterval
    let date: Date

    var timestampText: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    static let availableEmojis: [String] = [
        "😂", "😍", "🔥", "😱", "👏", "😭", "🤣", "💯"
    ]

    static let samples: [Reaction] = [
        Reaction(id: UUID(), emoji: "😂", participantName: "ユウキ",
                 timestamp: 1245, date: Date().addingTimeInterval(-120)),
        Reaction(id: UUID(), emoji: "🔥", participantName: "サクラ",
                 timestamp: 1248, date: Date().addingTimeInterval(-115)),
        Reaction(id: UUID(), emoji: "😱", participantName: "レン",
                 timestamp: 1250, date: Date().addingTimeInterval(-110)),
        Reaction(id: UUID(), emoji: "😍", participantName: "あなた",
                 timestamp: 1380, date: Date().addingTimeInterval(-60)),
        Reaction(id: UUID(), emoji: "👏", participantName: "ユウキ",
                 timestamp: 1395, date: Date().addingTimeInterval(-45)),
        Reaction(id: UUID(), emoji: "💯", participantName: "レン",
                 timestamp: 1420, date: Date().addingTimeInterval(-20)),
    ]
}

struct ChatMessage: Identifiable, Sendable {
    let id: UUID
    let text: String
    let senderName: String
    let timestamp: TimeInterval
    let date: Date

    var timestampText: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    static let samples: [ChatMessage] = [
        ChatMessage(id: UUID(), text: "この映画すごくいい！",
                    senderName: "ユウキ", timestamp: 600,
                    date: Date().addingTimeInterval(-300)),
        ChatMessage(id: UUID(), text: "主人公かっこいいね",
                    senderName: "サクラ", timestamp: 900,
                    date: Date().addingTimeInterval(-200)),
        ChatMessage(id: UUID(), text: "次のシーンが楽しみ",
                    senderName: "レン", timestamp: 1200,
                    date: Date().addingTimeInterval(-100)),
        ChatMessage(id: UUID(), text: "ここ泣けるよね…",
                    senderName: "あなた", timestamp: 1400,
                    date: Date().addingTimeInterval(-30)),
    ]
}
