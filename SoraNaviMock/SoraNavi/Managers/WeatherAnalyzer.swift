import Foundation

/// WeatherKit データから撮影条件を分析するマネージャー
/// 実デバイスでは WeatherService.shared.weather(for:) を使用
@MainActor
@Observable
final class WeatherAnalyzer {
    static let shared = WeatherAnalyzer()
    private init() {}

    // MARK: - State

    private(set) var currentWeather: WeatherSnapshot = .sampleClear
    private(set) var conditions: [PhotoCondition] = []
    private(set) var hourlyForecast: [HourlyPhotoForecast] = []
    private(set) var spots: [PhotoSpot] = PhotoSpot.samples
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?
    private(set) var locationName: String = "東京都"

    // MARK: - Fetch

    func fetchWeatherData() async {
        isLoading = true

        // モック: WeatherKit API コールをシミュレーション
        try? await Task.sleep(for: .seconds(1))

        // ランダムにサンプルデータを選択
        let samples: [WeatherSnapshot] = [.sampleClear, .sampleCloudy, .sampleRainy]
        currentWeather = samples.randomElement()!

        analyzeConditions()
        hourlyForecast = HourlyPhotoForecast.generateMockForecast()
        lastUpdated = Date()
        isLoading = false
    }

    // MARK: - Analysis

    private func analyzeConditions() {
        var results: [PhotoCondition] = []

        // 夕焼けスコア
        let sunsetScore = calculateSunsetScore()
        results.append(PhotoCondition(
            type: .sunset, score: sunsetScore,
            label: sunsetScore > 0.7 ? "好条件" : (sunsetScore > 0.4 ? "まずまず" : "不向き"),
            detail: "高層雲 \(Int(currentWeather.cloudCoverHigh * 100))% / 低層雲 \(Int(currentWeather.cloudCoverLow * 100))%"
        ))

        // 朝焼けスコア
        let sunriseScore = calculateSunriseScore()
        results.append(PhotoCondition(
            type: .sunrise, score: sunriseScore,
            label: sunriseScore > 0.7 ? "好条件" : (sunriseScore > 0.4 ? "まずまず" : "不向き"),
            detail: "湿度 \(currentWeather.humidityText) / 視程 \(currentWeather.visibilityText)"
        ))

        // ゴールデンアワー
        let goldenScore = calculateGoldenHourScore()
        results.append(PhotoCondition(
            type: .goldenHour, score: goldenScore,
            label: goldenScore > 0.7 ? "最高" : (goldenScore > 0.4 ? "良い" : "雲が多い"),
            detail: "雲量 \(currentWeather.totalCloudCoverText)"
        ))

        // ブルーアワー
        let blueScore = calculateBlueHourScore()
        results.append(PhotoCondition(
            type: .blueHour, score: blueScore,
            label: blueScore > 0.7 ? "好条件" : (blueScore > 0.4 ? "まずまず" : "不向き"),
            detail: "視程 \(currentWeather.visibilityText)"
        ))

        // 虹スコア
        let rainbowScore = calculateRainbowScore()
        results.append(PhotoCondition(
            type: .rainbow, score: rainbowScore,
            label: rainbowScore > 0.5 ? "可能性あり" : "低確率",
            detail: "降水量 \(String(format: "%.1f mm/h", currentWeather.precipitationIntensity))"
        ))

        // 星空スコア
        let starScore = calculateStargazingScore()
        results.append(PhotoCondition(
            type: .stargazing, score: starScore,
            label: starScore > 0.7 ? "絶好" : (starScore > 0.4 ? "まずまず" : "不向き"),
            detail: "\(currentWeather.moonPhaseText)"
        ))

        // 風景スコア
        let landscapeScore = calculateLandscapeScore()
        results.append(PhotoCondition(
            type: .landscape, score: landscapeScore,
            label: landscapeScore > 0.7 ? "最適" : (landscapeScore > 0.4 ? "良い" : "視程不足"),
            detail: "視程 \(currentWeather.visibilityText) / 風速 \(currentWeather.windSpeedText)"
        ))

        // ポートレートスコア
        let portraitScore = calculatePortraitScore()
        results.append(PhotoCondition(
            type: .portrait, score: portraitScore,
            label: portraitScore > 0.7 ? "最適" : (portraitScore > 0.4 ? "良い" : "光が強い"),
            detail: "UV \(currentWeather.uvIndex) / 気温 \(currentWeather.temperatureText)"
        ))

        conditions = results.sorted { $0.score > $1.score }
    }

