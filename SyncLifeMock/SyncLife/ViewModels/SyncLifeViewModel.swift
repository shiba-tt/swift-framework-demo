import Foundation
import SwiftUI

@MainActor
@Observable
final class SyncLifeViewModel {
    // MARK: - State

    private(set) var familyMembers: [FamilyMember] = []
    private(set) var memberSchedules: [MemberSchedule] = []
    private(set) var commonFreeSlots: [CommonFreeSlot] = []
    private(set) var sharedEvents: [SharedFamilyEvent] = []
    private(set) var sharedTasks: [SharedTask] = []
    private(set) var eventSuggestions: [EventSuggestion] = []
    private(set) var locationNotifications: [LocationNotification] = []
    private(set) var weeklyStats: WeeklyFamilyStats?
    private(set) var isLoading = false
    private(set) var hasCalendarAccess = false

    // MARK: - Computed

    var pendingTasks: [SharedTask] {
        sharedTasks.filter { !$0.isCompleted }
    }

    var completedTasks: [SharedTask] {
        sharedTasks.filter { $0.isCompleted }
    }

    var upcomingEvents: [SharedFamilyEvent] {
        sharedEvents.sorted { $0.date < $1.date }
    }

    var nextFreeSlot: CommonFreeSlot? {
        commonFreeSlots.first
    }

    var familyName: String {
        "\u{7530}\u{4E2D}\u{5BB6}"
    }

    // MARK: - Actions

    func loadAllData() async {
        isLoading = true
        let manager = SyncLifeEventKitManager.shared

        hasCalendarAccess = await manager.requestCalendarAccess()

        async let members = manager.fetchFamilyMembers()
        async let schedules = manager.fetchMemberSchedules(for: Date())
        async let freeSlots = manager.findCommonFreeSlots(days: 7)
        async let events = manager.fetchSharedEvents()
        async let tasks = manager.fetchSharedTasks()
        async let suggestions = manager.fetchEventSuggestions()
        async let notifications = manager.fetchRecentLocationNotifications()
        async let stats = manager.fetchWeeklyStats()

        familyMembers = await members
        memberSchedules = await schedules
        commonFreeSlots = await freeSlots
        sharedEvents = await events
        sharedTasks = await tasks
        eventSuggestions = await suggestions
        locationNotifications = await notifications
        weeklyStats = await stats

        isLoading = false
    }

    func toggleTaskCompletion(_ task: SharedTask) {
        if let index = sharedTasks.firstIndex(where: { $0.id == task.id }) {
            let t = sharedTasks[index]
            sharedTasks[index] = SharedTask(
                title: t.title,
                assignee: t.assignee,
                dueDate: t.dueDate,
                isCompleted: !t.isCompleted,
                category: t.category
            )
        }
    }
}
