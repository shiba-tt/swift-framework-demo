import SwiftUI

struct StageListView: View {
    var viewModel: ARShadowViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    progressCard
                }

                Section("ステージ一覧") {
                    ForEach(viewModel.stages) { stage in
                        StageRow(stage: stage) {
                            viewModel.selectStage(stage)
                        }
                    }
                }
            }
            .navigationTitle("AR シャドウ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingCoop = true
                    } label: {
                        Image(systemName: "person.2.fill")
                    }
                }
            }
            .sheet(item: $viewModel.selectedStage) { stage in
                StageDetailSheet(viewModel: viewModel, stage: stage)
            }
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("進捗")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.completedStages) / \(viewModel.stages.count)")
                        .font(.title.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("スター")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.totalStars) / \(viewModel.maxStars)")
                            .font(.title.bold())
                    }
                }
            }

            ProgressView(value: Double(viewModel.completedStages), total: Double(viewModel.stages.count))
                .tint(.orange)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - StageRow

struct StageRow: View {
    let stage: PuzzleStage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Target shape icon
                ZStack {
                    Circle()
                        .fill(stage.isUnlocked ? stage.targetShape.color.opacity(0.15) : .gray.opacity(0.1))
                        .frame(width: 50, height: 50)

                    if stage.isUnlocked {
                        Image(systemName: stage.targetShape.systemImage)
                            .font(.title2)
                            .foregroundStyle(stage.targetShape.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.name)
                        .font(.headline)
                        .foregroundStyle(stage.isUnlocked ? .primary : .secondary)

                    HStack(spacing: 8) {
                        Label(stage.difficulty.rawValue, systemImage: stage.difficulty.systemImage)
                            .font(.caption)
                            .foregroundStyle(stage.difficulty.color)

                        if let timeLimit = stage.timeLimit {
                            Label("\(Int(timeLimit))秒", systemImage: "timer")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // Star rating
                if stage.isUnlocked {
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { star in
                            Image(systemName: star <= stage.starRating ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(star <= stage.starRating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
        }
        .disabled(!stage.isUnlocked)
    }
}

// MARK: - StageDetailSheet

struct StageDetailSheet: View {
    var viewModel: ARShadowViewModel
    let stage: PuzzleStage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Target shape preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.black)
                        .frame(height: 200)

                    VStack(spacing: 16) {
                        Image(systemName: stage.targetShape.systemImage)
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("目標: \(stage.targetShape.rawValue)の影")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)

                // Stage info
                VStack(spacing: 12) {
                    InfoRow(label: "難易度", value: stage.difficulty.rawValue, color: stage.difficulty.color)
                    InfoRow(label: "目標精度", value: "\(Int(stage.requiredAccuracy * 100))%以上", color: .blue)
                    InfoRow(label: "使用可能オブジェクト", value: "\(stage.allowedObjects)個", color: .purple)

                    if let timeLimit = stage.timeLimit {
                        InfoRow(label: "制限時間", value: "\(Int(timeLimit))秒", color: .red)
                    }

                    if let best = stage.bestScore {
                        InfoRow(label: "ベストスコア", value: "\(best)%", color: .orange)
                    }
                }
                .padding(.horizontal)

                Text(stage.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Button {
                    dismiss()
                    viewModel.startGame()
                } label: {
                    Label("パズル開始", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle(stage.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    StageListView(viewModel: ARShadowViewModel())
}
