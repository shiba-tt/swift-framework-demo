import Foundation
import SwiftUI

// MARK: - WeatherCondition

enum WeatherConditionType: String, Sendable, CaseIterable, Identifiable {
    case clear
    case partlyCloudy
    case cloudy
    case rain
    case heavyRain
    case snow
    case thunderstorm
    case fog
    case windy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .clear: "晴れ"
        case .partlyCloudy: "晴れ時々曇り"
        case .cloudy: "曇り"
        case .rain: "雨"
        case .heavyRain: "大雨"
        case .snow: "雪"
        case .thunderstorm: "雷雨"
        case .fog: "霧"
        case .windy: "強風"
        }
    }

    var emoji: String {
        switch self {
        case .clear: "\u{2600}\u{FE0F}"
        case .partlyCloudy: "\u{26C5}"
        case .cloudy: "\u{2601}\u{FE0F}"
        case .rain: "\u{1F327}\u{FE0F}"
        case .heavyRain: "\u{1F327}\u{FE0F}"
        case .snow: "\u{2744}\u{FE0F}"
        case .thunderstorm: "\u{26C8}\u{FE0F}"
        case .fog: "\u{1F32B}\u{FE0F}"
        case .windy: "\u{1F4A8}"
        }
    }

    var color: Color {
        switch self {
        case .clear: .orange
        case .partlyCloudy: .yellow
        case .cloudy: .gray
        case .rain: .blue
        case .heavyRain: .indigo
        case .snow: .cyan
        case .thunderstorm: .purple
        case .fog: .gray.opacity(0.6)
        case .windy: .teal
        }
    }
}

// MARK: - MoodType

enum MoodType: String, Sendable, CaseIterable, Identifiable {
    case veryGood
    case good
    case neutral
    case bad
    case veryBad

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .veryGood: "とても良い"
        case .good: "良い"
        case .neutral: "普通"
        case .bad: "悪い"
        case .veryBad: "とても悪い"
        }
    }

    var emoji: String {
        switch self {
        case .veryGood: "\u{1F60A}"
        case .good: "\u{1F642}"
        case .neutral: "\u{1F610}"
        case .bad: "\u{1F641}"
        case .veryBad: "\u{1F622}"
        }
    }

    var color: Color {
        switch self {
        case .veryGood: .green
        case .good: .mint
        case .neutral: .gray
        case .bad: .orange
        case .veryBad: .red
        }
    }

    var score: Int {
        switch self {
        case .veryGood: 5
        case .good: 4
        case .neutral: 3
        case .bad: 2
        case .veryBad: 1
        }
    }
}

// MARK: - HealthCondition

enum HealthCondition: String, Sendable, CaseIterable, Identifiable {
    case headache
    case jointPain
    case fatigue
    case insomnia
    case allergy
    case none

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .headache: "頭痛"
        case .jointPain: "関節痛"
        case .fatigue: "倦怠感"
        case .insomnia: "不眠"
        case .allergy: "アレルギー"
        case .none: "なし"
        }
    }

    var emoji: String {
        switch self {
        case .headache: "\u{1F915}"
        case .jointPain: "\u{1F9B4}"
        case .fatigue: "\u{1F634}"
        case .insomnia: "\u{1F4A4}"
        case .allergy: "\u{1F927}"
        case .none: "\u{2705}"
        }
    }
}

// MARK: - WeatherLog

struct WeatherLog: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let condition: WeatherConditionType
    let temperatureHigh: Double
    let temperatureLow: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let uvIndex: Int
    let precipitation: Double
    let mood: MoodType?
    let diaryNote: String?
    let healthConditions: [HealthCondition]
    let photoCount: Int
    let historicalComparison: String?

    var temperatureRange: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        let high = formatter.string(from: NSNumber(value: temperatureHigh)) ?? ""
        let low = formatter.string(from: NSNumber(value: temperatureLow)) ?? ""
        return "\(low)\u{00B0}C / \(high)\u{00B0}C"
    }

    var pressureFormatted: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: pressure)) ?? "") hPa"
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter.string(from: date)
    }

    var monthDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - WeatherCorrelation

struct WeatherCorrelation: Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let factor: String
    let correlation: Double
    let icon: String

    var correlationLabel: String {
        if correlation > 0.6 { return "強い正の相関" }
        if correlation > 0.3 { return "弱い正の相関" }
        if correlation > -0.3 { return "相関なし" }
        if correlation > -0.6 { return "弱い負の相関" }
        return "強い負の相関"
    }

    var correlationColor: Color {
        if abs(correlation) > 0.6 { return .red }
        if abs(correlation) > 0.3 { return .orange }
        return .gray
    }
}

// MARK: - WeatherStatsSummary

struct WeatherStatsSummary: Sendable {
    let totalDays: Int
    let clearDays: Int
    let rainyDays: Int
    let snowDays: Int
    let hottestDay: WeatherLog?
    let coldestDay: WeatherLog?
    let avgTemperature: Double
    let totalPrecipitation: Double
    let avgMoodScore: Double
}

// MARK: - AppTab

enum AppTab: String, Sendable {
    case timeline
    case calendar
    case insights
    case stats
}
