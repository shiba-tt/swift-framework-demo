import Foundation
import SwiftUI

/// SocialPulse アプリのメイン ViewModel
@MainActor
@Observable
final class SocialPulseViewModel {

    // MARK: - State

    /// 今日の社会的つながりスコア
    private(set) var currentScore: SocialScore?
    /// 今日のコミュニケーション記録
    private(set) var todayRecord: CommunicationRecord?
    /// 過去7日間の訪問記録
    private(set) var visitRecords: [VisitRecord] = []
    /// 週間レポート
    private(set) var weeklyReport: WeeklyReport?
    /// 認可状態
    private(set) var isAuthorized = false
    /// ローディング状態
    private(set) var isLoading = false

    // MARK: - Dependencies

    let sensorKitManager = SocialSensorKitManager.shared

    // MARK: - Computed Properties

    /// 今日の総合スコア
    var todayScore: Int {
        currentScore?.overallScore ?? 0
    }

    /// 今日のスコアレベル
    var todayLevel: SocialLevel {
        currentScore?.scoreLevel ?? .poor
    }

    /// 今日の評価テキスト
    var assessmentText: String {
        currentScore?.assessmentText ?? "データを収集中..."
    }

    /// 週間平均スコア
    var weeklyAverageScore: Int {
        weeklyReport?.averageScore ?? 0
    }

    /// 週間トレンド
    var weeklyTrend: WeeklyTrend {
        weeklyReport?.trend ?? .stable
    }

    /// 今日の訪問記録
    var todayVisitRecord: VisitRecord? {
        visitRecords.last
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true
        generateDemoData()
        isAuthorized = true
        isLoading = false
    }

    /// データの更新
    func refreshData() async {
        isLoading = true
        generateDemoData()
        isLoading = false
    }

    // MARK: - Demo Data Generation

    /// SensorKit が Apple 承認制のため、リアルなデモデータを生成
    func generateDemoData() {
        let calendar = Calendar.current
        let today = Date()

        var dailyScores: [SocialScore] = []
        var communicationRecords: [CommunicationRecord] = []
        var visitRecordsList: [VisitRecord] = []
        var previousScore: Int?

        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let isWeekend = calendar.isDateInWeekend(date)

            // コミュニケーション記録を生成
            let commRecord = generateCommunicationRecord(date: date, isWeekend: isWeekend, dayOffset: dayOffset)
            communicationRecords.append(commRecord)

            // 訪問記録を生成
            let visitRecord = generateVisitRecord(date: date, isWeekend: isWeekend, dayOffset: dayOffset)
            visitRecordsList.append(visitRecord)

            // スコアを計算
            let score = sensorKitManager.calculateSocialScore(
                date: date,
                communication: commRecord,
                visit: visitRecord,
                previousScore: previousScore
            )
            dailyScores.append(score)
            previousScore = score.overallScore
        }

        // 状態を更新
        currentScore = dailyScores.last
        todayRecord = communicationRecords.last
        visitRecords = visitRecordsList

