import Foundation
import SwiftUI

/// MindMirror のメインビューモデル
@MainActor
@Observable
final class MindMirrorViewModel {
    // MARK: - State

    /// 今日のメンタルヘルススコア
    private(set) var todayScore: MentalHealthScore?

    /// 今日の行動メトリクス
    private(set) var todayMetrics: BehaviorMetrics?

    /// 過去7日分のレポート
    private(set) var weeklyReports: [DailyReport] = []

    /// 週間サマリー
    private(set) var weeklySummary: WeeklySummary?

    /// 今日のインサイト
    private(set) var todayInsights: [Insight] = []

    /// HealthKit からの歩数
    private(set) var todaySteps: Int = 0

    /// HealthKit からの睡眠時間
    private(set) var lastSleepMinutes: Int = 0

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// センサー記録中かどうか
    var isRecording: Bool {
        sensorKitManager.isRecording
    }

    // MARK: - Dependencies

    let sensorKitManager = SensorKitManager.shared
    let healthDataManager = HealthDataManager.shared

    // MARK: - Actions

    /// 初期化と認可
    func initialize() async {
        isLoading = true

        // SensorKit 認可
        if !sensorKitManager.isAuthorized {
            sensorKitManager.requestAuthorization()
        }

        // HealthKit 認可
        if healthDataManager.isAvailable && !healthDataManager.isAuthorized {
            _ = await healthDataManager.requestAuthorization()
        }

        await refresh()
        isLoading = false
    }

    /// データの更新
    func refresh() async {
        // SensorKit データ取得
        if sensorKitManager.isAuthorized {
            sensorKitManager.fetchRecentData()
        }

        // HealthKit データ取得
        if healthDataManager.isAuthorized {
            async let steps = healthDataManager.fetchTodayStepCount()
            async let sleep = healthDataManager.fetchLastNightSleepMinutes()
            todaySteps = await steps
            lastSleepMinutes = await sleep
        }

        // メトリクスの集約
        todayMetrics = buildTodayMetrics()

        // スコア計算
        if let metrics = todayMetrics {
            todayScore = sensorKitManager.calculateScore(from: metrics)
        }

        // インサイト生成
        generateInsights()

        // 週間データ生成（デモ用）
        generateWeeklyData()
    }

    /// センサー記録の開始/停止
    func toggleRecording() {
        if sensorKitManager.isRecording {
            sensorKitManager.stopRecording()
        } else {
            sensorKitManager.startRecording()
        }
    }

    // MARK: - Private

    /// 今日の行動メトリクスを構築
    private func buildTodayMetrics() -> BehaviorMetrics {
        BehaviorMetrics(
            date: Date(),
            typing: sensorKitManager.typingMetrics,
            deviceUsage: sensorKitManager.deviceUsageMetrics,
            communication: sensorKitManager.communicationMetrics,
            mobility: sensorKitManager.mobilityMetrics,
            ambientLight: sensorKitManager.ambientLightSamples.last
        )
    }

    /// インサイトを生成
    private func generateInsights() {
        var insights: [Insight] = []

        if let typing = todayMetrics?.typing {
            if typing.speedLevel == .concern {
                insights.append(Insight(
                    type: .warning,
                    title: "タイピング速度の低下",
                    description: "タイピング速度が普段より低下しています。疲れていませんか？",
                    relatedCategory: .cognition
                ))
            }
            if typing.sentimentScore > 0.5 {
                insights.append(Insight(
                    type: .positive,
                    title: "ポジティブな入力傾向",
                    description: "キーボード入力の感情分析がポジティブ傾向です。",
                    relatedCategory: .mood
                ))
            }
        }

        if let comm = todayMetrics?.communication {
            if comm.socialLevel == .concern {
                insights.append(Insight(
                    type: .warning,
                    title: "コミュニケーション量の減少",
                    description: "電話やメッセージの量が少なくなっています。誰かに連絡してみませんか？",
                    relatedCategory: .social
                ))
            }
        }

        if let mobility = todayMetrics?.mobility {
            if mobility.mobilityLevel == .good {
                insights.append(Insight(
                    type: .positive,
                    title: "活動的な1日",
                    description: "複数の場所を訪れています。良い活動量です。",
                    relatedCategory: .activity
                ))
            }
        }

        if let light = todayMetrics?.ambientLight {
            if light.lightLevel == .concern {
                insights.append(Insight(
                    type: .neutral,
                    title: "光環境について",
                    description: "明るい環境での時間が少なめです。日光を浴びることで生活リズムが整います。",
                    relatedCategory: .rhythm
                ))
            }
        }

        todayInsights = insights
    }

    /// 週間データを生成（デモ用）
    private func generateWeeklyData() {
        let calendar = Calendar.current
        var reports: [DailyReport] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }

            let demoScore = MentalHealthScore(
                overallScore: Int.random(in: 45...85),
                subScores: ScoreCategory.allCases.map { category in
                    SubScore(
                        category: category,
                        score: Int.random(in: 40...90),
                        weight: 0.2
                    )
                },
                changeFromPrevious: Int.random(in: -8...8)
            )

            let demoMetrics = BehaviorMetrics(
                date: date,
                typing: TypingMetrics(
                    averageWPM: Double.random(in: 25...45),
                    errorRate: Double.random(in: 0.02...0.15),
                    rhythmVariability: Double.random(in: 0.05...0.25),
                    sentimentScore: Double.random(in: -0.5...0.8)
                ),
                deviceUsage: DeviceUsageMetrics(
                    totalScreenTimeMinutes: Int.random(in: 120...600),
                    screenWakeCount: Int.random(in: 30...120),
                    unlockCount: Int.random(in: 20...80),
                    categoryUsage: [
                        AppCategoryUsage(category: "SNS", usageMinutes: Int.random(in: 10...120)),
                        AppCategoryUsage(category: "仕事", usageMinutes: Int.random(in: 30...240)),
                        AppCategoryUsage(category: "エンタメ", usageMinutes: Int.random(in: 10...90)),
                    ]
                ),
                communication: CommunicationMetrics(
                    outgoingCalls: Int.random(in: 0...5),
                    incomingCalls: Int.random(in: 0...5),
                    totalCallMinutes: Int.random(in: 0...30),
                    outgoingMessages: Int.random(in: 5...30),
                    incomingMessages: Int.random(in: 5...30)
                ),
                mobility: MobilityMetrics(
                    visitedPlaceCount: Int.random(in: 1...6),
                    homeTimeMinutes: Int.random(in: 600...1200),
                    awayTimeMinutes: Int.random(in: 60...540),
                    maxDistanceFromHomeKm: Double.random(in: 0.5...15.0)
                ),
                ambientLight: AmbientLightMetrics(
                    averageLux: Double.random(in: 100...800),
                    peakDaytimeLux: Double.random(in: 500...10000),
                    nighttimeAverageLux: Double.random(in: 5...50),
                    brightExposureMinutes: Int.random(in: 30...180)
                )
            )

            reports.append(DailyReport(
                date: date,
                score: demoScore,
                metrics: demoMetrics,
                insights: []
            ))
        }

        weeklyReports = reports
        weeklySummary = WeeklySummary(
            weekStartDate: reports.first?.date ?? Date(),
            averageScore: reports.reduce(0) { $0 + $1.score.overallScore } / max(1, reports.count),
            scoreTrend: reports.map(\.score.overallScore),
            bestDay: reports.max { $0.score.overallScore < $1.score.overallScore },
            worstDay: reports.min { $0.score.overallScore < $1.score.overallScore },
            keyInsights: []
        )
    }
}
