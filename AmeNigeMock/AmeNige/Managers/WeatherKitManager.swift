import Foundation
import WeatherKit
import CoreLocation

/// WeatherKit を使った気象データの取得・分析
@MainActor
@Observable
final class WeatherKitManager {
    static let shared = WeatherKitManager()

    private let weatherService = WeatherService()

    private init() {}

    // MARK: - Fetch Minute Forecast

    /// 分単位降水予報を取得
    func fetchMinuteForecast(for location: CLLocation) async throws -> [PrecipitationForecast] {
        let weather = try await weatherService.weather(
            for: location,
            including: .minute
        )

        guard let minuteForecast = weather else {
            return []
        }

        return minuteForecast.map { minute in
            PrecipitationForecast(
                date: minute.date,
                intensityMmPerHour: minute.precipitationIntensity
                    .converted(to: .millimetersPerHour).value
            )
        }
    }

    // MARK: - Fetch Hourly Forecast

    /// 時間別降水予報を取得
    func fetchHourlyForecast(
        for location: CLLocation,
        hours: Int = 12
    ) async throws -> [HourlyPrecipitation] {
        let hourly = try await weatherService.weather(
            for: location,
            including: .hourly
        )

        let now = Date()
        return hourly
            .filter { $0.date > now }
            .prefix(hours)
            .map { hour in
                HourlyPrecipitation(
                    date: hour.date,
                    precipitationChance: hour.precipitationChance,
                    precipitationAmount: hour.precipitationAmount
                        .converted(to: .millimeters).value,
                    conditionDescription: hour.condition.description,
                    conditionIcon: iconForCondition(hour.condition)
                )
            }
    }

    // MARK: - Fetch Alerts

    /// 気象アラートを取得
    func fetchAlerts(
        for location: CLLocation,
        countryCode: String = "JP"
    ) async throws -> [WeatherAlertInfo] {
        let (_, alerts) = try await weatherService.weather(
            for: location,
            including: .current, .alerts(countryCode: countryCode)
        )

        return alerts.map { alert in
            WeatherAlertInfo(
                title: alert.summary,
                severity: mapSeverity(alert.severity),
                description: alert.detailsURL?.absoluteString ?? "",
                effectiveDate: alert.metadata.issueDate,
                expiresDate: alert.metadata.expirationDate
            )
        }
    }

    // MARK: - Fetch Current Weather

    /// 現在の天気を取得（降水状況の即時判定用）
    func fetchCurrentPrecipitation(
        for location: CLLocation
    ) async throws -> PrecipitationForecast {
        let current = try await weatherService.weather(
            for: location,
            including: .current
        )

        return PrecipitationForecast(
            date: current.date,
            intensityMmPerHour: current.precipitationIntensity
                .converted(to: .millimetersPerHour).value
        )
    }

    // MARK: - Analysis

    /// 分単位予報から「晴れ間ウィンドウ」を検出
    func findDryWindows(
        in forecasts: [PrecipitationForecast],
        minimumMinutes: Int = 10
    ) -> [DryWindow] {
        var windows: [DryWindow] = []
        var windowStart: Date?

        for forecast in forecasts {
            if !forecast.isRaining && windowStart == nil {
                windowStart = forecast.date
            } else if forecast.isRaining, let start = windowStart {
                let durationMinutes = Int(forecast.date.timeIntervalSince(start) / 60)
                if durationMinutes >= minimumMinutes {
                    windows.append(DryWindow(
                        startDate: start,
                        endDate: forecast.date
                    ))
                }
                windowStart = nil
            }
        }

        // 最後まで晴れていた場合
        if let start = windowStart, let last = forecasts.last {
            let durationMinutes = Int(last.date.timeIntervalSince(start) / 60)
            if durationMinutes >= minimumMinutes {
                windows.append(DryWindow(
                    startDate: start,
                    endDate: last.date
                ))
            }
        }

        return windows
    }

    /// 外出判定を行う
    func judgeOutdoor(
        currentForecast: PrecipitationForecast,
        minuteForecasts: [PrecipitationForecast]
    ) -> OutdoorVerdict {
        guard !minuteForecasts.isEmpty else {
            return .unavailable
        }

        let dryWindows = findDryWindows(in: minuteForecasts)

        if !currentForecast.isRaining {
            // 現在降っていない → いつまで降らないか計算
            let nextRainTime = minuteForecasts
                .first { $0.isRaining && $0.date > Date() }
                .map(\.date)
            let returnBy = nextRainTime ?? minuteForecasts.last?.date ?? Date()
            return .goNow(returnBy: returnBy)
        }

        // 現在降っている場合
        let futureWindows = dryWindows.filter { $0.startDate > Date() }

        if let nextWindow = futureWindows.first {
            if nextWindow.minutesUntilStart <= 15 {
                return .waitThenGo(window: nextWindow)
            }
            return .stayIndoor(nextDryWindow: nextWindow)
        }

        return .stayIndoor(nextDryWindow: nil)
    }

    // MARK: - Private Helpers

    private func iconForCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .hot: "sun.max.fill"
        case .mostlyClear: "sun.min.fill"
        case .partlyCloudy: "cloud.sun.fill"
        case .mostlyCloudy: "cloud.fill"
        case .cloudy: "smoke.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .rain: "cloud.rain.fill"
        case .heavyRain: "cloud.heavyrain.fill"
        case .thunderstorms, .strongStorms, .isolatedThunderstorms, .scatteredThunderstorms:
            "cloud.bolt.rain.fill"
        case .snow, .heavySnow, .flurries: "cloud.snow.fill"
        case .sleet, .freezingRain, .freezingDrizzle: "cloud.sleet.fill"
        case .hail: "cloud.hail.fill"
        case .foggy: "cloud.fog.fill"
        case .haze, .smoky: "sun.haze.fill"
        case .windy, .breezy: "wind"
        case .blizzard: "wind.snow"
        default: "cloud.fill"
        }
    }

    private func mapSeverity(_ severity: WeatherSeverity) -> AlertSeverity {
        switch severity {
        case .minor: .minor
        case .moderate: .moderate
        case .severe: .severe
        case .extreme: .extreme
        default: .minor
        }
    }
}
