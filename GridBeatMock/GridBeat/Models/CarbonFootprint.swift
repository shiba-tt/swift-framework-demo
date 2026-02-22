import Foundation
import SwiftUI

// MARK: - Carbon Footprint Record

struct CarbonRecord: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let evChargingKg: Double
    let hvacKg: Double
    let otherKg: Double

    var totalKg: Double {
        evChargingKg + hvacKg + otherKg
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var dayOfWeekText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Carbon Day Rating

enum CarbonDayRating: Sendable {
    case green
    case yellow
    case red

    var color: Color {
        switch self {
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        }
    }

    var label: String {
        switch self {
        case .green: return "Good"
        case .yellow: return "Fair"
        case .red: return "Poor"
        }
    }

    static func from(totalKg: Double) -> CarbonDayRating {
        if totalKg < 1.5 {
            return .green
        } else if totalKg < 3.0 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Carbon Calendar Day

struct CarbonCalendarDay: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let totalKg: Double
    let rating: CarbonDayRating

    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Monthly Summary

struct MonthlyCarbonSummary: Identifiable, Sendable {
    let id = UUID()
    let month: Date
    let greenDays: Int
    let yellowDays: Int
    let redDays: Int
    let totalCO2Kg: Double
    let cleanChargeRate: Double
    let costSavings: Double

    var totalDays: Int {
        greenDays + yellowDays + redDays
    }

    var greenRate: Double {
        guard totalDays > 0 else { return 0 }
        return Double(greenDays) / Double(totalDays) * 100
    }

    var monthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy\u{5E74}M\u{6708}"
        return formatter.string(from: month)
    }
}

// MARK: - Annual Summary

struct AnnualCarbonSummary: Sendable {
    let year: Int
    let totalCO2ReductionKg: Double
    let treesEquivalent: Int
    let totalCostSavings: Double
    let cleanChargeRate: Double
    let greenDays: Int
    let totalDays: Int
    let communityRank: Double

    var greenDayRate: Double {
        guard totalDays > 0 else { return 0 }
        return Double(greenDays) / Double(totalDays) * 100
    }
}

// MARK: - Action Suggestion

struct ActionSuggestion: Identifiable, Sendable {
    let id = UUID()
    let message: String
    let actionLabel: String
    let startTime: Date
    let cleanFraction: Double

    var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }
}
