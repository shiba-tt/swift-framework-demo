import Foundation

/// 訪問場所パターン分析マネージャー（モック実装）
final class LocationPatternManager: Sendable {
    static let shared = LocationPatternManager()

    private init() {}

    /// デモ用の訪問場所サマリーを生成
    func generateLocationSummary() -> LocationSummary {
        let homeHours = Double.random(in: 10...16)
        let workHours = Double.random(in: 6...9)
        let outdoorHours = Double.random(in: 0.5...3)
        let otherHours = 24 - homeHours - workHours - outdoorHours

        let entries: [LocationEntry] = [
            LocationEntry(
                category: .home,
                duration: homeHours * 3600,
                averageLux: Double.random(in: 50...200)
            ),
            LocationEntry(
                category: .work,
                duration: workHours * 3600,
                averageLux: Double.random(in: 300...600)
            ),
            LocationEntry(
                category: .outdoors,
                duration: outdoorHours * 3600,
                averageLux: Double.random(in: 2000...10000)
            ),
            LocationEntry(
                category: .gym,
                duration: max(0, otherHours * 0.3) * 3600,
                averageLux: Double.random(in: 200...500)
            ),
            LocationEntry(
                category: .shop,
                duration: max(0, otherHours * 0.2) * 3600,
                averageLux: Double.random(in: 300...800)
            ),
        ]

        return LocationSummary(
            totalLocationsVisited: Int.random(in: 2...6),
            timeAtHome: homeHours * 3600,
            timeOutdoors: outdoorHours * 3600,
            locationBreakdown: entries
        )
    }

    /// デモ用のスクリーン使用サマリーを生成
    func generateScreenUsage() -> ScreenUsageSummary {
        ScreenUsageSummary(
            totalScreenTime: Double.random(in: 3...8) * 3600,
            screenWakes: Int.random(in: 40...120),
            unlocks: Int.random(in: 30...80),
            nightScreenTime: Double.random(in: 0...90) * 60
        )
    }
}
