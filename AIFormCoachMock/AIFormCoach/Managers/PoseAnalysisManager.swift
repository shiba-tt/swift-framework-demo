import Foundation

/// 姿勢推定とフォーム分析を担当するマネージャー
@MainActor
@Observable
final class PoseAnalysisManager {
    static let shared = PoseAnalysisManager()

    // MARK: - Observable State

    private(set) var activeSession: WorkoutSession?
    private(set) var isAnalyzing = false
    private(set) var history: [DailyWorkoutSummary] = []

    private init() {
        generateSampleHistory()
    }

    // MARK: - Session Management

    func startSession(exercise: Exercise) {
        activeSession = WorkoutSession(exercise: exercise)
    }

    func endSession() {
        activeSession = nil
        isAnalyzing = false
    }

    // MARK: - Analysis

    func analyzeCurrentForm() {
        guard var session = activeSession else { return }
        isAnalyzing = true

        // モックデータ: 姿勢推定結果をシミュレーション
        let analysis = generateMockAnalysis(for: session.exercise)
        session.analyses.append(analysis)
        session.repCount += 1
        activeSession = session

        // 分析完了のシミュレーション
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            self.isAnalyzing = false
        }
    }

    // MARK: - Query

    var totalWorkouts: Int {
        history.reduce(0) { $0 + $1.exerciseSummaries.count }
    }

    var overallAverageScore: Int {
        let scores = history.flatMap { $0.exerciseSummaries.map(\.averageScore) }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    var totalRepsAllTime: Int {
        history.reduce(0) { $0 + $1.totalReps }
    }

    func bestScoreForExercise(_ exercise: Exercise) -> Int {
        history.flatMap { $0.exerciseSummaries }
            .filter { $0.exercise == exercise }
            .map(\.bestScore)
            .max() ?? 0
    }

    // MARK: - Mock Data Generation

    private func generateMockAnalysis(for exercise: Exercise) -> FormAnalysis {
        let jointResults = exercise.targetJoints.map { joint in
            let deviation = Int.random(in: -joint.tolerance * 2...joint.tolerance * 2)
            let currentAngle = joint.idealAngle + deviation
            let absDev = abs(deviation)
            let score: Int
            if absDev <= joint.tolerance / 2 {
                score = Int.random(in: 90...100)
            } else if absDev <= joint.tolerance {
                score = Int.random(in: 75...89)
            } else if absDev <= joint.tolerance * 2 {
                score = Int.random(in: 55...74)
            } else {
                score = Int.random(in: 30...54)
            }

            return JointAnalysis(
                jointName: joint.name,
                currentAngle: max(0, min(180, currentAngle)),
                idealAngle: joint.idealAngle,
                tolerance: joint.tolerance,
                score: score
            )
        }

        let overallScore = jointResults.map(\.score).reduce(0, +) / max(jointResults.count, 1)

        let advice = generateAdvice(for: exercise, jointResults: jointResults)

        return FormAnalysis(
            exercise: exercise,
            overallScore: overallScore,
            jointResults: jointResults,
            advice: advice
        )
    }

    private func generateAdvice(for exercise: Exercise, jointResults: [JointAnalysis]) -> [String] {
        var advice: [String] = []

        for result in jointResults {
            if result.status == .warning || result.status == .critical {
                let direction = result.currentAngle > result.idealAngle ? "浅すぎ" : "深すぎ"
                advice.append(
                    "\(result.jointName)の角度が\(direction)です（現在 \(result.currentAngle)°、理想 \(result.idealAngle)°）。"
                )
            }
        }

        if advice.isEmpty {
            advice.append("素晴らしいフォームです！この調子で続けましょう。")
        }

        // エクササイズ固有のアドバイスを追加
        let tip = exercise.tips.randomElement() ?? ""
        if !tip.isEmpty {
            advice.append("ヒント: \(tip)")
        }

        return advice
    }

    private func generateSampleHistory() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }

            // 各日にランダムな数のエクササイズ
            let exerciseCount = Int.random(in: 1...3)
            let selectedExercises = Array(Exercise.allCases.shuffled().prefix(exerciseCount))

            let summaries = selectedExercises.map { exercise in
                let reps = Int.random(in: 5...20)
                let avgScore = Int.random(in: 60...95)
                let bestScore = min(100, avgScore + Int.random(in: 5...15))
                return ExerciseSummary(
                    exercise: exercise,
                    reps: reps,
                    averageScore: avgScore,
                    bestScore: bestScore
                )
            }

            history.append(DailyWorkoutSummary(date: date, exerciseSummaries: summaries))
        }
    }
}
