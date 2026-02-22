import Foundation

@MainActor
@Observable
final class TenKiLogViewModel {
    // MARK: - State

    var selectedTab: AppTab = .timeline
    var selectedDate: Date = Date()
    var showDiaryEditor = false

    private(set) var logs: [WeatherLog] { manager.logs }
    var isLoading: Bool { manager.isLoading }
    var correlations: [WeatherCorrelation] { manager.correlations }

    // MARK: - Dependencies

    private let manager = WeatherLogManager.shared

    // MARK: - Init

    init() {}

    // MARK: - Actions

    func loadData() async {
        await manager.refreshLogs()
    }

    func logForDate(_ date: Date) -> WeatherLog? {
        manager.logForDate(date)
    }

    func todayLog() -> WeatherLog? {
        manager.logForDate(Date())
    }

    func oneYearAgoLog() -> WeatherLog? {
        manager.oneYearAgoLog()
    }

    func recentLogs(count: Int = 7) -> [WeatherLog] {
        Array(manager.logs.suffix(count))
    }

    func statsSummary() -> WeatherStatsSummary {
        manager.statsSummary()
    }

    func logsForCurrentMonth() -> [WeatherLog] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let year = components.year, let month = components.month else { return [] }
        return manager.logsForMonth(year: year, month: month)
    }
}
