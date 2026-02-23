import SwiftUI

// MARK: - ARTrainingView

struct ARTrainingView: View {
    var viewModel: ARFitnessCoachViewModel
    let exercise: Exercise

    var body: some View {
        NavigationStack {
            ZStack {
                arCameraBackground
                bodySkeletonOverlay
                uiOverlay
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.endTraining()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }

    // MARK: - AR Camera Background (Mock)

    private var arCameraBackground: some View {
        LinearGradient(
            colors: [.black.opacity(0.05), exercise.category.color.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Body Skeleton Overlay (Mock)

    private var bodySkeletonOverlay: some View {
        GeometryReader { geo in
            ZStack {
                // ガイドキャラクター（半透明）
                if viewModel.showGuideOverlay {
                    guideCharacter(size: geo.size)
                }

                // 関節ポイント表示
                jointPointsOverlay(size: geo.size)
            }
        }
    }

    private func guideCharacter(size: CGSize) -> some View {
        Image(systemName: exercise.category.systemImage)
            .font(.system(size: 120))
            .foregroundStyle(exercise.category.color.opacity(viewModel.guideOpacity))
            .position(x: size.width / 2, y: size.height * 0.4)
    }

    private func jointPointsOverlay(size: CGSize) -> some View {
        ForEach(viewModel.jointFeedbacks) { feedback in
            let position = mockJointPosition(for: feedback.joint, in: size)
            Circle()
                .fill(feedback.status.color)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: feedback.status.color.opacity(0.6), radius: 4)
                .position(position)
        }
    }

    private func mockJointPosition(for joint: JointName, in size: CGSize) -> CGPoint {
        let cx = size.width / 2
        let cy = size.height * 0.4
        switch joint {
        case .head: return CGPoint(x: cx, y: cy - 80)
        case .neck: return CGPoint(x: cx, y: cy - 60)
        case .leftShoulder: return CGPoint(x: cx - 40, y: cy - 45)
        case .rightShoulder: return CGPoint(x: cx + 40, y: cy - 45)
        case .leftElbow: return CGPoint(x: cx - 55, y: cy - 15)
        case .rightElbow: return CGPoint(x: cx + 55, y: cy - 15)
        case .leftWrist: return CGPoint(x: cx - 65, y: cy + 15)
        case .rightWrist: return CGPoint(x: cx + 65, y: cy + 15)
        case .leftHip: return CGPoint(x: cx - 20, y: cy + 20)
        case .rightHip: return CGPoint(x: cx + 20, y: cy + 20)
        case .leftKnee: return CGPoint(x: cx - 25, y: cy + 55)
        case .rightKnee: return CGPoint(x: cx + 25, y: cy + 55)
        case .leftAnkle: return CGPoint(x: cx - 25, y: cy + 90)
        case .rightAnkle: return CGPoint(x: cx + 25, y: cy + 90)
        case .spine: return CGPoint(x: cx, y: cy - 10)
        }
    }

    // MARK: - UI Overlay

    private var uiOverlay: some View {
        VStack {
            topStatusBar
            Spacer()
            feedbackPanel
            bottomControls
        }
        .padding()
    }

    // MARK: - Top Status Bar

    private var topStatusBar: some View {
        HStack(spacing: 12) {
            // セット/レップ
            VStack(spacing: 2) {
                Text("セット \(viewModel.currentSet)/\(exercise.targetSets)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.currentReps)/\(exercise.targetReps)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()

            // フォームスコア
            VStack(spacing: 2) {
                Text("フォーム")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(viewModel.currentFormScore))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(formScoreColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 心拍数
            VStack(spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Text("\(viewModel.currentHeartRate)")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("bpm")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // タイマー
            VStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(timeString)
                    .font(.headline)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var formScoreColor: Color {
        if viewModel.currentFormScore >= 80 { return .green }
        if viewModel.currentFormScore >= 60 { return .orange }
        return .red
    }

    private var timeString: String {
        let minutes = Int(viewModel.elapsedTime) / 60
        let seconds = Int(viewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Feedback Panel

    private var feedbackPanel: some View {
        VStack(spacing: 8) {
            // 関節フィードバック一覧
            if !viewModel.jointFeedbacks.isEmpty {
                VStack(spacing: 4) {
                    HStack {
                        Label("\(viewModel.correctJoints) OK", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Label("\(viewModel.warningJoints) 注意", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Label("\(viewModel.incorrectJoints) NG", systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Spacer()
                    }

                    // NG/警告の関節を表示
                    ForEach(viewModel.jointFeedbacks.filter { $0.status != .correct }.prefix(3)) { feedback in
                        HStack(spacing: 8) {
                            Image(systemName: feedback.status.systemImage)
                                .foregroundStyle(feedback.status.color)
                            Text(feedback.message)
                                .font(.caption)
                            Spacer()
                        }
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // ガイドTip
            if let tip = viewModel.currentTip {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(tip)
                        .font(.caption)
                    Spacer()
                    Button {
                        viewModel.nextTip()
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 16) {
            // レップカウントボタン
            Button {
                viewModel.countRep()
                Task {
                    await viewModel.updateFormAnalysis(for: exercise)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                    Text("レップ")
                        .font(.caption2)
                }
                .frame(width: 70, height: 60)
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // 一時停止/再開
            Button {
                if viewModel.isPaused {
                    viewModel.resumeTraining()
                } else {
                    viewModel.pauseTraining()
                }
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .frame(width: 50, height: 60)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // 録画
            Button {
                viewModel.toggleRecording()
            } label: {
                Image(systemName: viewModel.isRecording ? "record.circle.fill" : "record.circle")
                    .font(.title2)
                    .frame(width: 50, height: 60)
                    .background(viewModel.isRecording ? .red : Color(.systemGray5))
                    .foregroundStyle(viewModel.isRecording ? .white : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // ガイド表示切替
            Button {
                viewModel.toggleGuideOverlay()
            } label: {
                Image(systemName: viewModel.showGuideOverlay ? "person.fill" : "person")
                    .font(.title2)
                    .frame(width: 50, height: 60)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Spacer()

            // プログレスリング
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: viewModel.setProgress)
                    .stroke(exercise.category.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(viewModel.setProgress * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(width: 50, height: 50)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    let vm = ARFitnessCoachViewModel()
    vm.selectedExercise = Exercise.samples[0]
    vm.isTraining = true
    vm.jointFeedbacks = [
        JointFeedback(joint: .leftKnee, status: .correct, angle: 88, idealAngle: 90, message: "左膝: 正しいフォームです"),
        JointFeedback(joint: .rightKnee, status: .warning, angle: 78, idealAngle: 90, message: "右膝: 少しずれています（12°）"),
        JointFeedback(joint: .spine, status: .incorrect, angle: 150, idealAngle: 170, message: "背骨: フォームを修正してください（20°）"),
    ]
    vm.currentFormScore = 72
    return ARTrainingView(viewModel: vm, exercise: Exercise.samples[0])
}
