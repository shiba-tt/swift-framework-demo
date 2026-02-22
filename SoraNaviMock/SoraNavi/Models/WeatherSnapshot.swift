import Foundation

/// 現在の天気状況のモックデータ
struct WeatherSnapshot: Sendable {
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let windDirection: Double
    let visibility: Double
    let uvIndex: Int
    let cloudCoverLow: Double
    let cloudCoverMid: Double
    let cloudCoverHigh: Double
    let precipitationIntensity: Double
    let condition: WeatherConditionType
    let sunriseTime: Date
    let sunsetTime: Date
    let moonPhase: Double

    var temperatureText: String {
        String(format: "%.1f°C", temperature)
    }

    var humidityText: String {
        String(format: "%.0f%%", humidity * 100)
    }

    var windSpeedText: String {
        String(format: "%.1f m/s", windSpeed)
    }

    var visibilityText: String {
        String(format: "%.1f km", visibility)
    }

    var totalCloudCover: Double {
        (cloudCoverLow + cloudCoverMid + cloudCoverHigh) / 3
    }

    var totalCloudCoverText: String {
        String(format: "%.0f%%", totalCloudCover * 100)
    }

    var moonPhaseText: String {
        switch moonPhase {
        case 0..<0.1:   return "🌑 新月"
        case 0.1..<0.25: return "🌒 三日月"
        case 0.25..<0.4: return "🌓 上弦"
        case 0.4..<0.6:  return "🌔 十三夜"
        case 0.6..<0.75: return "🌕 満月"
        case 0.75..<0.9: return "🌖 十八夜"
        default:         return "🌘 下弦"
        }
    }

    /// 金星の時間帯判定
    func currentLightingPhase(at date: Date) -> LightingPhase {
        let calendar = Calendar.current
        let sunriseMinutes = calendar.component(.hour, from: sunriseTime) * 60
            + calendar.component(.minute, from: sunriseTime)
        let sunsetMinutes = calendar.component(.hour, from: sunsetTime) * 60
            + calendar.component(.minute, from: sunsetTime)
        let nowMinutes = calendar.component(.hour, from: date) * 60
            + calendar.component(.minute, from: date)

        if abs(nowMinutes - sunriseMinutes) <= 30 || abs(nowMinutes - sunsetMinutes) <= 30 {
            return .goldenHour
        } else if nowMinutes < sunriseMinutes && sunriseMinutes - nowMinutes <= 60 {
            return .blueHour
        } else if nowMinutes > sunsetMinutes && nowMinutes - sunsetMinutes <= 60 {
            return .blueHour
        } else if nowMinutes >= sunriseMinutes && nowMinutes <= sunsetMinutes {
            return .daylight
        } else {
            return .night
        }
    }

    static let sampleClear = WeatherSnapshot(
        temperature: 22.5, humidity: 0.45, windSpeed: 3.2,
        windDirection: 225, visibility: 18.5, uvIndex: 5,
        cloudCoverLow: 0.1, cloudCoverMid: 0.2, cloudCoverHigh: 0.6,
        precipitationIntensity: 0, condition: .clear,
        sunriseTime: Calendar.current.date(bySettingHour: 5, minute: 42, second: 0, of: Date())!,
        sunsetTime: Calendar.current.date(bySettingHour: 18, minute: 15, second: 0, of: Date())!,
        moonPhase: 0.15
    )

    static let sampleCloudy = WeatherSnapshot(
        temperature: 18.0, humidity: 0.72, windSpeed: 5.8,
        windDirection: 180, visibility: 10.2, uvIndex: 2,
        cloudCoverLow: 0.7, cloudCoverMid: 0.5, cloudCoverHigh: 0.3,
        precipitationIntensity: 0, condition: .cloudy,
        sunriseTime: Calendar.current.date(bySettingHour: 5, minute: 42, second: 0, of: Date())!,
        sunsetTime: Calendar.current.date(bySettingHour: 18, minute: 15, second: 0, of: Date())!,
        moonPhase: 0.55
    )

    static let sampleRainy = WeatherSnapshot(
        temperature: 15.0, humidity: 0.88, windSpeed: 8.0,
        windDirection: 90, visibility: 5.0, uvIndex: 1,
        cloudCoverLow: 0.9, cloudCoverMid: 0.8, cloudCoverHigh: 0.4,
        precipitationIntensity: 2.5, condition: .rain,
        sunriseTime: Calendar.current.date(bySettingHour: 5, minute: 42, second: 0, of: Date())!,
        sunsetTime: Calendar.current.date(bySettingHour: 18, minute: 15, second: 0, of: Date())!,
        moonPhase: 0.8
    )
}

enum WeatherConditionType: String, Sendable {
    case clear = "晴れ"
    case partlyCloudy = "晴れ時々曇り"
    case cloudy = "曇り"
    case rain = "雨"
    case snow = "雪"
    case thunderstorm = "雷雨"

    var emoji: String {
        switch self {
        case .clear:        return "☀️"
        case .partlyCloudy: return "⛅"
        case .cloudy:       return "☁️"
        case .rain:         return "🌧️"
        case .snow:         return "❄️"
        case .thunderstorm: return "⛈️"
        }
    }

    var systemImageName: String {
        switch self {
        case .clear:        return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy:       return "cloud.fill"
        case .rain:         return "cloud.rain.fill"
        case .snow:         return "cloud.snow.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        }
    }
}

enum LightingPhase: String, Sendable {
    case goldenHour = "ゴールデンアワー"
    case blueHour = "ブルーアワー"
    case daylight = "日中"
    case night = "夜間"

    var emoji: String {
        switch self {
        case .goldenHour: return "✨"
        case .blueHour:   return "🌆"
        case .daylight:   return "☀️"
        case .night:      return "🌙"
        }
    }
}
