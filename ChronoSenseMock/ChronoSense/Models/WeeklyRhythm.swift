import Foundation

/// 週間リズムレポート
struct WeeklyRhythm: Identifiable, Sendable {
    let id = UUID()
    let weekStartDate: Date
    let profiles: [CircadianProfile]

    /// 週間平均リズムスコア
    var averageScore: Int {
        guard !profiles.isEmpty else { return 0 }
        return profiles.reduce(0) { $0 + $1.rhythmScore } / profiles.count
    }

    /// 最も安定した日
    var mostStableDay: CircadianProfile? {
        profiles.max(by: { $0.rhythmScore < $1.rhythmScore })
    }

    /// 最も乱れた日
    var leastStableDay: CircadianProfile? {
        profiles.min(by: { $0.rhythmScore < $1.rhythmScore })
    }

    /// 平均就寝時間（hour）
    var averageSleepOnsetHour: Int {
        guard !profiles.isEmpty else { return 23 }
        let sleepOnsets = profiles.compactMap { profile -> Int? in
            // 21時〜翌4時の間で最初に睡眠が始まった時間
            let nightHours = [21, 22, 23, 0, 1, 2, 3, 4]
            return nightHours.first { hour in profile.sleepHours.contains(hour) }
        }
        guard !sleepOnsets.isEmpty else { return 23 }
        return sleepOnsets.reduce(0, +) / sleepOnsets.count
    }

    /// 平均起床時間（hour）
    var averageWakeHour: Int {
        guard !profiles.isEmpty else { return 7 }
        let wakeHours = profiles.compactMap { profile -> Int? in
            // 5時〜11時の間で最初に活動が始まった時間
            let morningHours = [5, 6, 7, 8, 9, 10, 11]
            return morningHours.first { hour in profile.activeHours.contains(hour) }
        }
        guard !wakeHours.isEmpty else { return 7 }
        return wakeHours.reduce(0, +) / wakeHours.count
    }

    /// スコアの週内変動（標準偏差）
    var scoreVariance: Double {
        guard profiles.count > 1 else { return 0 }
        let mean = Double(averageScore)
        let sumOfSquares = profiles.reduce(0.0) { $0 + pow(Double($1.rhythmScore) - mean, 2) }
        return (sumOfSquares / Double(profiles.count)).squareRoot()
    }

    /// 改善トレンドかどうか
    var isImproving: Bool {
        guard profiles.count >= 3 else { return false }
        let lastThree = profiles.suffix(3)
        let firstScore = lastThree.first?.rhythmScore ?? 0
        let lastScore = lastThree.last?.rhythmScore ?? 0
        return lastScore > firstScore
    }
}
