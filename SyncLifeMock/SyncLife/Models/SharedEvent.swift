import Foundation
import SwiftUI

// MARK: - Shared Family Event

struct SharedFamilyEvent: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let date: Date
    let startHour: Int
    let endHour: Int
    let participants: [FamilyMember]
    let category: EventCategory
    let location: String?

    var timeText: String {
        "\(startHour):00\u{2013}\(endHour):00"
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M\u{6708}d\u{65E5} (E)"
        return formatter.string(from: date)
    }

    var participantNames: String {
        participants.map(\.name).joined(separator: "\u{3001}")
    }
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable, Sendable {
    case family = "\u{5BB6}\u{65CF}"
    case outing = "\u{304A}\u{51FA}\u{304B}\u{3051}"
    case meal = "\u{98DF}\u{4E8B}"
    case exercise = "\u{904B}\u{52D5}"
    case errand = "\u{7528}\u{4E8B}"

    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .outing: return "car.fill"
        case .meal: return "fork.knife"
        case .exercise: return "figure.run"
        case .errand: return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .family: return .blue
        case .outing: return .green
        case .meal: return .orange
        case .exercise: return .red
        case .errand: return .purple
        }
    }
}

// MARK: - Shared Task

struct SharedTask: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let assignee: FamilyMember?
    let dueDate: Date?
    let isCompleted: Bool
    let category: TaskCategory

    var dueDateText: String? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: dueDate)
    }
}

// MARK: - Task Category

enum TaskCategory: String, CaseIterable, Sendable {
    case shopping = "\u{8CB7}\u{3044}\u{7269}"
    case housework = "\u{5BB6}\u{4E8B}"
    case preparation = "\u{6E96}\u{5099}"
    case other = "\u{305D}\u{306E}\u{4ED6}"

    var icon: String {
        switch self {
        case .shopping: return "cart.fill"
        case .housework: return "washer.fill"
        case .preparation: return "checklist"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .shopping: return .green
        case .housework: return .blue
        case .preparation: return .orange
        case .other: return .gray
        }
    }
}

// MARK: - Location Notification

struct LocationNotification: Identifiable, Sendable {
    let id = UUID()
    let member: FamilyMember
    let location: String
    let message: String
    let timestamp: Date

    var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Weekly Stats

struct WeeklyFamilyStats: Sendable {
    let totalFamilyEvents: Int
    let sharedHours: Double
    let completedTasks: Int
    let pendingTasks: Int
    let freeSlots: Int
}
