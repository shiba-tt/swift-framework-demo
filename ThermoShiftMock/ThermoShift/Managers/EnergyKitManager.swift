import Foundation
import EnergyKit

/// EnergyKit を使った電力グリッド・TOU 料金データの取得
@MainActor
@Observable
final class EnergyKitManager {
    static let shared = EnergyKitManager()

    private(set) var selectedVenue: EnergyVenue?

    var isVenueConfigured: Bool {
        selectedVenue != nil
    }

    private init() {}

    // MARK: - Venue Setup

    func configureVenue(_ venue: EnergyVenue) {
        selectedVenue = venue
    }

    // MARK: - Fetch Grid + Price Data

    /// 今日のグリッド料金統合データを取得
    func fetchGridPriceData() async throws -> [GridPriceData] {
        guard let venue = selectedVenue else {
            throw ThermoShiftError.venueNotConfigured
        }

        let query = ElectricityGuidanceQuery(venue: venue)
        var dataPoints: [GridPriceData] = []

        for try await guidance in query.guidances {
            let priceLevel = mapToPriceLevel(guidance.level)
            let data = GridPriceData(
                date: guidance.startDate,
                cleanFraction: guidance.cleanEnergyFraction,
                priceLevel: priceLevel,
                ratePerKWh: priceLevel.ratePerKWh
            )
            dataPoints.append(data)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    /// LoadEvent を送信（HVAC 消費電力の報告）
    func reportHVACLoadEvent(
        energyKWh: Double,
        duration: TimeInterval
    ) async throws {
        guard let venue = selectedVenue else {
            throw ThermoShiftError.venueNotConfigured
        }

        let loadEvent = LoadEvent(
            venue: venue,
            category: .hvac,
            energy: Measurement(value: energyKWh, unit: .kilowattHours),
            duration: duration
        )

        try await loadEvent.send()
    }

    // MARK: - Optimization

    /// グリッド料金データと快適度プロファイルから最適運転プランを生成
    func generateOperationPlan(
        gridData: [GridPriceData],
        profile: ComfortProfile,
        currentTemperature: Double,
        outdoorTemperature: Double
    ) -> DailyOperationPlan {
        var slots: [OperationSlot] = []

        for (index, data) in gridData.enumerated() {
            let endDate: Date
            if index + 1 < gridData.count {
                endDate = gridData[index + 1].date
            } else {
                endDate = data.date.addingTimeInterval(3600)
            }

            let mode: OperationMode
            let targetTemp: Double

            switch data.priceLevel {
            case .onPeak:
                // ピーク時間はパッシブ or OFF
                if data.combinedScore > 0.7 {
                    mode = .off
                    targetTemp = profile.awayTemperature
                } else {
                    mode = .passive
                    targetTemp = currentTemperature
                }
            case .midPeak:
                mode = .passive
                targetTemp = (profile.minimumTemperature + profile.maximumTemperature) / 2
            case .offPeak:
                // オフピーク時に事前調整
                let hour = Calendar.current.component(.hour, from: data.date)
                if hour < 8 {
                    mode = outdoorTemperature < 15 ? .preHeat : .normal
                    targetTemp = outdoorTemperature < 15
                        ? profile.maximumTemperature
                        : (profile.minimumTemperature + profile.maximumTemperature) / 2
                } else if hour >= 14 && hour < 16 {
                    mode = outdoorTemperature > 28 ? .preCool : .normal
                    targetTemp = outdoorTemperature > 28
                        ? profile.minimumTemperature
                        : (profile.minimumTemperature + profile.maximumTemperature) / 2
                } else {
                    mode = .normal
                    targetTemp = (profile.minimumTemperature + profile.maximumTemperature) / 2
                }
            }

            slots.append(OperationSlot(
                startDate: data.date,
                endDate: endDate,
                targetTemperature: targetTemp,
                mode: mode,
                cleanFraction: data.cleanFraction,
                priceLevel: data.priceLevel
            ))
        }

        // 節約額を概算
        let normalCost = gridData.reduce(0.0) { $0 + $1.ratePerKWh * 2.0 } // 常時2kW想定
        let optimizedCost = slots.reduce(0.0) { total, slot in
            let powerKW: Double
            switch slot.mode {
            case .preHeat, .preCool: powerKW = 2.5
            case .normal: powerKW = 1.5
            case .passive: powerKW = 0.5
            case .off: powerKW = 0.0
            }
            return total + slot.priceLevel.ratePerKWh * powerKW
        }

        let savings = max(0, normalCost - optimizedCost)
        let comfortScore = calculateComfortScore(slots: slots, profile: profile)
        let totalEnergy = slots.reduce(0.0) { total, slot in
            let powerKW: Double
            switch slot.mode {
            case .preHeat, .preCool: powerKW = 2.5
            case .normal: powerKW = 1.5
            case .passive: powerKW = 0.5
            case .off: powerKW = 0.0
            }
            return total + powerKW * (Double(slot.durationMinutes) / 60.0)
        }

        return DailyOperationPlan(
            date: Date(),
            slots: slots,
            estimatedSavings: savings,
            comfortScore: comfortScore,
            estimatedEnergyKWh: totalEnergy
        )
    }

    // MARK: - Private

    private func mapToPriceLevel(_ level: ElectricityGuidanceLevel) -> PriceLevel {
        switch level {
        case .good: .offPeak
        case .neutral: .midPeak
        case .bad: .onPeak
        @unknown default: .midPeak
        }
    }

    private func calculateComfortScore(
        slots: [OperationSlot],
        profile: ComfortProfile
    ) -> Int {
        guard !slots.isEmpty else { return 0 }

        var totalScore = 0
        for slot in slots {
            let temp = slot.targetTemperature
            let midpoint = (profile.minimumTemperature + profile.maximumTemperature) / 2
            let range = (profile.maximumTemperature - profile.minimumTemperature) / 2
            let deviation = abs(temp - midpoint) / max(range, 1.0)
            let score = max(0, Int(100.0 * (1.0 - deviation * 0.5)))
            totalScore += score
        }

        return totalScore / slots.count
    }
}

/// ThermoShift 関連のエラー
enum ThermoShiftError: Error, LocalizedError {
    case venueNotConfigured

    var errorDescription: String? {
        switch self {
        case .venueNotConfigured:
            "HomeKit Home が設定されていません。"
        }
    }
}
