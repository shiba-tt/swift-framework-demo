import SwiftUI

// MARK: - ExerciseListView

struct ExerciseListView: View {
    var viewModel: ARFitnessCoachViewModel

    var body: some View {
        NavigationStack {
            List {
                categoryFilter
                exercisesSection
            }
            .navigationTitle("エクササイズ")
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryChip(
                        label: "すべて",
                        systemImage: "square.grid.2x2",
                        color: .gray,
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            label: category.rawValue,
                            systemImage: category.systemImage,
                            color: category.color,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Exercises Section

    private var exercisesSection: some View {
        Section("種目 (\(viewModel.filteredExercises.count))") {
            ForEach(viewModel.filteredExercises) { exercise in
                ExerciseRow(exercise: exercise) {
                    viewModel.selectExercise(exercise)
                }
            }
        }
    }
}

// MARK: - ExerciseRow

struct ExerciseRow: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(exercise.category.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: exercise.category.systemImage)
                        .font(.title2)
                        .foregroundStyle(exercise.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Label(exercise.difficulty.rawValue, systemImage: exercise.difficulty.systemImage)
                            .font(.caption)
                            .foregroundStyle(exercise.difficulty.color)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(exercise.targetReps)回 × \(exercise.targetSets)セット")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        ForEach(exercise.trackedJoints.prefix(4), id: \.self) { joint in
                            Text(joint.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(joint.color.opacity(0.15))
                                .foregroundStyle(joint.color)
                                .clipShape(Capsule())
                        }
                        if exercise.trackedJoints.count > 4 {
                            Text("+\(exercise.trackedJoints.count - 4)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CategoryChip

struct CategoryChip: View {
    let label: String
    let systemImage: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ExerciseDetailSheet

struct ExerciseDetailSheet: View {
    var viewModel: ARFitnessCoachViewModel
    let exercise: Exercise

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    descriptionSection
                    targetSection
                    jointsSection
                    tipsSection
                    startButton
                }
                .padding()
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.deselectExercise()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Label(exercise.category.rawValue, systemImage: exercise.category.systemImage)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(exercise.category.color.opacity(0.15))
                .foregroundStyle(exercise.category.color)
                .clipShape(Capsule())

            Label(exercise.difficulty.rawValue, systemImage: exercise.difficulty.systemImage)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(exercise.difficulty.color.opacity(0.15))
                .foregroundStyle(exercise.difficulty.color)
                .clipShape(Capsule())
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("概要")
                .font(.headline)
            Text(exercise.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("目標")
                .font(.headline)

            HStack(spacing: 16) {
                TargetCard(value: "\(exercise.targetReps)", label: "回数", systemImage: "repeat", color: .blue)
                TargetCard(value: "\(exercise.targetSets)", label: "セット", systemImage: "square.stack.3d.up.fill", color: .green)
                TargetCard(
                    value: String(format: "%.0f", Double(exercise.targetReps * exercise.targetSets) * exercise.caloriesPerRep),
                    label: "kcal",
                    systemImage: "flame.fill",
                    color: .orange
                )
            }
        }
    }

    private var jointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("トラッキング関節")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(exercise.trackedJoints, id: \.self) { joint in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(joint.color)
                            .frame(width: 8, height: 8)
                        Text(joint.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("フォームのポイント")
                .font(.headline)

            ForEach(Array(exercise.guideTips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(exercise.category.color)
                        .clipShape(Circle())

                    Text(tip)
                        .font(.subheadline)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            Task {
                await viewModel.startTraining()
            }
        } label: {
            Label("トレーニングを開始", systemImage: "arkit")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - TargetCard

struct TargetCard: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ExerciseListView(viewModel: ARFitnessCoachViewModel())
}
