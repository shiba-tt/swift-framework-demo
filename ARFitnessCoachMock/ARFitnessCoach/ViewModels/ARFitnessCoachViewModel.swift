import Foundation
import SwiftUI

// MARK: - ARFitnessCoachViewModel

@MainActor
@Observable
final class ARFitnessCoachViewModel {

    // MARK: - State

    var exercises: [Exercise] = Exercise.samples
    var selectedExercise: Exercise?
    var isTraining = false
    var isPaused = false
    var isARActive = false
    var isRecording = false

    // Workout State
    var currentReps = 0
    var currentSet = 1
    var elapsedTime: TimeInterval = 0
    var currentFormScore: Double = 0.0
    var jointFeedbacks: [JointFeedback] = []

    // Guide
    var showGuideOverlay = true
    var guideOpacity: Double = 0.5
    var currentTipIndex = 0

    // History
    var workoutHistory: [WorkoutSession] = WorkoutSession.samples
    var showingSessionDetail = false
    var selectedSession: WorkoutSession?

    // Sheets
    var showingExerciseDetail = false
    var showingResult = false
    var lastSession: WorkoutSession?

    // Filter
    var selectedCategory: ExerciseCategory?

    // Heart Rate (Apple Watch mock)
    var currentHeartRate: Int = 72
    var peakHeartRate: Int = 72

    // MARK: - Dependencies

    let motionEngine = MotionCaptureEngine.shared

    // MARK: - Computed

    var filteredExercises: [Exercise] {
        guard let category = selectedCategory else { return exercises }
        return exercises.filter { $0.category == category }
    }

    var correctJoints: Int {
        jointFeedbacks.filter { $0.status == .correct }.count
    }

    var warningJoints: Int {
        jointFeedbacks.filter { $0.status == .warning }.count
    }

    var incorrectJoints: Int {
        jointFeedbacks.filter { $0.status == .incorrect }.count
    }

    var totalCaloriesBurned: Double {
        guard let exercise = selectedExercise else { return 0 }
        return Double(currentReps) * exercise.caloriesPerRep
    }

    var currentTip: String? {
        guard let exercise = selectedExercise,
              !exercise.guideTips.isEmpty else { return nil }
        return exercise.guideTips[currentTipIndex % exercise.guideTips.count]
    }

    var remainingReps: Int {
        guard let exercise = selectedExercise else { return 0 }
        return max(exercise.targetReps - currentReps, 0)
    }

    var setProgress: Double {
        guard let exercise = selectedExercise, exercise.targetReps > 0 else { return 0 }
        return Double(currentReps) / Double(exercise.targetReps)
    }

    var totalWorkouts: Int {
        workoutHistory.count
    }

    var averageFormScore: Double {
        guard !workoutHistory.isEmpty else { return 0 }
        return workoutHistory.reduce(0) { $0 + $1.averageFormScore } / Double(workoutHistory.count)
    }

    var totalCaloriesHistory: Double {
        workoutHistory.reduce(0) { $0 + $1.caloriesBurned }
    }

    // MARK: - Exercise Selection

    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        showingExerciseDetail = true
    }

    func deselectExercise() {
        selectedExercise = nil
        showingExerciseDetail = false
    }

    // MARK: - Training Actions

    func startTraining() async {
        guard let exercise = selectedExercise else { return }
        showingExerciseDetail = false
        isTraining = true
        isPaused = false
        isARActive = true
        currentReps = 0
        currentSet = 1
        elapsedTime = 0
        currentFormScore = 0
        jointFeedbacks = []
        currentHeartRate = Int.random(in: 70...80)
        peakHeartRate = currentHeartRate

        await motionEngine.startTracking()
        await updateFormAnalysis(for: exercise)
    }

    func pauseTraining() {
        isPaused = true
    }

    func resumeTraining() {
        isPaused = false
    }

    func endTraining() {
        guard let exercise = selectedExercise else { return }

        motionEngine.stopTracking()

        let session = WorkoutSession(
            exercise: exercise,
            startDate: Date().addingTimeInterval(-elapsedTime),
            endDate: Date(),
            completedReps: currentReps,
            completedSets: currentSet,
            averageFormScore: currentFormScore,
            caloriesBurned: totalCaloriesBurned,
            peakHeartRate: peakHeartRate
        )

        workoutHistory.insert(session, at: 0)
        lastSession = session

        isTraining = false
        isARActive = false
        isRecording = false
        showingResult = true
    }

    func dismissResult() {
        showingResult = false
        lastSession = nil
        selectedExercise = nil
    }

    // MARK: - Form Analysis

    func updateFormAnalysis(for exercise: Exercise) async {
        jointFeedbacks = await motionEngine.analyzeForm(for: exercise)
        currentFormScore = motionEngine.calculateFormScore(feedbacks: jointFeedbacks)
    }

    // MARK: - Rep & Set Tracking

    func countRep() {
        guard let exercise = selectedExercise else { return }
        currentReps += 1

        if currentReps >= exercise.targetReps {
            if currentSet < exercise.targetSets {
                currentSet += 1
                currentReps = 0
            } else {
                endTraining()
            }
        }
    }

    // MARK: - Timer

    func tick() {
        guard isTraining, !isPaused else { return }
        elapsedTime += 1

        // モック: 心拍数変動
        let heartDelta = Int.random(in: -2...3)
        currentHeartRate = max(65, min(180, currentHeartRate + heartDelta))
        if currentHeartRate > peakHeartRate {
            peakHeartRate = currentHeartRate
        }
    }

    // MARK: - Guide

    func nextTip() {
        currentTipIndex += 1
    }

    func toggleGuideOverlay() {
        showGuideOverlay.toggle()
    }

    func setGuideOpacity(_ opacity: Double) {
        guideOpacity = opacity
    }

    // MARK: - Recording

    func toggleRecording() {
        isRecording.toggle()
    }

    // MARK: - History

    func selectSession(_ session: WorkoutSession) {
        selectedSession = session
        showingSessionDetail = true
    }
}
