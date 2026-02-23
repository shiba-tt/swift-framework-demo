import Foundation

/// フォーム分析結果
struct FormAnalysis: Identifiable, Sendable {
    let id: UUID
    let exercise: Exercise
    let overallScore: Int
    let jointResults: [JointAnalysis]
    let advice: [String]
    let analyzedAt: Date

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        overallScore: Int,
        jointResults: [JointAnalysis],
        advice: [String],
        analyzedAt: Date = Date()
    ) {
        self.id = id
        self.exercise = exercise
        self.overallScore = overallScore
        self.jointResults = jointResults
        self.advice = advice
        self.analyzedAt = analyzedAt
    }

    var scoreGrade: ScoreGrade {
        switch overallScore {
        case 90...100: .excellent
        case 75..<90: .good
        case 60..<75: .fair
        default: .needsWork
        }
    }

    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: analyzedAt)
    }
}

/// 個々の関節の分析結果
struct JointAnalysis: Identifiable, Sendable {
    let id: UUID
    let jointName: String
    let currentAngle: Int
    let idealAngle: Int
    let tolerance: Int
    let score: Int

    init(
        id: UUID = UUID(),
        jointName: String,
        currentAngle: Int,
        idealAngle: Int,
        tolerance: Int,
        score: Int
    ) {
        self.id = id
        self.jointName = jointName
        self.currentAngle = currentAngle
        self.idealAngle = idealAngle
        self.tolerance = tolerance
        self.score = score
    }

    var deviation: Int {
        abs(currentAngle - idealAngle)
    }

    var isWithinRange: Bool {
        deviation <= tolerance
    }

    var status: JointStatus {
        if deviation <= tolerance / 2 {
            return .perfect
        } else if deviation <= tolerance {
            return .acceptable
        } else if deviation <= tolerance * 2 {
            return .warning
        } else {
            return .critical
        }
    }
}

enum JointStatus: String, Sendable {
    case perfect = "完璧"
    case acceptable = "良好"
    case warning = "要改善"
    case critical = "要注意"
}

enum ScoreGrade: String, Sendable {
    case excellent = "素晴らしい"
    case good = "良好"
    case fair = "まずまず"
    case needsWork = "要改善"
}
