import Foundation
import SwiftUI

// MARK: - Family Member

struct FamilyMember: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let calendarID: String

    var initials: String {
        String(name.prefix(1))
    }
}

// MARK: - Time Slot Availability

enum SlotAvailability: Sendable {
    case free
    case busy
    case tentative

    var color: Color {
        switch self {
        case .free: return .green
        case .busy: return .red
        case .tentative: return .yellow
        }
    }

    var label: String {
        switch self {
        case .free: return "\u{7A7A}\u{304D}"
        case .busy: return "\u{4E88}\u{5B9A}\u{3042}\u{308A}"
        case .tentative: return "\u{4EEE}"
        }
    }
}

// MARK: - Member Schedule

struct MemberSchedule: Identifiable, Sendable {
    let id = UUID()
    let member: FamilyMember
    let slots: [TimeSlot]
}

// MARK: - Time Slot

struct TimeSlot: Identifiable, Sendable {
    let id = UUID()
    let startHour: Int
    let endHour: Int
    let availability: SlotAvailability
    let eventTitle: String?

    var timeText: String {
        "\(startHour):00\u{2013}\(endHour):00"
    }
}

// MARK: - Common Free Slot

struct CommonFreeSlot: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let startHour: Int
    let endHour: Int
    let duration: Int
    let availableMembers: [FamilyMember]

    var timeText: String {
        "\(startHour):00\u{2013}\(endHour):00"
    }

    var durationText: String {
        if duration >= 60 {
            return "\(duration / 60)\u{6642}\u{9593}"
        }
        return "\(duration)\u{5206}"
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter.string(from: date)
    }
}

// MARK: - Event Suggestion

struct EventSuggestion: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let icon: String
    let suggestedSlot: CommonFreeSlot
    let estimatedDuration: Int

    var durationText: String {
        if estimatedDuration >= 60 {
            return "\u{7D04}\(estimatedDuration / 60)\u{6642}\u{9593}"
        }
        return "\u{7D04}\(estimatedDuration)\u{5206}"
    }
}
