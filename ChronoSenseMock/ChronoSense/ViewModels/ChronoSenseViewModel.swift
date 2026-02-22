import Foundation
import SwiftUI

/// ChronoSense アプリのメイン ViewModel
@MainActor
@Observable
final class ChronoSenseViewModel {

    // MARK: - State

    private(set) var todayProfile: CircadianProfile?
    private(set) var weeklyRhythm: WeeklyRhythm?
    private(set) var isLoading = false
    var selectedChannel: SensorChannel = .activity
    var selectedDay: CircadianProfile?

    // MARK: - Dependencies

    let sensorKitManager = ChronoSensorKitManager.shared

    // MARK: - Computed Properties

    /// 今日のリズムスコア
    var todayScore: Int {
        todayProfile?.rhythmScore ?? 0
    }

    /// 今日のスコアレベル
    var todayLevel: RhythmLevel {
        todayProfile?.scoreLevel ?? .poor
    }

    /// 週間平均スコア
    var weeklyAverageScore: Int {
        weeklyRhythm?.averageScore ?? 0
    }

    /// 改善トレンドかどうか
    var isImproving: Bool {
        weeklyRhythm?.isImproving ?? false
    }

    /// 今日のアドバイス
    var todayAdvice: [RhythmAdvice] {
        guard let profile = todayProfile else { return [] }
        return generateAdvice(from: profile)
    }

    /// 表示対象のプロファイル（選択中 or 今日）
    var displayProfile: CircadianProfile? {
        selectedDay ?? todayProfile
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true
        generateMockData()
        isLoading = false
    }

    /// 選択した日をリセット
    func resetSelection() {
        selectedDay = nil
    }

    // MARK: - Mock Data Generation

    private func generateMockData() {
        let calendar = Calendar.current
        let today = Date()

        // 7日分のプロファイルを生成
        var profiles: [CircadianProfile] = []
        var previousScore: Int?

        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let isWeekend = calendar.isDateInWeekend(date)
            let readings = generateDayReadings(isWeekend: isWeekend, dayOffset: dayOffset)
            let score = sensorKitManager.calculateRhythmScore(readings: readings)

            let profile = CircadianProfile(
                date: date,
                readings: readings,
                rhythmScore: score,
                changeFromPrevious: previousScore.map { score - $0 }
            )
            profiles.append(profile)
            previousScore = score
        }

