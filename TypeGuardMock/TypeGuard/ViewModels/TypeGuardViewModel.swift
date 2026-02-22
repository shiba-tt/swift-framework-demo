import Foundation
import SwiftUI

/// TypeGuard のメインビューモデル
@MainActor
@Observable
final class TypeGuardViewModel {
    // MARK: - State

    /// 直近のバイオマーカーデータ
    private(set) var latestBiomarker: TypingBiomarker?

    /// 過去のバイオマーカー履歴（デモ用含む）
    private(set) var biomarkerHistory: [TypingBiomarker] = []

    /// ベースラインからの偏差
    private(set) var deviations: [DeviationResult] = []

    /// アラート履歴
    private(set) var alertHistory: [AlertRecord] = []

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// センサー記録中かどうか
    var isRecording: Bool {
        metricsManager.isRecording
    }

    // MARK: - Dependencies

    let metricsManager = KeyboardMetricsManager.shared

    // MARK: - Actions

    /// 初期化と認可
    func initialize() async {
        isLoading = true

        if !metricsManager.isAuthorized {
            metricsManager.requestAuthorization()
        }

        await refresh()
        isLoading = false
    }

    /// データの更新
    func refresh() async {
        // SensorKit データ取得
        if metricsManager.isAuthorized {
            metricsManager.fetchRecentData()
        }

        // デモデータを生成
        generateDemoData()

        // ベースライン更新
        metricsManager.updateBaseline(from: biomarkerHistory)

        // 最新データの偏差を計算
        if let latest = latestBiomarker {
            deviations = metricsManager.calculateDeviations(current: latest)
        }

        // アラート取得
        alertHistory = metricsManager.alerts
    }

    /// センサー記録の開始/停止
    func toggleRecording() {
        if metricsManager.isRecording {
            metricsManager.stopRecording()
        } else {
            metricsManager.startRecording()
        }
    }

    // MARK: - Demo Data

    private func generateDemoData() {
        let calendar = Calendar.current
        var history: [TypingBiomarker] = []

        // 30日分のデモデータ
        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }

            // 最後の5日間は軽い変化を表現
            let recentVariation = dayOffset < 5 ? 0.15 : 0.0

            let biomarker = TypingBiomarker(
                date: date,
                averageWPM: 38 + Double.random(in: -5...5) - recentVariation * 8,
                errorRate: 0.05 + Double.random(in: -0.02...0.03) + recentVariation * 0.04,
                rhythmVariability: 0.10 + Double.random(in: -0.03...0.05) + recentVariation * 0.06,
                adjacentKeyErrorRate: 0.025 + Double.random(in: -0.01...0.02) + recentVariation * 0.02,
                pressureDurationSD: 22 + Double.random(in: -5...8) + recentVariation * 12,
                sentimentScore: 0.2 + Double.random(in: -0.4...0.3) - recentVariation * 0.15
            )
            history.append(biomarker)
        }

        biomarkerHistory = history
        latestBiomarker = history.last

        // デモ用のアラート
        if alertHistory.isEmpty {
            alertHistory = generateDemoAlerts()
        }
    }

    private func generateDemoAlerts() -> [AlertRecord] {
        let calendar = Calendar.current
        var alerts: [AlertRecord] = []

        if let date1 = calendar.date(byAdding: .day, value: -2, to: Date()) {
            alerts.append(AlertRecord(
                date: date1,
                title: "タイピング速度の低下傾向",
                description: "過去3日間のタイピング速度がベースラインから12%低下しています。疲労や体調の変化が考えられます。",
                severity: .info,
                relatedMetrics: [.speed]
            ))
        }

        if let date2 = calendar.date(byAdding: .day, value: -1, to: Date()) {
            alerts.append(AlertRecord(
                date: date2,
                title: "リズム不規則性の増加",
                description: "キーストローク間隔のばらつきが増加しています。リラックスした状態で入力してみてください。",
                severity: .warning,
                relatedMetrics: [.rhythm, .adjacentError]
            ))
        }

        return alerts
    }
}