        // 週間レポートを生成
        weeklyReport = WeeklyReport(
            weekStartDate: calendar.date(byAdding: .day, value: -6, to: today)!,
            dailyScores: dailyScores,
            insights: generateInsights(
                scores: dailyScores,
                communications: communicationRecords,
                visits: visitRecordsList
            )
        )
    }

    // MARK: - Communication Record Generation

    private func generateCommunicationRecord(date: Date, isWeekend: Bool, dayOffset: Int) -> CommunicationRecord {
        let jitter = dayOffset % 3

        let outgoingCalls: Int
        let incomingCalls: Int
        let callDuration: Int
        let outgoingMessages: Int
        let incomingMessages: Int
        let uniqueContacts: Int

        if isWeekend {
            // 週末はやや多めのコミュニケーション
            outgoingCalls = Int.random(in: 2...5) + jitter
            incomingCalls = Int.random(in: 3...7)
            callDuration = Int.random(in: 20...60)
            outgoingMessages = Int.random(in: 10...25)
            incomingMessages = Int.random(in: 12...30)
            uniqueContacts = Int.random(in: 5...10)
        } else {
            // 平日は仕事中心のコミュニケーション
            outgoingCalls = Int.random(in: 1...4) + jitter
            incomingCalls = Int.random(in: 2...6)
            callDuration = Int.random(in: 15...45)
            outgoingMessages = Int.random(in: 8...20)
            incomingMessages = Int.random(in: 10...22)
            uniqueContacts = Int.random(in: 4...8)
        }

        return CommunicationRecord(
            date: date,
            outgoingCalls: outgoingCalls,
            incomingCalls: incomingCalls,
            callDurationMinutes: callDuration,
            outgoingMessages: outgoingMessages,
            incomingMessages: incomingMessages,
            uniqueContacts: uniqueContacts
        )
    }

    // MARK: - Visit Record Generation

    private func generateVisitRecord(date: Date, isWeekend: Bool, dayOffset: Int) -> VisitRecord {
        let placesVisited: Int
        let timeOutside: Int
        let distanceFromHome: Double
        var categories: [VisitCategory: Int] = [:]

        if isWeekend {
            placesVisited = Int.random(in: 2...6)
            timeOutside = Int.random(in: 180...420)
            distanceFromHome = Double.random(in: 2.0...15.0)

            // 週末のカテゴリ
            categories[.home] = 1
            if Bool.random() { categories[.gym] = 1 }
            categories[.shopping] = Int.random(in: 0...2)
            categories[.restaurant] = Int.random(in: 0...2)
            if dayOffset % 2 == 0 { categories[.other] = Int.random(in: 1...2) }
        } else {
            placesVisited = Int.random(in: 2...4)
            timeOutside = Int.random(in: 300...540)
            distanceFromHome = Double.random(in: 3.0...20.0)

            // 平日のカテゴリ
            categories[.home] = 1
            categories[.work] = 1
            if dayOffset % 3 == 0 { categories[.gym] = 1 }
            categories[.restaurant] = Int.random(in: 0...1)
            if dayOffset % 2 == 0 { categories[.shopping] = 1 }
        }

        return VisitRecord(
            date: date,
            placesVisited: placesVisited,
            timeOutsideMinutes: timeOutside,
            categories: categories,
            distanceFromHomeKm: distanceFromHome
        )
    }

    // MARK: - Insights Generation

    private func generateInsights(
        scores: [SocialScore],
        communications: [CommunicationRecord],
        visits: [VisitRecord]
    ) -> [String] {
        var insights: [String] = []

        // スコアトレンド分析
        if let first = scores.first, let last = scores.last {
            let diff = last.overallScore - first.overallScore
            if diff > 5 {
                insights.append("今週の社会的つながりスコアは改善傾向にあります。この調子を維持しましょう。")
            } else if diff < -5 {
                insights.append("今週の社会的つながりスコアがやや低下しています。友人や家族との連絡を増やしてみましょう。")
            } else {
                insights.append("今週の社会的つながりスコアは安定しています。")
            }
        }

        // コミュニケーション分析
        let avgCalls = communications.reduce(0) { $0 + $1.totalCalls } / max(1, communications.count)
        let avgMessages = communications.reduce(0) { $0 + $1.totalMessages } / max(1, communications.count)

        if avgCalls >= 6 {
            insights.append("電話でのコミュニケーションが活発です。声を使った会話は社会的つながりの質を高めます。")
        } else if avgCalls <= 2 {
            insights.append("電話の使用が少なめです。テキストだけでなく、音声通話も社会的つながりに効果的です。")
        }

        if avgMessages >= 20 {
            insights.append("メッセージのやり取りが多く、デジタルコミュニケーションが充実しています。")
        }

        // 訪問分析
        let avgPlaces = visits.reduce(0) { $0 + $1.placesVisited } / max(1, visits.count)
        let avgTimeOutside = visits.reduce(0.0) { $0 + $1.timeOutsideHours } / max(1.0, Double(visits.count))

        if avgPlaces >= 4 {
            insights.append("多くの場所を訪問しており、行動範囲が広いです。外出は社会的孤立の予防に効果的です。")
        } else if avgPlaces <= 1 {
            insights.append("外出先が限られています。新しい場所への訪問が社会的つながりの幅を広げます。")
        }

        if avgTimeOutside >= 5.0 {
            insights.append("自宅外で過ごす時間が十分確保されています。外出の習慣は社会的健康に良い影響を与えます。")
        }

        // ユニーク連絡先分析
        let avgContacts = communications.reduce(0) { $0 + $1.uniqueContacts } / max(1, communications.count)
        if avgContacts >= 6 {
            insights.append("多様な人々とのコミュニケーションが維持されています。社会的ネットワークの広さは重要な保護因子です。")
        }

        return insights
    }
}
