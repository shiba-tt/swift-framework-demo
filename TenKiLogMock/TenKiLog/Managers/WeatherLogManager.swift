import Foundation

@MainActor
@Observable
final class WeatherLogManager {
    static let shared = WeatherLogManager()

    // MARK: - State

    private(set) var isLoading = false
    private(set) var logs: [WeatherLog] = []
    private(set) var correlations: [WeatherCorrelation] = []

    private init() {
        generateSampleData()
        generateCorrelations()
    }

    // MARK: - Data Fetching

    func refreshLogs() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(1))
    }

    // MARK: - Log Operations

    func logForDate(_ date: Date) -> WeatherLog? {
        let calendar = Calendar.current
        return logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func logsForMonth(year: Int, month: Int) -> [WeatherLog] {
        let calendar = Calendar.current
        return logs.filter {
            let components = calendar.dateComponents([.year, .month], from: $0.date)
            return components.year == year && components.month == month
        }
    }

    func statsSummary() -> WeatherStatsSummary {
        let clearDays = logs.filter { $0.condition == .clear || $0.condition == .partlyCloudy }.count
        let rainyDays = logs.filter { $0.condition == .rain || $0.condition == .heavyRain || $0.condition == .thunderstorm }.count
        let snowDays = logs.filter { $0.condition == .snow }.count
        let hottestDay = logs.max(by: { $0.temperatureHigh < $1.temperatureHigh })
        let coldestDay = logs.min(by: { $0.temperatureLow < $1.temperatureLow })
        let avgTemp = logs.isEmpty ? 0 : logs.reduce(0.0) { $0 + ($1.temperatureHigh + $1.temperatureLow) / 2.0 } / Double(logs.count)
        let totalPrecip = logs.reduce(0.0) { $0 + $1.precipitation }
        let moodLogs = logs.compactMap { $0.mood }
        let avgMood = moodLogs.isEmpty ? 0 : Double(moodLogs.reduce(0) { $0 + $1.score }) / Double(moodLogs.count)

        return WeatherStatsSummary(
            totalDays: logs.count,
            clearDays: clearDays,
            rainyDays: rainyDays,
            snowDays: snowDays,
            hottestDay: hottestDay,
            coldestDay: coldestDay,
            avgTemperature: avgTemp,
            totalPrecipitation: totalPrecip,
            avgMoodScore: avgMood
        )
    }

    // MARK: - One Year Ago

    func oneYearAgoLog() -> WeatherLog? {
        let calendar = Calendar.current
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) else { return nil }
        return logForDate(oneYearAgo)
    }

    // MARK: - Sample Data

    private func generateSampleData() {
        let calendar = Calendar.current
        let today = Date()
        var generatedLogs: [WeatherLog] = []

        let conditions: [WeatherConditionType] = [
            .clear, .clear, .partlyCloudy, .cloudy, .rain,
            .clear, .partlyCloudy, .clear, .rain, .cloudy,
            .clear, .clear, .fog, .cloudy, .partlyCloudy,
            .rain, .heavyRain, .cloudy, .partlyCloudy, .clear,
            .clear, .windy, .partlyCloudy, .clear, .cloudy,
            .rain, .clear, .clear, .partlyCloudy, .snow,
        ]

        let moods: [MoodType?] = [
            .veryGood, .good, .good, .neutral, .bad,
            .veryGood, .good, .veryGood, .bad, .neutral,
            .good, .veryGood, nil, .neutral, .good,
            .bad, .veryBad, .neutral, .good, .veryGood,
            .good, .neutral, .good, .veryGood, .neutral,
            .bad, .good, .veryGood, .good, .neutral,
        ]

        let diaries: [String?] = [
            "朝ランニングが気持ちよかった", "公園で読書した", nil, "少しだるい一日", "雨で一日室内",
            "友人とBBQ", nil, "夕焼けがきれいだった", "傘を忘れた...", nil,
            "カフェで仕事", "散歩日和", "朝靄が幻想的", nil, "買い物に出かけた",
            "低気圧で頭痛", "台風接近で外出断念", nil, "回復してきた", "ピクニック日和",
            nil, "風が強くて寒い", "紅葉がきれい", "快晴ドライブ", nil,
            "雨の日の映画鑑賞", "洗濯物がよく乾いた", "最高の一日", nil, "初雪観測",
        ]

        let healthSets: [[HealthCondition]] = [
            [.none], [.none], [.none], [.fatigue], [.jointPain],
            [.none], [.none], [.none], [.none], [.fatigue],
            [.none], [.none], [.none], [.none], [.none],
            [.headache], [.headache, .jointPain], [.fatigue], [.none], [.none],
            [.none], [.none], [.allergy], [.none], [.none],
            [.jointPain], [.none], [.none], [.none], [.none],
        ]

        let comparisons: [String?] = [
            "例年より3\u{00B0}C高い", nil, nil, nil, "例年より降水量が多い",
            nil, "例年並み", nil, nil, nil,
            nil, "例年より2\u{00B0}C高い", nil, nil, nil,
            nil, "記録的な降水量", nil, nil, "例年より5\u{00B0}C高い",
            nil, nil, nil, nil, "例年並みの気温",
            nil, nil, "例年より暖かい", nil, "例年より早い初雪",
        ]

        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -(29 - i), to: today) else { continue }
            let baseTemp = 12.0 + Double.random(in: -3...8)
            let log = WeatherLog(
                id: UUID(),
                date: date,
                condition: conditions[i],
                temperatureHigh: baseTemp + Double.random(in: 3...8),
                temperatureLow: baseTemp - Double.random(in: 2...5),
                humidity: Double.random(in: 0.3...0.9),
                pressure: 1000.0 + Double.random(in: -15...20),
                windSpeed: Double.random(in: 0.5...12),
                uvIndex: Int.random(in: 1...8),
                precipitation: conditions[i] == .rain || conditions[i] == .heavyRain ? Double.random(in: 2...30) : 0,
                mood: moods[i],
                diaryNote: diaries[i],
                healthConditions: healthSets[i],
                photoCount: Int.random(in: 0...5),
                historicalComparison: comparisons[i]
            )
            generatedLogs.append(log)
        }

        logs = generatedLogs
    }

    private func generateCorrelations() {
        correlations = [
            WeatherCorrelation(
                id: UUID(),
                title: "気圧と頭痛",
                description: "気圧が1005hPa以下の日に頭痛の発生率が上昇",
                factor: "気圧低下",
                correlation: -0.72,
                icon: "gauge.with.dots.needle.33percent"
            ),
            WeatherCorrelation(
                id: UUID(),
                title: "日照と気分",
                description: "晴れの日は気分スコアが平均0.8ポイント高い",
                factor: "日照時間",
                correlation: 0.68,
                icon: "sun.max.fill"
            ),
            WeatherCorrelation(
                id: UUID(),
                title: "湿度と関節痛",
                description: "湿度70%以上で関節痛の報告が増加",
                factor: "高湿度",
                correlation: 0.55,
                icon: "humidity.fill"
            ),
            WeatherCorrelation(
                id: UUID(),
                title: "気温差と倦怠感",
                description: "日較差10\u{00B0}C以上で倦怠感を感じやすい",
                factor: "気温差",
                correlation: 0.45,
                icon: "thermometer.medium"
            ),
        ]
    }
}
