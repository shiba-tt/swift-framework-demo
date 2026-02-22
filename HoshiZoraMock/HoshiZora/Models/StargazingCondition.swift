import Foundation
import SwiftUI

// MARK: - MoonPhase

enum MoonPhase: String, Sendable, CaseIterable, Identifiable {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newMoon: "新月"
        case .waxingCrescent: "三日月"
        case .firstQuarter: "上弦の月"
        case .waxingGibbous: "十三夜"
        case .fullMoon: "満月"
        case .waningGibbous: "十八夜"
        case .lastQuarter: "下弦の月"
        case .waningCrescent: "二十六夜"
        }
    }

    var emoji: String {
        switch self {
        case .newMoon: "🌑"
        case .waxingCrescent: "🌒"
        case .firstQuarter: "🌓"
        case .waxingGibbous: "🌔"
        case .fullMoon: "🌕"
        case .waningGibbous: "🌖"
        case .lastQuarter: "🌗"
        case .waningCrescent: "🌘"
        }
    }

    /// 天体観測への影響度（0=最適, 1=最悪）
    var lightPollution: Double {
        switch self {
        case .newMoon: 0.0
        case .waxingCrescent, .waningCrescent: 0.15
        case .firstQuarter, .lastQuarter: 0.4
        case .waxingGibbous, .waningGibbous: 0.7
        case .fullMoon: 1.0
        }
    }
}

// MARK: - CloudLevel

enum CloudLevel: String, Sendable, Identifiable {
    case low
    case mid
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "低層雲"
        case .mid: "中層雲"
        case .high: "高層雲"
        }
    }

    var altitudeRange: String {
        switch self {
        case .low: "0〜2km"
        case .mid: "2〜6km"
        case .high: "6km以上"
        }
    }

    /// 星の見え方への影響度（低層雲のほうが影響が大きい）
    var impactWeight: Double {
        switch self {
        case .low: 1.0
        case .mid: 0.6
        case .high: 0.3
        }
    }
}

// MARK: - StargazingScore

enum StargazingScore: Sendable {
    case excellent  // 90-100
    case good       // 70-89
    case fair       // 50-69
    case poor       // 30-49
    case bad        // 0-29

    init(score: Int) {
        switch score {
        case 90...100: self = .excellent
        case 70..<90: self = .good
        case 50..<70: self = .fair
        case 30..<50: self = .poor
        default: self = .bad
        }
    }

    var displayName: String {
        switch self {
        case .excellent: "最高"
        case .good: "良好"
        case .fair: "まあまあ"
        case .poor: "悪い"
        case .bad: "不適"
        }
    }

    var stars: Int {
        switch self {
        case .excellent: 5
        case .good: 4
        case .fair: 3
        case .poor: 2
        case .bad: 1
        }
    }

    var color: Color {
        switch self {
        case .excellent: .yellow
        case .good: .green
        case .fair: .orange
        case .poor: .red
        case .bad: .gray
        }
    }

    var description: String {
        switch self {
        case .excellent: "絶好の天体観測日和！天の川も見える可能性があります。"
        case .good: "良い条件です。主要な星座はくっきり見えるでしょう。"
        case .fair: "明るい星は見えますが、暗い天体は難しいかもしれません。"
        case .poor: "雲や月明かりの影響が大きく、条件はよくありません。"
        case .bad: "天体観測には不向きです。別の夜を選びましょう。"
        }
    }
}

// MARK: - StargazingCondition

struct StargazingCondition: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let overallScore: Int
    let cloudCoverTotal: Double
    let cloudCoverLow: Double
    let cloudCoverMid: Double
    let cloudCoverHigh: Double
    let visibility: Double // km
    let humidity: Double // 0-1
    let moonPhase: MoonPhase
    let temperature: Double // 摂氏
    let windSpeed: Double // m/s
    let sunset: Date
    let sunrise: Date
    let bestTimeStart: Date
    let bestTimeEnd: Date

    init(
        id: UUID = UUID(),
        date: Date,
        overallScore: Int,
        cloudCoverTotal: Double,
        cloudCoverLow: Double,
        cloudCoverMid: Double,
        cloudCoverHigh: Double,
        visibility: Double,
        humidity: Double,
        moonPhase: MoonPhase,
        temperature: Double,
        windSpeed: Double,
        sunset: Date,
        sunrise: Date,
        bestTimeStart: Date,
        bestTimeEnd: Date
    ) {
        self.id = id
        self.date = date
        self.overallScore = overallScore
        self.cloudCoverTotal = cloudCoverTotal
        self.cloudCoverLow = cloudCoverLow
        self.cloudCoverMid = cloudCoverMid
        self.cloudCoverHigh = cloudCoverHigh
        self.visibility = visibility
        self.humidity = humidity
        self.moonPhase = moonPhase
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.sunset = sunset
        self.sunrise = sunrise
        self.bestTimeStart = bestTimeStart
        self.bestTimeEnd = bestTimeEnd
    }

    var scoreLevel: StargazingScore {
        StargazingScore(score: overallScore)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter.string(from: date)
    }

    var bestTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: bestTimeStart))〜\(formatter.string(from: bestTimeEnd))"
    }

    var temperatureText: String {
        "\(Int(temperature))°C"
    }

    var visibilityText: String {
        if visibility >= 10 {
            return "\(Int(visibility))km（非常にクリア）"
        } else if visibility >= 5 {
            return "\(Int(visibility))km（クリア）"
        } else {
            return "\(Int(visibility))km（やや霞あり）"
        }
    }
}

// MARK: - HourlyStarCondition

struct HourlyStarCondition: Identifiable, Sendable {
    let id: UUID
    let hour: Date
    let score: Int
    let cloudCover: Double
    let visibility: Double

    init(
        id: UUID = UUID(),
        hour: Date,
        score: Int,
        cloudCover: Double,
        visibility: Double
    ) {
        self.id = id
        self.hour = hour
        self.score = score
        self.cloudCover = cloudCover
        self.visibility = visibility
    }

    var hourText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH時"
        return formatter.string(from: hour)
    }

    var scoreLevel: StargazingScore {
        StargazingScore(score: score)
    }
}

// MARK: - ObservationSpot

struct ObservationSpot: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let lightPollutionLevel: Double // 0=最適, 1=最悪
    let altitude: Int // メートル
    let icon: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        latitude: Double,
        longitude: Double,
        lightPollutionLevel: Double,
        altitude: Int,
        icon: String = "mountain.2.fill"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.lightPollutionLevel = lightPollutionLevel
        self.altitude = altitude
        self.icon = icon
    }

    var lightPollutionText: String {
        switch lightPollutionLevel {
        case 0..<0.2: "極めて暗い（天の川明瞭）"
        case 0.2..<0.4: "暗い（良好な星空）"
        case 0.4..<0.6: "やや光害あり"
        case 0.6..<0.8: "光害あり"
        default: "都市部（光害大）"
        }
    }

    var lightPollutionColor: Color {
        switch lightPollutionLevel {
        case 0..<0.2: .green
        case 0.2..<0.4: .mint
        case 0.4..<0.6: .yellow
        case 0.6..<0.8: .orange
        default: .red
        }
    }
}
