import EventKit
import Foundation

/// EventKit を用いてカレンダーデータを取得・分析するマネージャー
@MainActor
final class LifeEventKitManager {
    static let shared = LifeEventKitManager()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - アクセス許可

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            return (try? await eventStore.requestFullAccessToEvents()) ?? false
        } else {
            return (try? await eventStore.requestAccess(to: .event)) ?? false
        }
    }

    // MARK: - イベント取得

    func fetchEvents(from startDate: Date, to endDate: Date) -> [LifeEvent] {
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let ekEvents = eventStore.events(matching: predicate)
        return ekEvents.map { event in
            LifeEvent(
                id: UUID(),
                title: event.title ?? "無題",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                calendarName: event.calendar?.title ?? "不明",
                category: classifyEvent(event),
                isAllDay: event.isAllDay
            )
        }
    }

    // MARK: - On This Day

    func fetchOnThisDay() -> [OnThisDayEntry] {
        let calendar = Calendar.current
        let today = Date()
        var entries: [OnThisDayEntry] = []

        for yearsAgo in 1...5 {
            guard let pastDate = calendar.date(byAdding: .year, value: -yearsAgo, to: today),
                  let dayStart = calendar.date(
                      from: calendar.dateComponents([.year, .month, .day], from: pastDate)
                  ),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }

            let events = fetchEvents(from: dayStart, to: dayEnd)
            for event in events {
                entries.append(OnThisDayEntry(
                    id: UUID(),
                    event: event,
                    yearsAgo: yearsAgo
                ))
            }
        }

        return entries
    }

    // MARK: - 年間サマリー生成

    func generateYearSummary(year: Int) -> YearSummary {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1

        guard let yearStart = calendar.date(from: components),
              let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart) else {
            return createEmptySummary(year: year)
        }

        let events = fetchEvents(from: yearStart, to: yearEnd)
        return buildSummary(year: year, events: events)
    }

    // MARK: - カテゴリ分類

    private func classifyEvent(_ event: EKEvent) -> LifeCategory {
        let title = (event.title ?? "").lowercased()
        let calendarTitle = (event.calendar?.title ?? "").lowercased()

        if calendarTitle.contains("仕事") || calendarTitle.contains("work") ||
            title.contains("会議") || title.contains("mtg") || title.contains("meeting") {
            return .work
        } else if title.contains("ジム") || title.contains("ランニング") ||
                    title.contains("病院") || title.contains("gym") {
            return .health
        } else if title.contains("飲み") || title.contains("ランチ") ||
                    title.contains("パーティ") || title.contains("dinner") {
            return .social
        } else if title.contains("勉強") || title.contains("セミナー") ||
                    title.contains("study") || title.contains("講座") {
            return .learning
        } else if title.contains("旅行") || title.contains("フライト") ||
                    title.contains("travel") || title.contains("trip") {
            return .travel
        } else if title.contains("映画") || title.contains("ライブ") ||
                    title.contains("ゲーム") || title.contains("読書") {
            return .hobby
        }

        return .personal
    }

    // MARK: - ヘルパー

    private func buildSummary(year: Int, events: [LifeEvent]) -> YearSummary {
        let calendar = Calendar.current
        var monthCounts = Array(repeating: 0, count: 12)

        for event in events {
            let month = calendar.component(.month, from: event.startDate)
            monthCounts[month - 1] += 1
        }

        let busiestMonthIndex = monthCounts.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0

        var categoryMap: [LifeCategory: (count: Int, hours: Double)] = [:]
        for event in events {
            let existing = categoryMap[event.category] ?? (0, 0)
            categoryMap[event.category] = (existing.count + 1, existing.hours + event.durationHours)
        }

        let categoryStats = categoryMap.map { key, value in
            CategoryStat(
                id: UUID(),
                category: key,
                eventCount: value.count,
                totalHours: value.hours
            )
        }.sorted { $0.eventCount > $1.eventCount }

        var locationMap: [String: Int] = [:]
        for event in events {
            if let location = event.location, !location.isEmpty {
                locationMap[location, default: 0] += 1
            }
        }

        let topLocations = locationMap.map { LocationStat(id: UUID(), name: $0.key, visitCount: $0.value) }
            .sorted { $0.visitCount > $1.visitCount }
            .prefix(5)

        let totalHours = events.reduce(0.0) { $0 + $1.durationHours }

        return YearSummary(
            id: UUID(),
            year: year,
            totalEvents: events.count,
            busiestMonth: busiestMonthIndex + 1,
            busiestMonthEventCount: monthCounts[busiestMonthIndex],
            totalHours: totalHours,
            categoryBreakdown: categoryStats,
            topLocations: Array(topLocations),
            monthlyEventCounts: monthCounts
        )
    }

    private func createEmptySummary(year: Int) -> YearSummary {
        YearSummary(
            id: UUID(),
            year: year,
            totalEvents: 0,
            busiestMonth: 1,
            busiestMonthEventCount: 0,
            totalHours: 0,
            categoryBreakdown: [],
            topLocations: [],
            monthlyEventCounts: Array(repeating: 0, count: 12)
        )
    }

    // MARK: - ウィジェットデータ永続化

    func persistWidgetData(_ data: WidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        let defaults = UserDefaults(suiteName: "group.com.example.liferewind")
        defaults?.set(encoded, forKey: "widgetData")
    }
}
