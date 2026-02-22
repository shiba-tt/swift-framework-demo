import Foundation
import SwiftData

// MARK: - VoiceMemo（永続化モデル）

@Model
final class VoiceMemo {
    var id: UUID
    var recordedAt: Date
    var rawTranscription: String
    var duration: TimeInterval
    var categoryRawValue: String?
    var title: String?
    var summary: String?
    var actionItems: [ActionItemData]
    var keyPoints: [String]
    var isStructured: Bool

    init(
        id: UUID = UUID(),
        recordedAt: Date = Date(),
        rawTranscription: String,
        duration: TimeInterval,
        categoryRawValue: String? = nil,
        title: String? = nil,
        summary: String? = nil,
        actionItems: [ActionItemData] = [],
        keyPoints: [String] = [],
        isStructured: Bool = false
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.rawTranscription = rawTranscription
        self.duration = duration
        self.categoryRawValue = categoryRawValue
        self.title = title
        self.summary = summary
        self.actionItems = actionItems
        self.keyPoints = keyPoints
        self.isStructured = isStructured
    }

    // MARK: - Computed Properties

    var category: MemoCategory? {
        guard let raw = categoryRawValue else { return nil }
        return MemoCategory(rawValue: raw)
    }

    var displayTitle: String {
        title ?? "無題のメモ"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E) HH:mm"
        return formatter.string(from: recordedAt)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        }
        return "\(seconds)秒"
    }

    var pendingActionItemsCount: Int {
        actionItems.filter { !$0.isCompleted }.count
    }
}

// MARK: - ActionItemData（永続化用）

struct ActionItemData: Codable, Sendable, Identifiable {
    var id: UUID
    let content: String
    let assignee: String?
    let priority: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        content: String,
        assignee: String? = nil,
        priority: String = "medium",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.content = content
        self.assignee = assignee
        self.priority = priority
        self.isCompleted = isCompleted
    }

    var priorityEmoji: String {
        switch priority {
        case "high": return "🔴"
        case "medium": return "🟡"
        case "low": return "🟢"
        default: return "⚪"
        }
    }
}
