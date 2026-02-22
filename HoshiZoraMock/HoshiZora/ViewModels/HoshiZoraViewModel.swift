import Foundation

// MARK: - AppTab

enum AppTab: String, CaseIterable, Identifiable {
    case tonight
    case forecast
    case spots

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tonight: "今夜"
        case .forecast: "星空予報"
        case .spots: "観測地"
        }
    }

    var icon: String {
        switch self {
        case .tonight: "moon.stars.fill"
        case .forecast: "calendar"
        case .spots: "map.fill"
        }
    }
}

// MARK: - HoshiZoraViewModel

@MainActor
@Observable
final class HoshiZoraViewModel {
    private let analyzer = StargazingAnalyzer.shared

    var selectedTab: AppTab = .tonight
    var isLoading: Bool { analyzer.isLoading }

    // MARK: - Computed Properties

    var tonightCondition: StargazingCondition? { analyzer.tonightCondition }
    var weeklyForecast: [StargazingCondition] { analyzer.weeklyForecast }
    var hourlyConditions: [HourlyStarCondition] { analyzer.hourlyConditions }
    var spots: [ObservationSpot] { analyzer.spots }

    var bestNightThisWeek: StargazingCondition? { analyzer.bestNightThisWeek() }
    var bestHourTonight: HourlyStarCondition? { analyzer.bestHourTonight() }
    var recommendedSpots: [ObservationSpot] { analyzer.recommendedSpots() }

    var lastUpdatedText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm 更新"
        return formatter.string(from: .now)
    }

    // MARK: - Actions

    func loadData() async {
        await analyzer.fetchStargazingData()
    }

    func refresh() async {
        await analyzer.fetchStargazingData()
    }
}