    // MARK: - Score Calculations

    /// 夕焼けスコア: 高層雲が多く低層雲が少ない = 美しい夕焼け
    private func calculateSunsetScore() -> Double {
        var score = currentWeather.cloudCoverHigh * 0.4
        score += (1.0 - currentWeather.cloudCoverLow) * 0.3
        score += min(currentWeather.visibility / 20.0, 1.0) * 0.3
        return min(1.0, max(0.0, score))
    }

    /// 朝焼けスコア: 湿度が適度で視程が良い
    private func calculateSunriseScore() -> Double {
        let humidityScore = currentWeather.humidity > 0.6 ? (1.0 - (currentWeather.humidity - 0.6) * 2.5) : 0.8
        let visibilityScore = min(currentWeather.visibility / 15.0, 1.0)
        let cloudScore = currentWeather.cloudCoverHigh * 0.5
        return min(1.0, max(0.0, humidityScore * 0.3 + visibilityScore * 0.3 + cloudScore * 0.4))
    }

    /// ゴールデンアワー: 低い雲量で暖かい光
    private func calculateGoldenHourScore() -> Double {
        let cloudPenalty = currentWeather.totalCloudCover * 0.6
        let visibilityBonus = min(currentWeather.visibility / 20.0, 1.0) * 0.4
        return min(1.0, max(0.0, 1.0 - cloudPenalty + visibilityBonus))
    }

    /// ブルーアワー: クリアな空が重要
    private func calculateBlueHourScore() -> Double {
        let clearSky = 1.0 - currentWeather.totalCloudCover
        let visibility = min(currentWeather.visibility / 15.0, 1.0)
        return min(1.0, max(0.0, clearSky * 0.6 + visibility * 0.4))
    }

    /// 虹: 雨上がり + 太陽光
    private func calculateRainbowScore() -> Double {
        guard currentWeather.precipitationIntensity > 0 else { return 0.05 }
        let lightRain = currentWeather.precipitationIntensity < 5.0 ? 0.6 : 0.3
        let partialClear = (1.0 - currentWeather.cloudCoverLow) * 0.4
        return min(1.0, max(0.0, lightRain + partialClear))
    }

    /// 星空: 低雲量 + 低湿度 + 新月
    private func calculateStargazingScore() -> Double {
        let clearSky = (1.0 - currentWeather.totalCloudCover) * 0.4
        let lowHumidity = (1.0 - currentWeather.humidity) * 0.2
        let moonScore = (1.0 - currentWeather.moonPhase) * 0.2
        let visibility = min(currentWeather.visibility / 20.0, 1.0) * 0.2
        return min(1.0, max(0.0, clearSky + lowHumidity + moonScore + visibility))
    }

    /// 風景: 高視程 + 適度な雲量
    private func calculateLandscapeScore() -> Double {
        let visibility = min(currentWeather.visibility / 15.0, 1.0) * 0.5
        let dramaticClouds = (currentWeather.cloudCoverHigh > 0.3 && currentWeather.cloudCoverLow < 0.5) ? 0.3 : 0.1
        let lowWind = (1.0 - min(currentWeather.windSpeed / 15.0, 1.0)) * 0.2
        return min(1.0, max(0.0, visibility + dramaticClouds + lowWind))
    }

    /// ポートレート: 柔らかい光 + 快適な気温
    private func calculatePortraitScore() -> Double {
        let softLight = currentWeather.cloudCoverLow > 0.3 ? 0.3 : (1.0 - Double(currentWeather.uvIndex) / 11.0) * 0.3
        let comfortTemp = (1.0 - abs(currentWeather.temperature - 22.0) / 15.0) * 0.3
        let lowWind = (1.0 - min(currentWeather.windSpeed / 10.0, 1.0)) * 0.2
        let noPrecip = currentWeather.precipitationIntensity == 0 ? 0.2 : 0.0
        return min(1.0, max(0.0, softLight + comfortTemp + lowWind + noPrecip))
    }

    // MARK: - Spot Recommendations

    func recommendedSpots(for conditionType: PhotoConditionType) -> [PhotoSpot] {
        spots.filter { $0.bestConditions.contains(conditionType) }
    }
}
