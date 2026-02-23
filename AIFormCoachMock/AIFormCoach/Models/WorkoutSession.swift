import Foundation

/// ワークアウトセッション
struct WorkoutSession: Identifiable, Sendable {
    let id: UUID
    let exercise: Exercise
    var repCount: Int
    var analyses: [FormAnalysis]
    let startedAt: Date

    init(
        id: UUID = UUID(),
        exercise: Exercise
    ) {
        self.id = id
        self.exercise = exercise
        self.repCount = 0
        self.analyses = []
        self.startedAt = Date()
    }

    var latestAnalysis: FormAnalysis? {
        analyses.last
    }

    var averageScore: Int {
        guard !analyses.isEmpty else { return 0 }
        return analyses.map(\.overallScore).reduce(0, +) / analyses.count
    }

    var bestScore: Int {
        analyses.map(\.overallScore).max() ?? 0
    }

    var durationText: String {
        let duration = Date().timeIntervalSince(startedAt)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// トレーニング履歴の日別サマリー
struct DailyWorkoutSummary: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let exerciseSummaries: [ExerciseSummary]

    init(
        id: UUID = UUID(),
        date: Date,
        exerciseSummaries: [ExerciseSummary]
    ) {
        self.id = id
        self.date = date
        self.exerciseSummaries = exerciseSummaries
    }

    var totalReps: Int {
        exerciseSummaries.map(\.reps).reduce(0, +)
    }

    var averageScore: Int {
        guard !exerciseSummaries.isEmpty else { return 0 }
        return exerciseSummaries.map(\.averageScore).reduce(0, +) / exerciseSummaries.count
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

/// エクササイズ別サマリー
struct ExerciseSummary: Identifiable, Sendable {
    let id: UUID
    let exercise: Exercise
    let reps: Int
    let averageScore: Int
    let bestScore: Int

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        reps: Int,
        averageScore: Int,
        bestScore: Int
    ) {
        self.id = id
        self.exercise = exercise
        self.reps = reps
        self.averageScore = averageScore
        self.bestScore = bestScore
    }
}
