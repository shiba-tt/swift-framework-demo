import Foundation

/// 天気状態の種別
enum WeatherConditionType: String, Sendable, CaseIterable {
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

/// 現在の天気データ（WeatherKit CurrentWeather のモック）
struct WeatherSnapshot: Sendable {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Double
    let windSpeed: Double
    let uvIndex: Int
    let precipitationChance: Double
    let condition: WeatherConditionType
    let isDaylight: Bool

    var temperatureText: String {
        String(format: "%.0f°C", temperature)
    }

    var apparentTemperatureText: String {
        String(format: "%.0f°C", apparentTemperature)
    }

    var humidityText: String {
        String(format: "%.0f%%", humidity * 100)
    }

    var windSpeedText: String {
        String(format: "%.1f m/s", windSpeed)
    }

    var precipitationChanceText: String {
        String(format: "%.0f%%", precipitationChance * 100)
    }

    /// 快適度スコア（0〜1）
    var comfortScore: Double {
        let tempScore: Double
        if temperature >= 18 && temperature <= 26 {
            tempScore = 1.0
        } else if temperature >= 10 && temperature < 18 {
            tempScore = 0.5 + (temperature - 10) / 16.0
        } else if temperature > 26 && temperature <= 35 {
            tempScore = 1.0 - (temperature - 26) / 18.0
        } else {
            tempScore = 0.2
        }

        let humidityScore = humidity < 0.7 ? 1.0 : max(0.2, 1.0 - (humidity - 0.7) * 3.0)
        let windScore = windSpeed < 5 ? 1.0 : max(0.3, 1.0 - (windSpeed - 5) / 15.0)

        return tempScore * 0.5 + humidityScore * 0.3 + windScore * 0.2
    }

    static let sampleSpring = WeatherSnapshot(
        temperature: 18, apparentTemperature: 17,
        humidity: 0.55, windSpeed: 3.5, uvIndex: 4,
        precipitationChance: 0.1, condition: .partlyCloudy, isDaylight: true
    )

    static let sampleSummer = WeatherSnapshot(
        temperature: 32, apparentTemperature: 36,
        humidity: 0.78, windSpeed: 2.0, uvIndex: 9,
        precipitationChance: 0.3, condition: .clear, isDaylight: true
    )

    static let sampleRainy = WeatherSnapshot(
        temperature: 22, apparentTemperature: 21,
        humidity: 0.88, windSpeed: 6.0, uvIndex: 1,
        precipitationChance: 0.85, condition: .rain, isDaylight: true
    )

    static let sampleWinter = WeatherSnapshot(
        temperature: 5, apparentTemperature: 1,
        humidity: 0.40, windSpeed: 8.0, uvIndex: 2,
        precipitationChance: 0.05, condition: .clear, isDaylight: true
    )
}
