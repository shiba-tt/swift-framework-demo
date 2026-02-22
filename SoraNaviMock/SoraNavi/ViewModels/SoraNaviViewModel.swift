import Foundation

/// SoraNavi のメイン ViewModel
@MainActor
@Observable
final class SoraNaviViewModel {
    private let analyzer = WeatherAnalyzer.shared

    // MARK: - UI State

    var selectedTab: AppTab = .conditions
    var selectedConditionType: PhotoConditionType?

    enum AppTab: String, CaseIterable, Sendable {
        case conditions = "条件"
        case forecast = "予報"
        case spots = "スポット"

        var systemImageName: String {
            switch self {
            case .conditions: return "camera.aperture"
            case .forecast:   return "chart.bar.fill"
            case .spots:      return "map.fill"
            }
        }
    }

    // MARK: - Computed Properties

    var currentWeather: WeatherSnapshot { analyzer.currentWeather }
    var conditions: [PhotoCondition] { analyzer.conditions }
    var hourlyForecast: [HourlyPhotoForecast] { analyzer.hourlyForecast }
    var spots: [PhotoSpot] { analyzer.spots }
    var isLoading: Bool { analyzer.isLoading }
    var lastUpdated: Date? { analyzer.lastUpdated }
    var locationName: String { analyzer.locationName }

    var lastUpdatedText: String {
        guard let date = lastUpdated else { return "未取得" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var currentLightingPhase: LightingPhase {
        currentWeather.currentLightingPhase(at: Date())
    }

    var topConditions: [PhotoCondition] {
        Array(conditions.prefix(3))
    }

    var bestTimeToday: String {
        guard let best = hourlyForecast.max(by: { $0.bestScore < $1.bestScore }) else {
            return "データなし"
        }
        return "\(best.hourText) (\(best.bestScoreLabel))"
    }

    // MARK: - Actions

    func loadData() async {
        await analyzer.fetchWeatherData()
    }

    func refresh() async {
        await analyzer.fetchWeatherData()
    }

    func spotsForCondition(_ type: PhotoConditionType) -> [PhotoSpot] {
        analyzer.recommendedSpots(for: type)
    }
}
