import Foundation
import SwiftUI

// MARK: - Grid Hourly Status

struct GridHourlyStatus: Identifiable, Sendable {
    let id = UUID()
    let hour: Int
    let cleanFraction: Double
    let pricePerKWh: Double
    let carbonIntensity: Double

    var hourText: String {
        "\(hour):00"
    }

    var cleanPercentage: Int {
        Int(cleanFraction * 100)
    }

    var cleanColor: Color {
        if cleanFraction >= 0.7 {
            return .green
        } else if cleanFraction >= 0.4 {
            return .yellow
        } else {
            return .red
        }
    }

    var priceText: String {
        String(format: "$%.2f", pricePerKWh)
    }
}

// MARK: - Grid Overview

struct GridOverview: Sendable {
    let currentCleanFraction: Double
    let currentCarbonIntensity: Double
    let currentPricePerKWh: Double
    let hourlyData: [GridHourlyStatus]
    let nextCleanWindowStart: Date?
    let nextCleanWindowCleanFraction: Double

    var currentCleanPercentage: Int {
        Int(currentCleanFraction * 100)
    }

    var statusLabel: String {
        if currentCleanFraction >= 0.7 {
            return "\u{98A8}\u{3068}\u{592A}\u{967D}\u{306E}\u{6642}\u{9593}"
        } else if currentCleanFraction >= 0.4 {
            return "\u{6DF7}\u{5408}\u{30A8}\u{30CD}\u{30EB}\u{30AE}\u30FC}"
        } else {
            return "\u{706B}\u{529B}\u{767A}\u{96FB}\u{4E2D}\u{5FC3}"
        }
    }

    var statusColor: Color {
        if currentCleanFraction >= 0.7 {
            return .green
        } else if currentCleanFraction >= 0.4 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Device Carbon Breakdown

struct DeviceCarbonBreakdown: Identifiable, Sendable {
    let id = UUID()
    let deviceName: String
    let icon: String
    let carbonKg: Double
    let color: Color

    var carbonText: String {
        String(format: "%.1f kg", carbonKg)
    }
}

// MARK: - Widget Data

struct GridBeatWidgetData: Codable, Sendable {
    let currentCleanPercentage: Int
    let todayCO2Kg: Double
    let greenDaysThisMonth: Int
    let lastUpdated: Date
}
