import Foundation
import EnergyKit

/// EnergyKit を使った電力グリッドデータの取得・管理
@MainActor
@Observable
final class EnergyKitManager {
    static let shared = EnergyKitManager()

    /// ベニュー（HomeKit Home）の選択状態
    private(set) var selectedVenue: EnergyVenue?

    /// ベニューが設定済みかどうか
    var isVenueConfigured: Bool {
        selectedVenue != nil
    }

    private init() {}

    // MARK: - Venue Setup

    /// ベニュー選択画面に必要なデータを返す
    /// （実際のアプリでは EnergyVenueSelector を使用）
    func configureVenue(_ venue: EnergyVenue) {
        selectedVenue = venue
    }

    // MARK: - Fetch Grid Forecast

    /// 今日のグリッド予測を取得
    func fetchGridForecast() async throws -> [GridForecast] {
        guard let venue = selectedVenue else {
            throw EnergyKitError.venueNotConfigured
        }

        let query = ElectricityGuidanceQuery(venue: venue)
        var forecasts: [GridForecast] = []

        for try await guidance in query.guidances {
            let forecast = GridForecast(
                date: guidance.startDate,
                cleanEnergyFraction: guidance.cleanEnergyFraction,
                guidanceLevel: mapGuidanceLevel(guidance.level)
            )
            forecasts.append(forecast)
        }

        return forecasts.sorted { $0.date < $1.date }
    }

    /// インサイトデータを取得
    func fetchInsights() async throws -> (totalCleanEnergy: Double, totalCO2Avoided: Double) {
        guard let venue = selectedVenue else {
            throw EnergyKitError.venueNotConfigured
        }

        let query = ElectricityInsightQuery(venue: venue)
        var totalClean: Double = 0
        var totalCO2: Double = 0

        for try await insight in query.insights {
            totalClean += insight.cleanEnergyFraction
            totalCO2 += insight.carbonIntensity
        }

        return (totalClean, totalCO2)
    }

    /// LoadEvent を送信（充電開始/停止時）
    func reportLoadEvent(
        energyKWh: Double,
        duration: TimeInterval,
        isCharging: Bool
    ) async throws {
        guard let venue = selectedVenue else {
            throw EnergyKitError.venueNotConfigured
        }

        let loadEvent = LoadEvent(
            venue: venue,
            category: .electricVehicle,
            energy: Measurement(value: energyKWh, unit: .kilowattHours),
            duration: duration
        )

        try await loadEvent.send()
    }

    // MARK: - Analysis

    /// グリッド予測からクリーンウィンドウを検出
    func findCleanWindows(
        in forecasts: [GridForecast],
        minimumCleanFraction: Double = 0.6,
        minimumMinutes: Int = 30
    ) -> [CleanWindow] {
        var windows: [CleanWindow] = []
        var windowStart: Date?
        var windowForecasts: [GridForecast] = []

        for forecast in forecasts {
            if forecast.cleanEnergyFraction >= minimumCleanFraction {
                if windowStart == nil {
                    windowStart = forecast.date
                }
                windowForecasts.append(forecast)
            } else if let start = windowStart {
                let end = forecast.date
                let durationMinutes = Int(end.timeIntervalSince(start) / 60)
                if durationMinutes >= minimumMinutes {
                    let avgClean = windowForecasts.reduce(0.0) {
                        $0 + $1.cleanEnergyFraction
                    } / Double(windowForecasts.count)

                    windows.append(CleanWindow(
                        startDate: start,
                        endDate: end,
                        averageCleanFraction: avgClean
                    ))
                }
                windowStart = nil
                windowForecasts = []
            }
        }

        // 最後まで続いていた場合
        if let start = windowStart, let last = forecasts.last {
            let durationMinutes = Int(last.date.timeIntervalSince(start) / 60)
            if durationMinutes >= minimumMinutes {
                let avgClean = windowForecasts.reduce(0.0) {
                    $0 + $1.cleanEnergyFraction
                } / Double(max(1, windowForecasts.count))

                windows.append(CleanWindow(
                    startDate: start,
                    endDate: last.date,
                    averageCleanFraction: avgClean
                ))
            }
        }

        return windows
    }

    /// スマート充電プランを生成
    func generateChargePlan(
        forecasts: [GridForecast],
        targetChargeLevel: Double,
        departureDate: Date,
        currentChargeLevel: Double = 0.5
    ) -> SmartChargePlan {
        let cleanWindows = findCleanWindows(in: forecasts)

        var slots: [ChargeSlot] = []
        var previousEndDate = Date()

        for window in cleanWindows where window.startDate < departureDate {
            // 待機スロット
            if window.startDate > previousEndDate {
                slots.append(ChargeSlot(
                    startDate: previousEndDate,
                    endDate: window.startDate,
                    cleanFraction: 0,
                    action: .wait
                ))
            }

            // 充電スロット
            let effectiveEnd = min(window.endDate, departureDate)
            slots.append(ChargeSlot(
                startDate: window.startDate,
                endDate: effectiveEnd,
                cleanFraction: window.averageCleanFraction,
                action: .charge
            ))
            previousEndDate = effectiveEnd
        }

        let chargeSlots = slots.filter { $0.action == .charge }
        let avgClean = chargeSlots.isEmpty ? 0 : chargeSlots.reduce(0.0) {
            $0 + $1.cleanFraction
        } / Double(chargeSlots.count)

        return SmartChargePlan(
            slots: slots,
            departureDate: departureDate,
            targetChargeLevel: targetChargeLevel,
            estimatedPoints: Int(avgClean * 180),
            estimatedCostSaving: avgClean * 2.40,
            estimatedCO2Saving: avgClean * 1.8
        )
    }

    // MARK: - Private

    private func mapGuidanceLevel(_ level: ElectricityGuidanceLevel) -> GuidanceLevel {
        switch level {
        case .good: .good
        case .neutral: .neutral
        case .bad: .bad
        @unknown default: .neutral
        }
    }
}

/// EnergyKit 関連のエラー
enum EnergyKitError: Error, LocalizedError {
    case venueNotConfigured

    var errorDescription: String? {
        switch self {
        case .venueNotConfigured:
            "HomeKit Home が設定されていません。"
        }
    }
}
