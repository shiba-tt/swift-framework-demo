import Foundation

// MARK: - StargazingAnalyzer

@MainActor
@Observable
final class StargazingAnalyzer {
    static let shared = StargazingAnalyzer()

    private(set) var tonightCondition: StargazingCondition?
    private(set) var weeklyForecast: [StargazingCondition] = []
    private(set) var hourlyConditions: [HourlyStarCondition] = []
    private(set) var spots: [ObservationSpot] = []
    var isLoading = false

    private init() {
        spots = Self.generateSampleSpots()
    }

    // MARK: - Data Fetching

    func fetchStargazingData() async {
        isLoading = true
        defer { isLoading = false }

        // WeatherKit API 呼び出しをシミュレート
        try? await Task.sleep(for: .seconds(1))

        let calendar = Calendar.current
        let now = Date.now

        // 今夜のコンディション生成
        tonightCondition = generateCondition(for: now, calendar: calendar)

        // 10日間予報生成
        weeklyForecast = (0..<10).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
            return generateCondition(for: date, calendar: calendar)
        }

        // 今夜の時間帯別コンディション生成
        hourlyConditions = generateHourlyConditions(for: now, calendar: calendar)
    }

    // MARK: - Analysis

    func bestNightThisWeek() -> StargazingCondition? {
        weeklyForecast.max(by: { $0.overallScore < $1.overallScore })
    }

    func bestHourTonight() -> HourlyStarCondition? {
        hourlyConditions.max(by: { $0.score < $1.score })
    }

    func recommendedSpots(minScore: Int = 70) -> [ObservationSpot] {
        spots.filter { $0.lightPollutionLevel < 0.5 }
            .sorted { $0.lightPollutionLevel < $1.lightPollutionLevel }
    }

    // MARK: - Score Calculation

    func calculateScore(
        cloudCoverTotal: Double,
        cloudCoverLow: Double,
        cloudCoverMid: Double,
        cloudCoverHigh: Double,
        visibility: Double,
        humidity: Double,
        moonPhase: MoonPhase,
        windSpeed: Double
    ) -> Int {
        // 雲量スコア（40%）- 低層雲を重視
        let cloudScore = max(0, 1.0
            - cloudCoverLow * CloudLevel.low.impactWeight
            - cloudCoverMid * CloudLevel.mid.impactWeight
            - cloudCoverHigh * CloudLevel.high.impactWeight
        ) * 40.0

        // 視程スコア（20%）
        let visibilityScore: Double
        switch visibility {
        case 15...: visibilityScore = 20.0
        case 10..<15: visibilityScore = 16.0
        case 5..<10: visibilityScore = 10.0
        case 2..<5: visibilityScore = 5.0
        default: visibilityScore = 0.0
        }

        // 月光スコア（20%）
        let moonScore = (1.0 - moonPhase.lightPollution) * 20.0

        // 湿度スコア（10%）
        let humidityScore = max(0, 1.0 - humidity) * 10.0

        // 風速スコア（10%）- 穏やかな風が最適
        let windScore: Double
        switch windSpeed {
        case 0..<3: windScore = 10.0
        case 3..<7: windScore = 7.0
        case 7..<12: windScore = 4.0
        default: windScore = 1.0
        }

        let total = cloudScore + visibilityScore + moonScore + humidityScore + windScore
        return min(100, max(0, Int(total)))
    }

    // MARK: - Sample Data Generation

    private func generateCondition(for date: Date, calendar: Calendar) -> StargazingCondition {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let seed = dayOfYear * 137 + 42

        let cloudTotal = pseudoRandom(seed: seed, min: 0.0, max: 0.8)
        let cloudLow = pseudoRandom(seed: seed + 1, min: 0.0, max: cloudTotal * 0.5)
        let cloudMid = pseudoRandom(seed: seed + 2, min: 0.0, max: cloudTotal * 0.3)
        let cloudHigh = max(0, cloudTotal - cloudLow - cloudMid)
        let visibility = pseudoRandom(seed: seed + 3, min: 3.0, max: 20.0)
        let humidity = pseudoRandom(seed: seed + 4, min: 0.3, max: 0.9)
        let temperature = pseudoRandom(seed: seed + 5, min: -2.0, max: 15.0)
        let windSpeed = pseudoRandom(seed: seed + 6, min: 0.5, max: 15.0)

        let moonPhases = MoonPhase.allCases
        let moonIndex = abs(seed + 7) % moonPhases.count
        let moonPhase = moonPhases[moonIndex]

        let score = calculateScore(
            cloudCoverTotal: cloudTotal,
            cloudCoverLow: cloudLow,
            cloudCoverMid: cloudMid,
            cloudCoverHigh: cloudHigh,
            visibility: visibility,
            humidity: humidity,
            moonPhase: moonPhase,
            windSpeed: windSpeed
        )

        let sunset = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: date) ?? date
        let sunrise = calendar.date(bySettingHour: 6, minute: 15, second: 0, of: calendar.date(byAdding: .day, value: 1, to: date)!) ?? date
        let bestStart = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: date) ?? date
        let bestEnd = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: date)!) ?? date

        return StargazingCondition(
            date: date,
            overallScore: score,
            cloudCoverTotal: cloudTotal,
            cloudCoverLow: cloudLow,
            cloudCoverMid: cloudMid,
            cloudCoverHigh: cloudHigh,
            visibility: visibility,
            humidity: humidity,
            moonPhase: moonPhase,
            temperature: temperature,
            windSpeed: windSpeed,
            sunset: sunset,
            sunrise: sunrise,
            bestTimeStart: bestStart,
            bestTimeEnd: bestEnd
        )
    }

    private func generateHourlyConditions(for date: Date, calendar: Calendar) -> [HourlyStarCondition] {
        let startHour = 19 // 19時から
        let hours = 10 // 翌朝5時まで
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        return (0..<hours).map { offset in
            let hourValue = (startHour + offset) % 24
            let hour = calendar.date(bySettingHour: hourValue, minute: 0, second: 0, of: date) ?? date
            let seed = dayOfYear * 137 + offset * 31

            let cloudCover = pseudoRandom(seed: seed, min: 0.05, max: 0.7)
            let visibility = pseudoRandom(seed: seed + 1, min: 5.0, max: 20.0)

            // 深夜ほど条件が良い傾向をシミュレート
            let timeBonus: Double
            switch hourValue {
            case 22, 23, 0, 1: timeBonus = 10.0
            case 2, 3: timeBonus = 8.0
            default: timeBonus = 0.0
            }

            let baseScore = (1.0 - cloudCover) * 60.0 + min(visibility / 20.0, 1.0) * 30.0 + timeBonus
            let score = min(100, max(0, Int(baseScore)))

            return HourlyStarCondition(
                hour: hour,
                score: score,
                cloudCover: cloudCover,
                visibility: visibility
            )
        }
    }

    private static func generateSampleSpots() -> [ObservationSpot] {
        [
            ObservationSpot(name: "奥多摩湖畔", description: "都心から約2時間。湖面に映る星空が美しい穴場スポット", latitude: 35.795, longitude: 139.013, lightPollutionLevel: 0.25, altitude: 530),
            ObservationSpot(name: "堂平山天文台", description: "埼玉県ときがわ町。元国立天文台の観測所で視界が広い", latitude: 36.002, longitude: 139.198, lightPollutionLevel: 0.2, altitude: 876, icon: "building.columns.fill"),
            ObservationSpot(name: "戦場ヶ原（日光）", description: "標高約1400m。湿原の広い視界で天頂付近まで見渡せる", latitude: 36.793, longitude: 139.449, lightPollutionLevel: 0.15, altitude: 1390),
            ObservationSpot(name: "富士山五合目", description: "標高2300m。雲海の上で抜群の透明度", latitude: 35.363, longitude: 138.731, lightPollutionLevel: 0.1, altitude: 2305),
            ObservationSpot(name: "三浦半島 城ヶ島", description: "南方の水平線が開けており、南天の星座観測に最適", latitude: 35.132, longitude: 139.617, lightPollutionLevel: 0.45, altitude: 30, icon: "water.waves"),
            ObservationSpot(name: "お台場海浜公園", description: "都心部。光害は大きいが、気軽にアクセスできる", latitude: 35.629, longitude: 139.775, lightPollutionLevel: 0.85, altitude: 3, icon: "building.2.fill"),
        ]
    }

    // MARK: - Pseudo Random Helper

    private func pseudoRandom(seed: Int, min: Double, max: Double) -> Double {
        let hash = abs(seed.hashValue)
        let normalized = Double(hash % 10000) / 10000.0
        return min + normalized * (max - min)
    }
}
