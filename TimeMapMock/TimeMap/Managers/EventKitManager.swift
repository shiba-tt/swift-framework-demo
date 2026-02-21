import Foundation
import EventKit
import CoreLocation

/// EventKit を使ったカレンダーイベントの管理
@MainActor
@Observable
final class EventKitManager {
    static let shared = EventKitManager()

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
            print("[EventKitManager] 認可リクエスト失敗: \(error)")
            return false
        }
    }

    // MARK: - Fetch Events

    /// 指定日のイベントを取得し、ScheduleEvent に変換
    func fetchEvents(for date: Date) async -> [ScheduleEvent] {
        guard isAuthorized else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = store.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        let ekEvents = store.events(matching: predicate)
            .sorted { $0.compareStartDate(with: $1) == .orderedAscending }

        return ekEvents.map { event in
            ScheduleEvent(
                id: event.eventIdentifier,
                title: event.title ?? "無題",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                coordinate: event.structuredLocation?.geoLocation?.coordinate,
                calendarColor: mapCalendarColor(event.calendar.cgColor),
                notes: event.notes,
                isAllDay: event.isAllDay
            )
        }
    }

    /// 指定日範囲のイベントを取得
    func fetchEvents(from startDate: Date, to endDate: Date) async -> [ScheduleEvent] {
        guard isAuthorized else { return [] }

        let predicate = store.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let ekEvents = store.events(matching: predicate)
            .sorted { $0.compareStartDate(with: $1) == .orderedAscending }

        return ekEvents.map { event in
            ScheduleEvent(
                id: event.eventIdentifier,
                title: event.title ?? "無題",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                coordinate: event.structuredLocation?.geoLocation?.coordinate,
                calendarColor: mapCalendarColor(event.calendar.cgColor),
                notes: event.notes,
                isAllDay: event.isAllDay
            )
        }
    }

    /// 仮イベントをカレンダーに追加
    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        coordinate: CLLocationCoordinate2D?
    ) async throws {
        guard isAuthorized else {
            throw EventKitError.notAuthorized
        }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents

        if let location {
            event.location = location
        }

        if let coordinate {
            let structuredLocation = EKStructuredLocation(title: location ?? "")
            structuredLocation.geoLocation = CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            event.structuredLocation = structuredLocation
        }

        try store.save(event, span: .thisEvent, commit: true)
        print("[EventKitManager] イベント追加: \(title)")
    }

    // MARK: - Private

    /// CGColor からカレンダーカラーへのマッピング
    private func mapCalendarColor(_ cgColor: CGColor) -> CalendarColor {
        guard let components = cgColor.components, components.count >= 3 else {
            return .default
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]

        // 近似的なカラーマッチング
        if r > 0.7 && g < 0.3 && b < 0.3 { return .red }
        if r < 0.3 && g < 0.3 && b > 0.7 { return .blue }
        if r < 0.3 && g > 0.7 && b < 0.3 { return .green }
        if r > 0.7 && g > 0.5 && b < 0.3 { return .orange }
        if r > 0.5 && g < 0.3 && b > 0.5 { return .purple }
        if r > 0.7 && g > 0.7 && b < 0.3 { return .yellow }
        if r > 0.5 && g > 0.3 && b < 0.3 { return .brown }
        if r > 0.8 && g > 0.3 && b > 0.5 { return .pink }

        return .default
    }
}

/// EventKit 関連のエラー
enum EventKitError: Error, LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            "カレンダーへのアクセスが許可されていません"
        }
    }
}
