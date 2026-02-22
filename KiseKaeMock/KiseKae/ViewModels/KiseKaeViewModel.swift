import Foundation

/// KiseKae のメイン ViewModel
@MainActor
@Observable
final class KiseKaeViewModel {
    private let engine = CoordinateEngine.shared

    // MARK: - UI State

    var selectedTab: AppTab = .coordinate

    enum AppTab: String, CaseIterable, Sendable {
        case coordinate = "コーデ"
        case forecast = "時間別"
        case closet = "クローゼット"

        var systemImageName: String {
            switch self {
            case .coordinate: return "tshirt.fill"
            case .forecast:   return "clock.fill"
            case .closet:     return "cabinet.fill"
            }
        }
    }

    // MARK: - Computed Properties

    var currentWeather: WeatherSnapshot { engine.currentWeather }
    var hourlyForecast: [HourlyWeather] { engine.hourlyForecast }
    var coordinate: Coordinate? { engine.coordinate }
    var weatherAlerts: [WeatherChangeAlert] { engine.weatherAlerts }
    var isLoading: Bool { engine.isLoading }
    var lastUpdated: Date? { engine.lastUpdated }
    var locationName: String { engine.locationName }

    var lastUpdatedText: String {
        guard let date = lastUpdated else { return "未取得" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var comfortLabel: String {
        let score = currentWeather.comfortScore
        switch score {
        case 0.8...: return "快適"
        case 0.6...: return "やや快適"
        case 0.4...: return "普通"
        default:     return "不快"
        }
    }

    var comfortScorePercent: Int {
        Int(currentWeather.comfortScore * 100)
    }

    /// カテゴリごとの全アイテム（適合度順）
    func itemsForCategory(_ category: ClothingCategory) -> [ClothingItem] {
        ClothingItem.allItems
            .filter { $0.category == category }
            .sorted { $0.suitability(for: currentWeather) > $1.suitability(for: currentWeather) }
    }

    // MARK: - Actions

    func loadData() async {
        await engine.fetchWeatherAndSuggest()
    }

    func refresh() async {
        await engine.fetchWeatherAndSuggest()
    }
}
