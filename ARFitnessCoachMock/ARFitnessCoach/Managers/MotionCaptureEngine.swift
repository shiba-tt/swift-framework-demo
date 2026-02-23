import Foundation
import SwiftUI

// MARK: - MotionCaptureEngine

/// ARKit の Motion Capture + People Occlusion を使用して
/// リアルタイムに関節位置を追跡しフォーム分析を行うエンジン（モック）
@MainActor
@Observable
final class MotionCaptureEngine {

    static let shared = MotionCaptureEngine()

    private init() {}

    // MARK: - State

    var isTracking = false
    var detectedJointCount = 0
    var trackingConfidence: Double = 0.0

    // MARK: - Motion Capture (Mock)

    /// モーションキャプチャを開始（モック）
    func startTracking() async {
        isTracking = true
        try? await Task.sleep(for: .seconds(0.8))
        detectedJointCount = 93
        trackingConfidence = Double.random(in: 0.85...0.98)
    }

    /// モーションキャプチャを停止
    func stopTracking() {
        isTracking = false
        detectedJointCount = 0
        trackingConfidence = 0
    }

    /// 現在のフォームを分析して関節フィードバックを返す（モック）
    func analyzeForm(for exercise: Exercise) async -> [JointFeedback] {
        try? await Task.sleep(for: .seconds(0.3))

        return exercise.trackedJoints.map { joint in
            let idealAngle = idealAngle(for: joint, exercise: exercise)
            let currentAngle = idealAngle + Double.random(in: -20...20)
            let deviation = abs(currentAngle - idealAngle)

            let status: JointStatus
            let message: String

            if deviation < 5 {
                status = .correct
                message = "\(joint.rawValue): 正しいフォームです"
            } else if deviation < 15 {
                status = .warning
                message = "\(joint.rawValue): 少しずれています（\(String(format: "%.0f", deviation))°）"
            } else {
                status = .incorrect
                message = "\(joint.rawValue): フォームを修正してください（\(String(format: "%.0f", deviation))°）"
            }

            return JointFeedback(
                joint: joint,
                status: status,
                angle: currentAngle,
                idealAngle: idealAngle,
                message: message
            )
        }
    }

    /// フォームスコアを計算（モック）
    func calculateFormScore(feedbacks: [JointFeedback]) -> Double {
        guard !feedbacks.isEmpty else { return 0 }

        let totalDeviation = feedbacks.reduce(0.0) { $0 + $1.deviation }
        let avgDeviation = totalDeviation / Double(feedbacks.count)
        let score = max(0, 100 - avgDeviation * 3)
        return min(score, 100)
    }

    /// レップ検出（モック）
    func detectRep(for exercise: Exercise) async -> Bool {
        try? await Task.sleep(for: .seconds(0.1))
        return Double.random(in: 0...1) > 0.3
    }

    // MARK: - Private

    private func idealAngle(for joint: JointName, exercise: Exercise) -> Double {
        switch (exercise.category, joint) {
        case (.squat, .leftKnee), (.squat, .rightKnee): return 90
        case (.squat, .leftHip), (.squat, .rightHip): return 90
        case (.squat, .spine): return 170
        case (.pushup, .leftElbow), (.pushup, .rightElbow): return 90
        case (.pushup, .spine): return 180
        case (.lunge, .leftKnee), (.lunge, .rightKnee): return 90
        case (.plank, .spine): return 180
        case (.deadlift, .leftHip), (.deadlift, .rightHip): return 90
        case (.deadlift, .spine): return 170
        default: return 160
        }
    }
}
