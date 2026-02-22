import Foundation
import SwiftUI

/// ThermoShift のメインビューモデル
@MainActor
@Observable
final class ThermoShiftViewModel {
    // MARK: - State

    /// 現在の室温 (°C)
    private(set) var currentTemperature: Double = 23.5

    /// 目標温度 (°C)
    var targetTemperature: Double = 23.0

    /// 外気温 (°C)
    private(set) var outdoorTemperature: Double = 18.0

    /// 現在の快適度スコア (0〜100)
    private(set) var currentComfortScore: Int = 95

    /// 今日のグリッド料金データ
    private(set) var gridPriceData: [GridPriceData] = []

    /// 今日の運転プラン
    private(set) var currentPlan: DailyOperationPlan?

    /// 現在実行中のスロット
    private(set) var activeSlot: OperationSlot?

    /// 室温履歴
    private(set) var temperatureHistory: [TemperatureRecord] = []

    /// 月次レポート
    private(set) var monthlyReports: [MonthlySavingsReport] = []

    /// 快適度プロファイル
    var comfortProfile: ComfortProfile = .default

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// 設定画面の表示フラグ
    var showSettings = false

    /// レポート画面の表示フラグ
    var showReport = false

    // MARK: - Computed

    var currentModeText: String {
        activeSlot?.mode.rawValue ?? "待機中"
    }

    var currentModeIcon: String {
        activeSlot?.mode.systemImageName ?? "questionmark.circle"
    }

    var savingsText: String {
        guard let plan = currentPlan else { return "$0.00" }
        return String(format: "$%.2f", plan.estimatedSavings)
    }

    var comfortScoreText: String {
        "\(currentComfortScore)%"
    }

    var energyText: String {
        guard let plan = currentPlan else { return "0.0 kWh" }
        return String(format: "%.1f kWh", plan.estimatedEnergyKWh)
    }

    // MARK: - Dependencies

    let energyKitManager = EnergyKitManager.shared

    // MARK: - Init

    init() {
        generateDemoData()
    }

    // MARK: - Actions

    /// データの初回読み込み
    func initialize() async {
        isLoading = true
        await loadGridData()
        isLoading = false
    }

    /// グリッドデータを取得して運転プランを生成
    func loadGridData() async {
        errorMessage = nil

        do {
            gridPriceData = try await energyKitManager.fetchGridPriceData()
        } catch is ThermoShiftError {
            generateDemoGridData()
        } catch {
            errorMessage = "グリッドデータの取得に失敗しました: \(error.localizedDescription)"
            generateDemoGridData()
        }

        generateOptimizedPlan()
    }

    /// AI 最適化プランを再生成
    func generateOptimizedPlan() {
        let plan = energyKitManager.generateOperationPlan(
            gridData: gridPriceData,
            profile: comfortProfile,
            currentTemperature: currentTemperature,
            outdoorTemperature: outdoorTemperature
        )
        currentPlan = plan

        // 現在のスロットを特定
        let now = Date()
        activeSlot = plan.slots.first { $0.startDate <= now && $0.endDate > now }
    }

    /// 目標温度を変更
    func adjustTargetTemperature(by delta: Double) {
        targetTemperature = max(16.0, min(30.0, targetTemperature + delta))
    }

    /// HVAC の消費電力を報告
    func reportCurrentUsage() async {
        guard let slot = activeSlot else { return }
        let powerKW: Double
        switch slot.mode {
        case .preHeat, .preCool: powerKW = 2.5
        case .normal: powerKW = 1.5
        case .passive: powerKW = 0.5
        case .off: powerKW = 0.0
        }
        let durationHours = Double(slot.durationMinutes) / 60.0
        let energy = powerKW * durationHours

        do {
            try await energyKitManager.reportHVACLoadEvent(
                energyKWh: energy,
                duration: TimeInterval(slot.durationMinutes * 60)
            )
        } catch {
            print("[ThermoShift] LoadEvent 送信失敗: \(error)")
        }
    }

    // MARK: - Demo Data

    private func generateDemoGridData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // TOU 料金パターン: オフピーク(0-8), ミッドピーク(8-12), ピーク(12-14),
        // ミッドピーク(14-16), ピーク(16-19), ミッドピーク(19-22), オフピーク(22-24)
        let touPattern: [(hour: Int, price: PriceLevel)] = [
            (0, .offPeak), (1, .offPeak), (2, .offPeak), (3, .offPeak),
            (4, .offPeak), (5, .offPeak), (6, .offPeak), (7, .offPeak),
            (8, .midPeak), (9, .midPeak), (10, .midPeak), (11, .midPeak),
            (12, .onPeak), (13, .onPeak),
            (14, .midPeak), (15, .midPeak),
            (16, .onPeak), (17, .onPeak), (18, .onPeak),
            (19, .midPeak), (20, .midPeak), (21, .midPeak),
            (22, .offPeak), (23, .offPeak),
        ]

        let cleanPatterns: [Double] = [
            0.45, 0.42, 0.40, 0.38, 0.35, 0.40,
            0.50, 0.55, 0.65, 0.72, 0.80, 0.85,
            0.87, 0.82, 0.70, 0.55, 0.40, 0.35,
            0.45, 0.60, 0.75, 0.80, 0.70, 0.55,
        ]

        gridPriceData = touPattern.enumerated().map { index, pattern in
            let date = calendar.date(byAdding: .hour, value: pattern.hour, to: today)!
            return GridPriceData(
                date: date,
                cleanFraction: cleanPatterns[index],
                priceLevel: pattern.price,
                ratePerKWh: pattern.price.ratePerKWh
            )
        }
    }

    private func generateDemoData() {
        generateDemoGridData()

        // 室温履歴を生成
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        temperatureHistory = (0..<24).map { hour in
            let date = calendar.date(byAdding: .hour, value: hour, to: today)!
            let baseTemp = 23.0
            let variation = sin(Double(hour) * .pi / 12.0) * 1.5
            let temp = baseTemp + variation + Double.random(in: -0.3...0.3)
            let target = 23.0
            let deviation = abs(temp - target)
            let score = max(70, Int(100 - deviation * 10))
            return TemperatureRecord(
                date: date,
                temperature: temp,
                targetTemperature: target,
                comfortScore: score
            )
        }

        // 月次レポートを生成
        monthlyReports = (1...6).reversed().map { monthOffset in
            let month = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            return MonthlySavingsReport(
                month: month,
                totalSavings: Double.random(in: 45...120),
                totalEnergyKWh: Double.random(in: 200...400),
                averageComfortScore: Int.random(in: 88...96),
                co2Savings: Double.random(in: 30...80),
                operatingDays: Int.random(in: 25...31)
            )
        }
    }
}
