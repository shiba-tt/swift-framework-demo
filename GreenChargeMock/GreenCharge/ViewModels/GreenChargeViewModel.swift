import Foundation
import SwiftUI

/// GreenCharge のメインビューモデル
@MainActor
@Observable
final class GreenChargeViewModel {
    // MARK: - State

    /// 今日のグリッド予測
    private(set) var gridForecasts: [GridForecast] = []

    /// クリーンウィンドウ
    private(set) var cleanWindows: [CleanWindow] = []

    /// 現在のグリッド状態
    private(set) var currentForecast: GridForecast?

    /// 次のクリーンウィンドウ
    private(set) var nextCleanWindow: CleanWindow?

    /// ユーザーのグリーンスコア
    private(set) var greenScore: GreenScore

    /// 充電履歴
    private(set) var chargingSessions: [ChargingSession] = []

    /// スマート充電プラン
    private(set) var currentPlan: SmartChargePlan?

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// スマート予約画面の表示フラグ
    var showScheduleSheet = false

    /// 目標充電率
    var targetChargeLevel: Double = 0.8

    /// 出発予定時刻
    var departureDate: Date = Calendar.current.date(
        bySettingHour: 7, minute: 30, second: 0, of: Date().addingTimeInterval(86400)
    ) ?? Date()

    /// 現在の充電率
    var currentChargeLevel: Double = 0.5

    /// 現在のクリーン度テキスト
    var currentCleanText: String {
        currentForecast?.cleanPercentText ?? "--"
    }

    /// 現在のガイダンスレベル
    var currentGuidance: GuidanceLevel {
        currentForecast?.guidanceLevel ?? .neutral
    }

    // MARK: - Dependencies

    let energyKitManager = EnergyKitManager.shared

    // MARK: - Init

    init() {
        // デモ用の初期スコア
        greenScore = GreenScore(
            totalPoints: 2450,
            monthlyPoints: 580,
            cleanChargeRate: 0.78,
            totalCO2Savings: 42.3,
            rank: 12,
            totalParticipants: 1280
        )

        // デモ用の充電履歴を生成
        generateDemoData()
    }

    // MARK: - Actions

    /// データの初回読み込み
    func initialize() async {
        isLoading = true
        await loadGridForecast()
        isLoading = false
    }

    /// グリッド予測を取得
    func loadGridForecast() async {
        errorMessage = nil

        do {
            gridForecasts = try await energyKitManager.fetchGridForecast()

            cleanWindows = energyKitManager.findCleanWindows(in: gridForecasts)

            currentForecast = gridForecasts.first {
                $0.date <= Date() && $0.date.addingTimeInterval(3600) > Date()
            } ?? gridForecasts.first

            nextCleanWindow = cleanWindows.first { $0.startDate > Date() }
        } catch is EnergyKitError {
            // ベニュー未設定の場合はデモデータを使用
            generateDemoForecasts()
        } catch {
            errorMessage = "グリッドデータの取得に失敗しました: \(error.localizedDescription)"
            generateDemoForecasts()
        }
    }

    /// スマート充電プランを生成
    func generatePlan() {
        currentPlan = energyKitManager.generateChargePlan(
            forecasts: gridForecasts,
            targetChargeLevel: targetChargeLevel,
            departureDate: departureDate,
            currentChargeLevel: currentChargeLevel
        )
    }

    /// 充電を開始
    func startCharging() async {
        let session = ChargingSession(
            startDate: Date(),
            endDate: nil,
            energyKWh: 0,
            averageCleanFraction: currentForecast?.cleanEnergyFraction ?? 0.5,
            status: .charging,
            earnedPoints: 0
        )
        chargingSessions.insert(session, at: 0)

        // LoadEvent を送信
        do {
            try await energyKitManager.reportLoadEvent(
                energyKWh: 0,
                duration: 0,
                isCharging: true
            )
        } catch {
            print("[GreenCharge] LoadEvent 送信失敗: \(error)")
        }
    }

    /// プランを確定
    func confirmPlan() {
        showScheduleSheet = false
        // プランに基づいて充電セッションを予約
        if let plan = currentPlan {
            for slot in plan.slots where slot.action == .charge {
                let session = ChargingSession(
                    startDate: slot.startDate,
                    endDate: slot.endDate,
                    energyKWh: 0,
                    averageCleanFraction: slot.cleanFraction,
                    status: .scheduled,
                    earnedPoints: 0
                )
                chargingSessions.insert(session, at: 0)
            }
        }
    }

    // MARK: - Demo Data

    private func generateDemoForecasts() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var forecasts: [GridForecast] = []

        // 24時間分のデモ予測を生成
        let cleanPatterns: [Double] = [
            0.45, 0.42, 0.40, 0.38, 0.35, 0.40,
            0.50, 0.55, 0.65, 0.72, 0.80, 0.85,
            0.87, 0.82, 0.70, 0.55, 0.40, 0.35,
            0.45, 0.60, 0.75, 0.80, 0.70, 0.55,
        ]

        for hour in 0..<24 {
            let date = calendar.date(byAdding: .hour, value: hour, to: today)!
            let clean = cleanPatterns[hour]
            let level: GuidanceLevel
            switch clean {
            case 0.6...: level = .good
            case 0.4..<0.6: level = .neutral
            default: level = .bad
            }

            forecasts.append(GridForecast(
                date: date,
                cleanEnergyFraction: clean,
                guidanceLevel: level
            ))
        }

        gridForecasts = forecasts
        cleanWindows = energyKitManager.findCleanWindows(in: forecasts)
        currentForecast = forecasts.first {
            $0.date <= Date() && $0.date.addingTimeInterval(3600) > Date()
        } ?? forecasts.first
        nextCleanWindow = cleanWindows.first { $0.startDate > Date() }
    }

    private func generateDemoData() {
        let calendar = Calendar.current
        var sessions: [ChargingSession] = []

        for dayOffset in (1...7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }
            let clean = Double.random(in: 0.5...0.95)
            sessions.append(ChargingSession(
                startDate: date,
                endDate: date.addingTimeInterval(Double.random(in: 3600...14400)),
                energyKWh: Double.random(in: 5...30),
                averageCleanFraction: clean,
                status: .completed,
                earnedPoints: Int(clean * 100)
            ))
        }

        chargingSessions = sessions
    }
}
