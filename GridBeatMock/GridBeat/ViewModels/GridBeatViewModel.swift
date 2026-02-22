import Foundation
import SwiftUI

@MainActor
@Observable
final class GridBeatViewModel {
    // MARK: - Published State

    private(set) var gridOverview: GridOverview?
    private(set) var todayRecord: CarbonRecord?
    private(set) var carbonHistory: [CarbonRecord] = []
    private(set) var calendarDays: [CarbonCalendarDay] = []
    private(set) var monthlySummary: MonthlyCarbonSummary?
    private(set) var annualSummary: AnnualCarbonSummary?
    private(set) var actionSuggestions: [ActionSuggestion] = []
    private(set) var deviceBreakdown: [DeviceCarbonBreakdown] = []
    private(set) var isLoading = false

    // MARK: - Computed

    var todayTotalKg: Double {
        todayRecord?.totalKg ?? 0
    }

    var averageDailyKg: Double {
        guard !carbonHistory.isEmpty else { return 0 }
        let total = carbonHistory.reduce(0) { $0 + $1.totalKg }
        return total / Double(carbonHistory.count)
    }

    var comparedToAverageText: String {
        guard averageDailyKg > 0 else { return "" }
        let diff = ((todayTotalKg - averageDailyKg) / averageDailyKg) * 100
        if diff < 0 {
            return String(format: "(\u{5E73}\u{5747}\u{6BD4} %.0f%%)", diff)
        } else {
            return String(format: "(\u{5E73}\u{5747}\u{6BD4} +%.0f%%)", diff)
        }
    }

    var greenDaysCount: Int {
        calendarDays.filter { $0.rating == .green }.count
    }

    var yellowDaysCount: Int {
        calendarDays.filter { $0.rating == .yellow }.count
    }

    var redDaysCount: Int {
        calendarDays.filter { $0.rating == .red }.count
    }

    var greenDayRate: Double {
        guard !calendarDays.isEmpty else { return 0 }
        return Double(greenDaysCount) / Double(calendarDays.count) * 100
    }

    // MARK: - Load Data

    func loadAllData() async {
        isLoading = true

        let manager = GridBeatEnergyManager.shared

        async let overview = manager.fetchCurrentGridOverview()
        async let today = manager.fetchTodayCarbonRecord()
        async let history = manager.fetchCarbonHistory(days: 14)
        async let calendar = manager.fetchCarbonCalendar(for: Date())
        async let monthly = manager.fetchMonthlySummary(for: Date())
        async let annual = manager.fetchAnnualSummary(year: Calendar.current.component(.year, from: Date()))
        async let suggestions = manager.fetchActionSuggestions()
        async let breakdown = manager.fetchDeviceBreakdown()

        gridOverview = await overview
        todayRecord = await today
        carbonHistory = await history
        calendarDays = await calendar
        monthlySummary = await monthly
        annualSummary = await annual
        actionSuggestions = await suggestions
        deviceBreakdown = await breakdown

        // Save widget data
        if let grid = gridOverview {
            manager.saveWidgetData(
                cleanPercentage: grid.currentCleanPercentage,
                todayCO2: todayTotalKg,
                greenDays: greenDaysCount
            )
        }

        isLoading = false
    }
}