        todayProfile = profiles.last
        weeklyRhythm = WeeklyRhythm(
            weekStartDate: calendar.date(byAdding: .day, value: -6, to: today)!,
            profiles: profiles
        )
    }

    /// 1日分の24時間センサー読み取り値を生成
    private func generateDayReadings(isWeekend: Bool, dayOffset: Int) -> [SensorReading] {
        let wakeHour = isWeekend ? 9 : 7
        let sleepHour = isWeekend ? 24 : 23
        let jitter = Double(dayOffset % 3) * 0.05

        return (0..<24).map { hour in
            let isAwake = hour >= wakeHour && hour < sleepHour
            let isMorning = hour >= wakeHour && hour < 12
            let isAfternoon = hour >= 12 && hour < 18
            let isEvening = hour >= 18 && hour < sleepHour

            // 身体活動量
            let activity: Double
            if !isAwake {
                activity = Double.random(in: 0.0...0.05)
            } else if isMorning {
                activity = Double.random(in: 0.3...0.7) + jitter
            } else if isAfternoon {
                activity = Double.random(in: 0.4...0.8) + jitter
            } else {
                activity = Double.random(in: 0.1...0.4)
            }

            // 環境光
            let lux: Double
            if !isAwake {
                lux = Double.random(in: 0...10)
            } else if isMorning {
                lux = Double.random(in: 200...3000)
            } else if isAfternoon {
                lux = Double.random(in: 500...8000)
            } else {
                lux = Double.random(in: 50...300)
            }

            // スクリーンタイム
            let screenTime: Int
            if !isAwake {
                screenTime = Int.random(in: 0...2)
            } else if hour == 8 || hour == 12 || hour == 21 {
                screenTime = Int.random(in: 30...50)
            } else if isAfternoon {
                screenTime = Int.random(in: 15...40)
            } else {
                screenTime = Int.random(in: 5...20)
            }

            // キーストローク
            let keystrokes: Int
            if !isAwake || isEvening {
                keystrokes = isEvening ? Int.random(in: 10...50) : 0
            } else if isAfternoon && !isWeekend {
                keystrokes = Int.random(in: 100...400)
            } else {
                keystrokes = Int.random(in: 20...150)
            }

            // 歩数
            let steps: Int
            if !isAwake {
                steps = 0
            } else if (hour == 8 || hour == 18) && !isWeekend {
                steps = Int.random(in: 800...2000) // 通勤時間
            } else if isAfternoon && isWeekend {
                steps = Int.random(in: 300...1500)
            } else {
                steps = Int.random(in: 50...500)
            }

            // ソーシャルインタラクション
            let social: Int
            if !isAwake {
                social = 0
            } else if isAfternoon && !isWeekend {
                social = Int.random(in: 3...15)
            } else if isEvening {
                social = Int.random(in: 2...8)
            } else {
                social = Int.random(in: 0...5)
            }

            return SensorReading(
                hour: hour,
                activityLevel: min(1.0, max(0.0, activity)),
                ambientLux: max(0, lux),
                screenTimeMinutes: screenTime,
                keystrokes: keystrokes,
                steps: steps,
                socialInteractions: social,
                isWristOn: isAwake
            )
        }
    }

    // MARK: - Advice Generation

    private func generateAdvice(from profile: CircadianProfile) -> [RhythmAdvice] {
        var advice: [RhythmAdvice] = []

        // 光曝露に関するアドバイス
        let daytimeLight = profile.readings
            .filter { (8...16).contains($0.hour) }
            .reduce(0.0) { $0 + $1.ambientLux } / 9.0
        if daytimeLight < 500 {
            advice.append(RhythmAdvice(
                category: .light,
                title: "日光を浴びましょう",
                description: "日中の光曝露が不足しています。午前中に15分以上の屋外活動を取り入れると、概日リズムが安定します。",
                priority: .high
            ))
        }

        // 夜間スクリーンタイムに関するアドバイス
        let nightScreen = profile.readings
            .filter { $0.hour >= 22 || $0.hour <= 1 }
            .reduce(0) { $0 + $1.screenTimeMinutes }
        if nightScreen > 30 {
            advice.append(RhythmAdvice(
                category: .screen,
                title: "就寝前のスクリーンタイムを減らしましょう",
                description: "22時以降の画面使用が多いです。就寝1時間前からブルーライトを避けると、メラトニン分泌が改善されます。",
                priority: .high
            ))
        }

        // 活動パターンに関するアドバイス
        let morningActivity = profile.readings
            .filter { (6...9).contains($0.hour) }
            .reduce(0.0) { $0 + $1.activityLevel } / 4.0
        if morningActivity < 0.2 {
            advice.append(RhythmAdvice(
                category: .activity,
                title: "朝の活動量を増やしましょう",
                description: "朝の活動量が低めです。朝の軽い運動やストレッチがリズムの安定に効果的です。",
                priority: .medium
            ))
        }

        // 総歩数に関するアドバイス
        if profile.totalSteps < 5000 {
            advice.append(RhythmAdvice(
                category: .activity,
                title: "もう少し歩きましょう",
                description: "今日の歩数は\(profile.totalSteps)歩です。8,000歩以上を目指すと健康維持に効果的です。",
                priority: .medium
            ))
        }

        return advice
    }
}

/// リズム改善アドバイス
struct RhythmAdvice: Identifiable, Sendable {
    let id = UUID()
    let category: AdviceCategory
    let title: String
    let description: String
    let priority: AdvicePriority

    enum AdviceCategory: String, Sendable {
        case light = "光環境"
        case screen = "スクリーン"
        case activity = "活動量"
        case sleep = "睡眠"

        var systemImageName: String {
            switch self {
            case .light: "sun.max.fill"
            case .screen: "iphone.slash"
            case .activity: "figure.walk"
            case .sleep: "moon.zzz.fill"
            }
        }

        var colorName: String {
            switch self {
            case .light: "yellow"
            case .screen: "blue"
            case .activity: "green"
            case .sleep: "purple"
            }
        }
    }

    enum AdvicePriority: Int, Sendable, Comparable {
        case low = 0
        case medium = 1
        case high = 2

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
