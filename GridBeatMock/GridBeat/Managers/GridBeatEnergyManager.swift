import Foundation
import SwiftUI

// MARK: - GridBeat Energy Manager

@MainActor
final class GridBeatEnergyManager: Sendable {
    static let shared = GridBeatEnergyManager()

    private init() {}

    // MARK: - Grid Status

    func fetchCurrentGridOverview() async -> GridOverview {
        let hourlyData = generateHourlyGridData()
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentData = hourlyData.first { $0.hour == currentHour } ?? hourlyData[0]

        let nextCleanWindow = hourlyData
            .filter { $0.hour > currentHour && $0.cleanFraction >= 0.7 }
            .first

        let nextCleanStart: Date? = nextCleanWindow.map { slot in
            Calendar.current.date(
                bySettingHour: slot.hour, minute: 0, second: 0, of: Date()
            )!
        }

        return GridOverview(
            currentCleanFraction: currentData.cleanFraction,
            currentCarbonIntensity: currentData.carbonIntensity,
            currentPricePerKWh: currentData.pricePerKWh,
            hourlyData: hourlyData,
            nextCleanWindowStart: nextCleanStart,
            nextCleanWindowCleanFraction: nextCleanWindow?.cleanFraction ?? 0
        )
    }

    // MARK: - Carbon Footprint

    func fetchTodayCarbonRecord() async -> CarbonRecord {
        CarbonRecord(
            date: Date(),
            evChargingKg: Double.random(in: 0.2...0.8),
            hvacKg: Double.random(in: 0.4...1.0),
            otherKg: Double.random(in: 0.1...0.4)
        )
    }

