import Foundation

@MainActor
@Observable
final class LightLifeViewModel {
    private(set) var isRecording = false
    private(set) var isAuthorized = false
    private(set) var currentSample: LightSample?
    private(set) var todayProfile: CircadianProfile?
    private(set) var todayReport: DailyLightReport?
    private(set) var weeklyReports: [DailyLightReport] = []
    private(set) var weeklyTrend: WeeklyTrend?

    private let lightManager = LightSensorManager.shared
    private let locationManager = LocationPatternManager.shared

    init() {
        generateDemoData()
    }

    func requestAuthorization() {
        isAuthorized = true
    }

    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            currentSample = lightManager.generateRealtimeSample()
        }
    }

    func refresh() {
        currentSample = lightManager.generateRealtimeSample()
        generateDemoData()
    }

    // MARK: - Private

    private func generateDemoData() {
        let calendar = Calendar.current
        var reports: [DailyLightReport] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let report = generateDailyReport(for: date)
            reports.append(report)
        }

        weeklyReports = reports
        todayReport = reports.last
        todayProfile = reports.last?.profile
        weeklyTrend = WeeklyTrend(reports: reports)
        currentSample = lightManager.generateRealtimeSample()
    }

    private func generateDailyReport(for date: Date) -> DailyLightReport {
        let hourlyLux = lightManager.generateNormalLightPattern(for: date)
        let hourlyColorTemp = lightManager.generateColorTempPattern()
        let rhythmScore = lightManager.calculateRhythmScore(hourlyLux: hourlyLux)

        let calendar = Calendar.current
        let wakeHour = Int.random(in: 6...8)
        let wakeMinute = Int.random(in: 0...59)
        let sleepHour = Int.random(in: 22...24)
        let sleepMinute = Int.random(in: 0...59)

        let wakeTime = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: date) ?? date
        let sleepTime = calendar.date(bySettingHour: sleepHour % 24, minute: sleepMinute, second: 0, of: date) ?? date

        let profile = CircadianProfile(
            date: date,
            hourlyLux: hourlyLux,
            hourlyColorTemp: hourlyColorTemp,
            rhythmScore: rhythmScore,
            estimatedWakeTime: wakeTime,
            estimatedSleepTime: sleepTime
        )

        let locationSummary = locationManager.generateLocationSummary()
        let screenUsage = locationManager.generateScreenUsage()
        let insights = generateInsights(profile: profile, location: locationSummary, screen: screenUsage)

        return DailyLightReport(
            date: date,
            profile: profile,
            locationSummary: locationSummary,
            screenUsage: screenUsage,
            insights: insights
        )
    }

    private func generateInsights(
        profile: CircadianProfile,
        location: LocationSummary,
        screen: ScreenUsageSummary
    ) -> [Insight] {
        var insights: [Insight] = []

        if profile.daytimeAverageLux > 500 {
            insights.append(Insight(
                type: .positive,
                title: "十分な日光曝露",
                description: "日中の平均照度が\(Int(profile.daytimeAverageLux))luxと良好です。概日リズムの維持に効果的です。"
            ))
        } else {
            insights.append(Insight(
                type: .warning,
                title: "日光曝露不足",
                description: "日中の平均照度が\(Int(profile.daytimeAverageLux))luxと低めです。外出や窓際での活動を増やしましょう。"
            ))
        }

        if profile.nighttimeAverageLux > 30 {
            insights.append(Insight(
                type: .warning,
                title: "夜間の光が多い",
                description: "夜間の照度が\(Int(profile.nighttimeAverageLux))luxです。就寝前は照明を暗くすることを推奨します。"
            ))
        }

        if profile.blueLightExposureLevel == .high {
            insights.append(Insight(
                type: .warning,
                title: "ブルーライト曝露",
                description: "夜間の色温度が高く、ブルーライトの影響が懸念されます。Night Shift の利用を検討してください。"
            ))
        }

        if location.timeOutdoors > 2 * 3600 {
            insights.append(Insight(
                type: .positive,
                title: "屋外活動が充実",
                description: "本日は\(Int(location.timeOutdoors / 3600))時間以上屋外で過ごしました。自然光の曝露は体内時計の調整に有益です。"
            ))
        }

        if screen.nightScreenTime > 60 * 60 {
            insights.append(Insight(
                type: .warning,
                title: "夜間のスクリーン使用",
                description: "22時以降に\(Int(screen.nightScreenTime / 60))分の画面使用が検出されました。入眠の質に影響する可能性があります。"
            ))
        }

        if profile.rhythmScore >= 80 {
            insights.append(Insight(
                type: .positive,
                title: "概日リズムが安定",
                description: "光環境のリズムスコアが\(profile.rhythmScore)と安定しています。この生活パターンを維持しましょう。"
            ))
        }

        return insights
    }
}
