import Foundation
import EventKit
import SwiftUI

/// EventKit を使った会議データの取得・分析
@MainActor
@Observable
final class MeetingEventKitManager {
    static let shared = MeetingEventKitManager()

    private let store = EKEventStore()

    private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined
    private(set) var isAuthorized = false

    private init() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = authorizationStatus == .fullAccess || authorizationStatus == .authorized
    }

    // MARK: - Authorization

    /// カレンダーアクセスの認可をリクエスト
    func requestAccess() async -> Bool {
        do {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = try await store.requestFullAccessToEvents()
            } else {
                granted = try await store.requestAccess(to: .event)
            }
            isAuthorized = granted
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return granted
        } catch {
            print("[MeetingEventKitManager] 認可リクエスト失敗: \(error)")
            return false
        }
    }

    // MARK: - Fetch Meetings

    /// 指定期間の会議イベントを取得
    func fetchMeetings(from startDate: Date, to endDate: Date) async -> [MeetingEvent] {
        guard isAuthorized else { return [] }

        let predicate = store.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let ekEvents = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.compareStartDate(with: $1) == .orderedAscending }

        return ekEvents.map { event in
            MeetingEvent(
                id: event.eventIdentifier,
                title: event.title ?? "無題",
                startDate: event.startDate,
                endDate: event.endDate,
                attendeeCount: max(1, event.attendees?.count ?? 1),
                isRecurring: event.hasRecurrenceRules,
                calendarColor: mapCalendarColor(event.calendar.cgColor),
                organizer: event.organizer?.name,
                location: event.location
            )
        }
    }

    /// 指定日の会議を取得
    func fetchMeetings(for date: Date) async -> [MeetingEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return await fetchMeetings(from: startOfDay, to: endOfDay)
    }

    /// 今週の会議を取得
    func fetchThisWeekMeetings() async -> [MeetingEvent] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }
        return await fetchMeetings(from: weekStart, to: weekEnd)
    }

    /// 今月の会議を取得
    func fetchThisMonthMeetings() async -> [MeetingEvent] {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: Date())?.start,
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }
        return await fetchMeetings(from: monthStart, to: monthEnd)
    }

    // MARK: - Private

    private func mapCalendarColor(_ cgColor: CGColor) -> Color {
        guard let components = cgColor.components, components.count >= 3 else {
            return .blue
        }
        return Color(
            red: components[0],
            green: components[1],
            blue: components[2]
        )
    }
}
