import Foundation

/// 時間別の撮影スコア予報
struct HourlyPhotoForecast: Identifiable, Sendable {
    let id = UUID()
    let hour: Int
    let condition: WeatherConditionType
    let sunsetScore: Double
    let landscapeScore: Double
    let portraitScore: Double
    let lightingPhase: LightingPhase
    let temperature: Double

    var hourText: String {
        String(format: "%02d:00", hour)
    }

    var bestScore: Double {
        max(sunsetScore, landscapeScore, portraitScore)
    }

    var bestScoreLabel: String {
        if sunsetScore >= landscapeScore && sunsetScore >= portraitScore {
            return "夕焼け"
        } else if landscapeScore >= portraitScore {
            return "風景"
        } else {
            return "ポートレート"
        }
    }

    static func generateMockForecast() -> [HourlyPhotoForecast] {
        let sunriseHour = 5
        let sunsetHour = 18

        return (0..<24).map { hour in
            let isGoldenHour = abs(hour - sunriseHour) <= 1 || abs(hour - sunsetHour) <= 1
            let isBlueHour = (hour == sunriseHour - 1) || (hour == sunsetHour + 1)
            let isDaytime = hour >= sunriseHour && hour <= sunsetHour
            let isNight = !isDaytime

            let condition: WeatherConditionType
            switch hour {
            case 0..<6:   condition = .clear
            case 6..<12:  condition = .partlyCloudy
            case 12..<15: condition = .cloudy
            case 15..<18: condition = .partlyCloudy
            case 18..<20: condition = .clear
            default:      condition = .clear
            }

            let sunsetScore: Double = isGoldenHour ? Double.random(in: 0.75...0.95) :
                (isDaytime ? Double.random(in: 0.2...0.5) : Double.random(in: 0.05...0.15))

            let landscapeScore: Double = isDaytime ? Double.random(in: 0.4...0.85) :
                Double.random(in: 0.1...0.3)

            let portraitScore: Double
            if isGoldenHour {
                portraitScore = Double.random(in: 0.8...0.95)
            } else if isDaytime {
                portraitScore = Double.random(in: 0.3...0.7)
            } else {
                portraitScore = Double.random(in: 0.05...0.2)
            }

            let lightingPhase: LightingPhase
            if isGoldenHour { lightingPhase = .goldenHour }
            else if isBlueHour { lightingPhase = .blueHour }
            else if isNight { lightingPhase = .night }
            else { lightingPhase = .daylight }

            let baseTemp = 22.0
            let hourOffset = isDaytime ? Double.random(in: 0...5) : Double.random(in: -5...0)

            return HourlyPhotoForecast(
                hour: hour,
                condition: condition,
                sunsetScore: sunsetScore,
                landscapeScore: landscapeScore,
                portraitScore: portraitScore,
                lightingPhase: lightingPhase,
                temperature: baseTemp + hourOffset
            )
        }
    }
}
