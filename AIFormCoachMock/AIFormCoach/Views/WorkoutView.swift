import SwiftUI

struct WorkoutView: View {
    @Bindable var viewModel: AIFormCoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    aiCoachBanner
                    exerciseSelector
                    exerciseDetail
                    startButton
                }
                .padding()
            }
            .navigationTitle("ワークアウト")
        }
    }

    // MARK: - AI Coach Banner

    private var aiCoachBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan)
                Text("AI フォームコーチ")
                    .font(.headline)
            }

            Text("カメラでリアルタイムに骨格を検出し、理想のフォームとの差分を AI が分析。自然言語で改善アドバイスを生成します。")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                featureChip("Vision", icon: "eye.fill")
                featureChip("Core ML", icon: "cpu.fill")
                featureChip("AI 解説", icon: "text.bubble.fill")
            }
        }
        .padding()
        .background(.cyan.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func featureChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.cyan.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - Exercise Selector

    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("エクササイズを選択")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Exercise.allCases) { exercise in
                    exerciseCard(exercise)
                }
            }
        }
    }

    private func exerciseCard(_ exercise: Exercise) -> some View {
        let isSelected = viewModel.selectedExercise == exercise
        let bestScore = viewModel.bestScore(for: exercise)

        return Button {
            withAnimation(.spring(duration: 0.2)) {
                viewModel.selectedExercise = exercise
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: exercise.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : exercise.color)

                Text(exercise.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(isSelected ? .white : .primary)

                if bestScore > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 10))
                        Text("\(bestScore)")
                            .font(.caption2.monospacedDigit())
                    }
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? exercise.color : .ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Exercise Detail

    private var exerciseDetail: some View {
        let exercise = viewModel.selectedExercise

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: exercise.icon)
                    .foregroundStyle(exercise.color)
                Text(exercise.rawValue)
                    .font(.headline)
            }

            // 監視する関節
            Text("監視する関節")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            ForEach(exercise.targetJoints) { joint in
                HStack(spacing: 12) {
                    Image(systemName: "angle")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                        .frame(width: 20)

                    Text(joint.name)
                        .font(.subheadline)

                    Spacer()

                    Text("理想: \(joint.idealAngle)° ± \(joint.tolerance)°")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // ポイント
            Text("フォームのポイント")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            ForEach(Array(exercise.tips.enumerated()), id: \.offset) { _, tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.top, 2)
                    Text(tip)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            viewModel.startSession()
        } label: {
            Label("フォームチェック開始", systemImage: "camera.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(.cyan)
    }
}

#Preview {
    WorkoutView(viewModel: AIFormCoachViewModel())
}