    func fetchCarbonHistory(days: Int) async -> [CarbonRecord] {
        let calendar = Calendar.current
        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                return nil
            }
            return CarbonRecord(
                date: date,
                evChargingKg: Double.random(in: 0.1...1.2),
                hvacKg: Double.random(in: 0.3...1.5),
                otherKg: Double.random(in: 0.05...0.5)
            )
        }.reversed()
    }

    // MARK: - Carbon Calendar

    func fetchCarbonCalendar(for month: Date) async -> [CarbonCalendarDay] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        let today = calendar.startOfDay(for: Date())

        return range.compactMap { day -> CarbonCalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) else {
                return nil
            }
            guard date <= today else { return nil }

            let totalKg = Double.random(in: 0.5...4.0)
            return CarbonCalendarDay(
                date: date,
                totalKg: totalKg,
                rating: CarbonDayRating.from(totalKg: totalKg)
            )
        }
    }

    // MARK: - Monthly Summary

    func fetchMonthlySummary(for month: Date) async -> MonthlyCarbonSummary {
        let greenDays = Int.random(in: 15...25)
        let yellowDays = Int.random(in: 3...8)
        let redDays = Int.random(in: 0...3)

        return MonthlyCarbonSummary(
            month: month,
            greenDays: greenDays,
            yellowDays: yellowDays,
            redDays: redDays,
            totalCO2Kg: Double.random(in: 30...60),
            cleanChargeRate: Double.random(in: 0.65...0.90),
            costSavings: Double.random(in: 40...120)
        )
    }

    // MARK: - Annual Summary

    func fetchAnnualSummary(year: Int) async -> AnnualCarbonSummary {
        AnnualCarbonSummary(
            year: year,
            totalCO2ReductionKg: 480,
            treesEquivalent: 24,
            totalCostSavings: 840,
            cleanChargeRate: 0.82,
            greenDays: 285,
            totalDays: 365,
            communityRank: 0.08
        )
    }

    // MARK: - Action Suggestions

    func fetchActionSuggestions() async -> [ActionSuggestion] {
        let calendar = Calendar.current
        var suggestions: [ActionSuggestion] = []

        let currentHour = calendar.component(.hour, from: Date())
        let cleanHours = [6, 7, 10, 11, 18, 19, 20, 21]
        let futureClean = cleanHours.filter { $0 > currentHour }

        if let nextClean = futureClean.first,
           let startTime = calendar.date(bySettingHour: nextClean, minute: 0, second: 0, of: Date()) {
            suggestions.append(ActionSuggestion(
                message: "\(nextClean):00 \u{304B}\u{3089}\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5EA6}\u{304C}\u{4E0A}\u{304C}\u{308A}\u{307E}\u{3059}\u{3002}EV \u{5145}\u{96FB}\u{3092}\u{4E88}\u{7D04}\u{3057}\u{307E}\u{3059}\u{304B}\u{FF1F}",
                actionLabel: "\u{4E88}\u{7D04}",
                startTime: startTime,
                cleanFraction: Double.random(in: 0.75...0.92)
            ))
        }

        if let offPeakTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) {
            suggestions.append(ActionSuggestion(
                message: "\u{6DF1}\u{591C}\u{5E2F}\u{306F}\u{96FB}\u{529B}\u{6599}\u{91D1}\u{304C}\u{6700}\u{3082}\u{5B89}\u{304F}\u{306A}\u{308A}\u{307E}\u{3059}",
                actionLabel: "\u{30B9}\u{30B1}\u{30B8}\u{30E5}\u{30FC}\u{30EB}",
                startTime: offPeakTime,
                cleanFraction: Double.random(in: 0.5...0.7)
            ))
        }

        return suggestions
    }

    // MARK: - Device Breakdown

    func fetchDeviceBreakdown() async -> [DeviceCarbonBreakdown] {
        [
            DeviceCarbonBreakdown(
                deviceName: "EV \u{5145}\u{96FB}",
                icon: "bolt.car.fill",
                carbonKg: Double.random(in: 0.2...0.8),
                color: .blue
            ),
            DeviceCarbonBreakdown(
                deviceName: "\u{30A8}\u{30A2}\u{30B3}\u{30F3}",
                icon: "thermometer.medium",
                carbonKg: Double.random(in: 0.4...1.0),
                color: .orange
            ),
            DeviceCarbonBreakdown(
                deviceName: "\u{305D}\u{306E}\u{4ED6}",
                icon: "house.fill",
                carbonKg: Double.random(in: 0.1...0.4),
                color: .gray
            ),
        ]
    }

    // MARK: - Report LoadEvent

    func reportLoadEvent(deviceID: String, powerConsumption: Double) async {
        // In a real app, this would call:
        // let event = LoadEvent(deviceIdentifier: deviceID, ...)
        // try await EnergyKit.submitLoadEvent(event, at: venueID)
    }

    // MARK: - Save Widget Data

    func saveWidgetData(cleanPercentage: Int, todayCO2: Double, greenDays: Int) {
        let data = GridBeatWidgetData(
            currentCleanPercentage: cleanPercentage,
            todayCO2Kg: todayCO2,
            greenDaysThisMonth: greenDays,
            lastUpdated: Date()
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults(suiteName: "group.com.example.gridbeat")?
                .set(encoded, forKey: "widgetData")
        }
    }

    // MARK: - Private

    private func generateHourlyGridData() -> [GridHourlyStatus] {
        // Simulates a typical daily pattern:
        // Early morning: moderate clean, low price
        // Mid-morning: high clean (solar ramp-up)
        // Afternoon peak: lower clean, high price
        // Evening: recovering clean, moderate price
        // Night: moderate clean, low price
        let cleanPattern: [Double] = [
            0.55, 0.52, 0.50, 0.48, 0.50, 0.55,  // 0-5
            0.65, 0.72, 0.78, 0.82, 0.85, 0.87,  // 6-11
            0.80, 0.72, 0.55, 0.42, 0.38, 0.45,  // 12-17
            0.60, 0.72, 0.78, 0.75, 0.68, 0.60,  // 18-23
        ]

        let pricePattern: [Double] = [
            0.08, 0.08, 0.08, 0.08, 0.08, 0.10,  // 0-5
            0.12, 0.15, 0.18, 0.20, 0.22, 0.25,  // 6-11
            0.28, 0.30, 0.32, 0.35, 0.38, 0.35,  // 12-17
            0.28, 0.22, 0.18, 0.15, 0.12, 0.10,  // 18-23
        ]

        return (0..<24).map { hour in
            let clean = cleanPattern[hour] + Double.random(in: -0.05...0.05)
            let price = pricePattern[hour] + Double.random(in: -0.02...0.02)
            let carbonIntensity = (1.0 - clean) * 500

            return GridHourlyStatus(
                hour: hour,
                cleanFraction: max(0, min(1, clean)),
                pricePerKWh: max(0.05, price),
                carbonIntensity: max(0, carbonIntensity)
            )
        }
    }
}
