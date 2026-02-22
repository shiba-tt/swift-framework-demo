import Foundation
import SwiftUI

// MARK: - SyncLife EventKit Manager

@MainActor
final class SyncLifeEventKitManager: Sendable {
    static let shared = SyncLifeEventKitManager()

    private init() {}

    // MARK: - Calendar Access

    func requestCalendarAccess() async -> Bool {
        // In a real app:
        // let store = EKEventStore()
        // if #available(iOS 17.0, *) {
        //     return try await store.requestFullAccessToEvents()
        // } else {
        //     return try await store.requestAccess(to: .event)
        // }
        return true
    }

    // MARK: - Family Members

    func fetchFamilyMembers() async -> [FamilyMember] {
        [
            FamilyMember(name: "\u{30D1}\u{30D1}", icon: "person.fill", color: .blue, calendarID: "cal_papa"),
            FamilyMember(name: "\u{30DE}\u{30DE}", icon: "person.fill", color: .pink, calendarID: "cal_mama"),
            FamilyMember(name: "\u{592A}\u{90CE}", icon: "person.fill", color: .green, calendarID: "cal_taro"),
            FamilyMember(name: "\u{82B1}\u{5B50}", icon: "person.fill", color: .orange, calendarID: "cal_hanako"),
        ]
    }

    // MARK: - Member Schedules

    func fetchMemberSchedules(for date: Date) async -> [MemberSchedule] {
        let members = await fetchFamilyMembers()

        return members.map { member in
            MemberSchedule(
                member: member,
                slots: generateSlots(for: member)
            )
        }
    }

    // MARK: - Common Free Slots

    func findCommonFreeSlots(days: Int) async -> [CommonFreeSlot] {
        let members = await fetchFamilyMembers()
        let calendar = Calendar.current
        var slots: [CommonFreeSlot] = []

        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }

            let isWeekend = calendar.isDateInWeekend(date)

