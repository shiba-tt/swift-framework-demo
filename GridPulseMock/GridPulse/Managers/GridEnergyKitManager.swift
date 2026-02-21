import Foundation
import EnergyKit

/// EnergyKit を使った電力グリッドデータの取得（アート可視化用）
@MainActor
@Observable
final class GridEnergyKitManager {
    static let shared = GridEnergyKitManager()

    /// ベニュー（HomeKit Home）の選択状態
    private(set) var selectedVenue: EnergyVenue?

    /// ベニューが設定済みかどうか
    var isVenueConfigured: Bool {
        selectedVenue != nil
    }

    private init() {}

    // MARK: - Venue Setup

    func configureVenue(_ venue: EnergyVenue) {
        selectedVenue = venue
    }

    // MARK: - Fetch Grid Data

    /// 今日のグリッド状態を取得
    func fetchTodayGrid() async throws -> [GridState] {
        guard let venue = selectedVenue else {
            throw GridEnergyKitError.venueNotConfigured
        }

        let query = ElectricityGuidanceQuery(venue: venue)
        var states: [GridState] = []

        for try await guidance in query.guidances {
            let state = GridState(
                date: guidance.startDate,
                cleanEnergyFraction: guidance.cleanEnergyFraction,
                solarFraction: guidance.cleanEnergyFraction * 0.6,
                windFraction: guidance.cleanEnergyFraction * 0.4
            )
            states.append(state)
        }

        return states.sorted { $0.date < $1.date }
    }

    // MARK: - Analysis

    /// 日次サマリーを生成
    func generateDailySummary(from states: [GridState]) -> GridDailySummary {
        guard !states.isEmpty else {
            return GridDailySummary(
                date: Date(),
                averageCleanFraction: 0,
                peakCleanFraction: 0,
                peakCleanHour: 12,
                lowestCleanFraction: 0,
                lowestCleanHour: 0,
                totalSolarHours: 0,
                totalWindHours: 0
            )
        }

        let avgClean = states.reduce(0.0) { $0 + $1.cleanEnergyFraction } / Double(states.count)

        let peak = states.max { $0.cleanEnergyFraction < $1.cleanEnergyFraction }!
        let lowest = states.min { $0.cleanEnergyFraction < $1.cleanEnergyFraction }!

        let calendar = Calendar.current
        let peakHour = calendar.component(.hour, from: peak.date)
        let lowestHour = calendar.component(.hour, from: lowest.date)

        let totalSolar = states.reduce(0.0) { $0 + $1.solarFraction }
        let totalWind = states.reduce(0.0) { $0 + $1.windFraction }

        return GridDailySummary(
            date: states.first?.date ?? Date(),
            averageCleanFraction: avgClean,
            peakCleanFraction: peak.cleanEnergyFraction,
            peakCleanHour: peakHour,
            lowestCleanFraction: lowest.cleanEnergyFraction,
            lowestCleanHour: lowestHour,
            totalSolarHours: totalSolar,
            totalWindHours: totalWind
        )
    }
}

/// GridPulse 固有のエラー
enum GridEnergyKitError: Error, LocalizedError {
    case venueNotConfigured

    var errorDescription: String? {
        switch self {
        case .venueNotConfigured:
            "HomeKit Home が設定されていません。"
        }
    }
}
