import Foundation

/// 時間別天気予報（WeatherKit HourWeather のモック）
struct HourlyWeather: Identifiable, Sendable {
    let id = UUID()
    let hour: Int
    let temperature: Double
    let condition: WeatherConditionType
    let precipitationChance: Double
    let uvIndex: Int
    let windSpeed: Double

    var hourText: String {
        String(format: "%02d:00", hour)
    }

    var temperatureText: String {
        String(format: "%.0f°", temperature)
    }

    /// 1日の天気変化を生成
    static func generateMockForecast(base: WeatherSnapshot) -> [HourlyWeather] {
        (6...22).map { hour in
            let tempVariation: Double
            switch hour {
            case 6...9:   tempVariation = -3.0 + Double(hour - 6) * 1.0
            case 10...14: tempVariation = Double(hour - 9) * 1.2
            case 15...18: tempVariation = 6.0 - Double(hour - 14) * 1.5
            default:      tempVariation = -2.0 - Double(hour - 18) * 0.8
            }

            let conditions: [WeatherConditionType]
            if base.precipitationChance > 0.6 {
                conditions = hour >= 12 && hour <= 16
                    ? [.rain, .rain, .cloudy]
                    : [.cloudy, .partlyCloudy, .rain]
            } else {
                conditions = [base.condition, base.condition, .partlyCloudy]
            }

            return HourlyWeather(
                hour: hour,
                temperature: base.temperature + tempVariation,
                condition: conditions.randomElement()!,
                precipitationChance: max(0, min(1, base.precipitationChance + Double.random(in: -0.2...0.2))),
                uvIndex: hour >= 10 && hour <= 15 ? base.uvIndex : max(1, base.uvIndex - 3),
                windSpeed: base.windSpeed + Double.random(in: -1.5...1.5)
            )
        }
    }
}
