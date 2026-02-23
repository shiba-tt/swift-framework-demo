import SwiftUI

// MARK: - HistoryView

struct HistoryView: View {
    var viewModel: ARFitnessCoachViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.workoutHistory.isEmpty {
                    ContentUnavailableView(
                        "トレーニング履歴なし",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("エクササイズを完了すると履歴が表示されます")
                    )
                } else {
                    ForEach(viewModel.workoutHistory) { session in
                        SessionRow(session: session) {
                            viewModel.selectSession(session)
                        }
                    }
                }
            }
            .navigationTitle("トレーニング履歴")
            .sheet(isPresented: $viewModel.showingSessionDetail) {
                if let session = viewModel.selectedSession {
                    SessionDetailSheet(session: session) {
                        viewModel.showingSessionDetail = false
                    }
                }
            }
        }
    }
}

// MARK: - SessionRow

struct SessionRow: View {
    let session: WorkoutSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(session.exercise.category.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: session.exercise.category.systemImage)
                        .font(.title2)
                        .foregroundStyle(session.exercise.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.exercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(session.startDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(session.completedReps)回 × \(session.completedSets)セット")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Label(String(format: "%.0f kcal", session.caloriesBurned), systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)

                        if let hr = session.peakHeartRate {
                            Label("\(hr) bpm", systemImage: "heart.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(session.formGrade)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(session.formGradeColor)
                    Text("\(Int(session.averageFormScore))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SessionDetailSheet

struct SessionDetailSheet: View {
    let session: WorkoutSession
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    gradeHeader
                    statsGrid
                    exerciseInfo
                }
                .padding()
            }
            .navigationTitle("トレーニング結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる", action: onDismiss)
                }
            }
        }
    }

    private var gradeHeader: some View {
        VStack(spacing: 8) {
            Text(session.formGrade)
                .font(.system(size: 60))
                .fontWeight(.bold)
                .foregroundStyle(session.formGradeColor)

            Text("フォームスコア: \(Int(session.averageFormScore))%")
                .font(.headline)

            Text(session.exercise.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(session.formGradeColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCell(label: "レップ数", value: "\(session.completedReps)回", systemImage: "repeat", color: .blue)
            StatCell(label: "セット数", value: "\(session.completedSets)セット", systemImage: "square.stack.3d.up.fill", color: .green)
            StatCell(label: "消費カロリー", value: String(format: "%.0f kcal", session.caloriesBurned), systemImage: "flame.fill", color: .orange)
            StatCell(label: "経過時間", value: formatDuration(session.duration), systemImage: "timer", color: .purple)
            if let hr = session.peakHeartRate {
                StatCell(label: "最大心拍", value: "\(hr) bpm", systemImage: "heart.fill", color: .red)
            }
            StatCell(label: "実施日", value: session.startDate.formatted(.dateTime.month().day()), systemImage: "calendar", color: .teal)
        }
    }

    private var exerciseInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("エクササイズ情報")
                .font(.headline)
            HStack {
                Label(session.exercise.category.rawValue, systemImage: session.exercise.category.systemImage)
                    .font(.subheadline)
                    .foregroundStyle(session.exercise.category.color)
                Spacer()
                Label(session.exercise.difficulty.rawValue, systemImage: session.exercise.difficulty.systemImage)
                    .font(.subheadline)
                    .foregroundStyle(session.exercise.difficulty.color)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d分%02d秒", minutes, seconds)
    }
}

// MARK: - StatCell

struct StatCell: View {
    let label: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HistoryView(viewModel: ARFitnessCoachViewModel())
}