            if isWeekend {
                // Weekends have more free time
                let morningSlot = CommonFreeSlot(
                    date: date,
                    startHour: 10,
                    endHour: 12,
                    duration: 120,
                    availableMembers: members
                )
                slots.append(morningSlot)

                let afternoonSlot = CommonFreeSlot(
                    date: date,
                    startHour: 14,
                    endHour: 17,
                    duration: 180,
                    availableMembers: members
                )
                slots.append(afternoonSlot)
            } else {
                // Weekdays - evening only
                if dayOffset % 2 == 0 {
                    let eveningSlot = CommonFreeSlot(
                        date: date,
                        startHour: 19,
                        endHour: 21,
                        duration: 120,
                        availableMembers: Array(members.prefix(Int.random(in: 2...4)))
                    )
                    slots.append(eveningSlot)
                }
            }
        }

        return slots
    }

    // MARK: - Shared Events

    func fetchSharedEvents() async -> [SharedFamilyEvent] {
        let members = await fetchFamilyMembers()
        let calendar = Calendar.current

        return [
            SharedFamilyEvent(
                title: "\u{5BB6}\u{65CF}\u{3067}\u{516C}\u{5712}",
                date: calendar.date(byAdding: .day, value: 1, to: Date())!,
                startHour: 10,
                endHour: 12,
                participants: members,
                category: .outing,
                location: "\u{4EE3}\u{3005}\u{6728}\u{516C}\u{5712}"
            ),
            SharedFamilyEvent(
                title: "\u{5BB6}\u{65CF}\u{30C7}\u{30A3}\u{30CA}\u{30FC}",
                date: calendar.date(byAdding: .day, value: 2, to: Date())!,
                startHour: 18,
                endHour: 20,
                participants: members,
                category: .meal,
                location: "\u{81EA}\u{5B85}"
            ),
            SharedFamilyEvent(
                title: "\u{592A}\u{90CE}\u{306E}\u{30B5}\u{30C3}\u{30AB}\u{30FC}\u{8A66}\u{5408}",
                date: calendar.date(byAdding: .day, value: 3, to: Date())!,
                startHour: 14,
                endHour: 16,
                participants: Array(members.prefix(3)),
                category: .exercise,
                location: "\u{5E02}\u{6C11}\u{30B0}\u{30E9}\u{30A6}\u{30F3}\u{30C9}"
            ),
            SharedFamilyEvent(
                title: "\u{8CB7}\u{3044}\u{51FA}\u{3057}",
                date: calendar.date(byAdding: .day, value: 4, to: Date())!,
                startHour: 11,
                endHour: 13,
                participants: Array(members.prefix(2)),
                category: .errand,
                location: "\u{30B7}\u{30E7}\u{30C3}\u{30D4}\u{30F3}\u{30B0}\u{30E2}\u{30FC}\u{30EB}"
            ),
            SharedFamilyEvent(
                title: "\u{6620}\u{753B}\u{9451}\u{8CDE}\u{4F1A}",
                date: calendar.date(byAdding: .day, value: 5, to: Date())!,
                startHour: 20,
                endHour: 22,
                participants: members,
                category: .family,
                location: "\u{81EA}\u{5B85}"
            ),
        ]
    }

    // MARK: - Shared Tasks

    func fetchSharedTasks() async -> [SharedTask] {
        let members = await fetchFamilyMembers()
        let calendar = Calendar.current

        return [
            SharedTask(title: "\u{725B}\u{4E73}\u{3092}\u{8CB7}\u{3046}", assignee: members[1], dueDate: Date(), isCompleted: false, category: .shopping),
            SharedTask(title: "\u{6D17}\u{6FEF}\u{7269}\u{3092}\u{305F}\u{305F}\u{3080}", assignee: members[0], dueDate: Date(), isCompleted: true, category: .housework),
            SharedTask(title: "\u{904A}\u{5712}\u{5730}\u{306E}\u{304A}\u{5F01}\u{5F53}\u{6E96}\u{5099}", assignee: members[1], dueDate: calendar.date(byAdding: .day, value: 1, to: Date()), isCompleted: false, category: .preparation),
            SharedTask(title: "\u{592A}\u{90CE}\u{306E}\u{30B5}\u{30C3}\u{30AB}\u{30FC}\u{30E6}\u{30CB}\u{30D5}\u{30A9}\u{30FC}\u{30E0}\u{6D17}\u{6FEF}", assignee: members[0], dueDate: calendar.date(byAdding: .day, value: 2, to: Date()), isCompleted: false, category: .preparation),
            SharedTask(title: "\u{98DF}\u{6750}\u{306E}\u{8CB7}\u{3044}\u{51FA}\u{3057}", assignee: nil, dueDate: calendar.date(byAdding: .day, value: 1, to: Date()), isCompleted: false, category: .shopping),
            SharedTask(title: "\u{82B1}\u{5B50}\u{306E}\u{30D4}\u{30A2}\u{30CE}\u{9001}\u{8FCE}", assignee: members[0], dueDate: calendar.date(byAdding: .day, value: 3, to: Date()), isCompleted: false, category: .other),
        ]
    }

    // MARK: - Event Suggestions

    func fetchEventSuggestions() async -> [EventSuggestion] {
        let freeSlots = await findCommonFreeSlots(days: 7)
        guard freeSlots.count >= 2 else { return [] }

        return [
            EventSuggestion(
                title: "\u{5BB6}\u{65CF}\u{3067}\u{30D4}\u{30AF}\u{30CB}\u{30C3}\u{30AF}",
                icon: "sun.max.fill",
                suggestedSlot: freeSlots[0],
                estimatedDuration: 120
            ),
            EventSuggestion(
                title: "\u{30DC}\u{30FC}\u{30C9}\u{30B2}\u{30FC}\u{30E0}\u{30CA}\u{30A4}\u{30C8}",
                icon: "dice.fill",
                suggestedSlot: freeSlots.count > 1 ? freeSlots[1] : freeSlots[0],
                estimatedDuration: 90
            ),
        ]
    }

    // MARK: - Location Notifications

    func fetchRecentLocationNotifications() async -> [LocationNotification] {
        let members = await fetchFamilyMembers()
        let calendar = Calendar.current

        return [
            LocationNotification(
                member: members[0],
                location: "\u{6700}\u{5BC4}\u{308A}\u{99C5}",
                message: "\u{30D1}\u{30D1}\u{304C}\u{99C5}\u{306B}\u{5230}\u{7740}\u{3057}\u{307E}\u{3057}\u{305F}",
                timestamp: calendar.date(byAdding: .minute, value: -15, to: Date())!
            ),
            LocationNotification(
                member: members[2],
                location: "\u{5B66}\u{6821}",
                message: "\u{592A}\u{90CE}\u{304C}\u{5B66}\u{6821}\u{3092}\u{51FA}\u{307E}\u{3057}\u{305F}",
                timestamp: calendar.date(byAdding: .minute, value: -45, to: Date())!
            ),
        ]
    }

    // MARK: - Weekly Stats

    func fetchWeeklyStats() async -> WeeklyFamilyStats {
        WeeklyFamilyStats(
            totalFamilyEvents: 8,
            sharedHours: 14.5,
            completedTasks: 12,
            pendingTasks: 6,
            freeSlots: 5
        )
    }

    // MARK: - Private

    private func generateSlots(for member: FamilyMember) -> [TimeSlot] {
        var slots: [TimeSlot] = []

        switch member.name {
        case "\u{30D1}\u{30D1}":
            slots = [
                TimeSlot(startHour: 9, endHour: 12, availability: .busy, eventTitle: "\u{4F1A}\u{8B70}"),
                TimeSlot(startHour: 12, endHour: 13, availability: .free, eventTitle: nil),
                TimeSlot(startHour: 13, endHour: 17, availability: .busy, eventTitle: "\u{4ED5}\u{4E8B}"),
                TimeSlot(startHour: 17, endHour: 18, availability: .tentative, eventTitle: "\u{6B8B}\u{696D}\u{304B}\u{3082}"),
                TimeSlot(startHour: 18, endHour: 21, availability: .free, eventTitle: nil),
            ]
        case "\u{30DE}\u{30DE}":
            slots = [
                TimeSlot(startHour: 9, endHour: 11, availability: .busy, eventTitle: "\u{30D1}\u{30FC}\u{30C8}"),
                TimeSlot(startHour: 11, endHour: 14, availability: .free, eventTitle: nil),
                TimeSlot(startHour: 14, endHour: 15, availability: .busy, eventTitle: "\u{82B1}\u{5B50}\u{9001}\u{8FCE}"),
                TimeSlot(startHour: 15, endHour: 17, availability: .free, eventTitle: nil),
                TimeSlot(startHour: 17, endHour: 21, availability: .free, eventTitle: nil),
            ]
        case "\u{592A}\u{90CE}":
            slots = [
                TimeSlot(startHour: 8, endHour: 15, availability: .busy, eventTitle: "\u{5B66}\u{6821}"),
                TimeSlot(startHour: 15, endHour: 17, availability: .busy, eventTitle: "\u{30B5}\u{30C3}\u{30AB}\u{30FC}"),
                TimeSlot(startHour: 17, endHour: 21, availability: .free, eventTitle: nil),
            ]
        case "\u{82B1}\u{5B50}":
            slots = [
                TimeSlot(startHour: 8, endHour: 14, availability: .busy, eventTitle: "\u{5B66}\u{6821}"),
                TimeSlot(startHour: 14, endHour: 15, availability: .tentative, eventTitle: "\u{30D4}\u{30A2}\u{30CE}"),
                TimeSlot(startHour: 15, endHour: 21, availability: .free, eventTitle: nil),
            ]
        default:
            break
        }

        return slots
    }
}
