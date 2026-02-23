import SwiftUI

struct GenerationProgressView: View {
    @Bindable var viewModel: ReelForgeViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                phaseIcon
                phaseInfo
                progressSection
                pipelineVisualization
                detailSection

                Spacer()

                actionButtons
            }
            .padding()
            .navigationTitle("リール生成")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Phase Icon

    private var phaseIcon: some View {
        ZStack {
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 100, height: 100)

            if viewModel.isProcessing {
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.overallProgress)
            }

            Text(viewModel.currentPhase.emoji)
                .font(.system(size: 40))
                .symbolEffect(.pulse, isActive: viewModel.isProcessing)
        }
    }

    // MARK: - Phase Info

    private var phaseInfo: some View {
        VStack(spacing: 8) {
            Text(viewModel.currentPhase.rawValue)
                .font(.title3.bold())
                .contentTransition(.numericText())

            Text(String(format: "%.0f%%", viewModel.overallProgress * 100))
                .font(.headline)
                .foregroundStyle(.purple)
                .contentTransition(.numericText())
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.overallProgress)
                .tint(.purple)
                .animation(.easeInOut(duration: 0.3), value: viewModel.overallProgress)

            HStack {
                Text("AI分析")
                    .font(.caption2)
                    .foregroundStyle(viewModel.isAnalyzing ? .purple : .secondary)
                Spacer()
                Text("合成")
                    .font(.caption2)
                    .foregroundStyle(viewModel.isComposing ? .purple : .secondary)
                Spacer()
                Text("書出し")
                    .font(.caption2)
                    .foregroundStyle(viewModel.currentPhase == .completed ? .purple : .secondary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Pipeline Visualization

    private var pipelineVisualization: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("生成パイプライン")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    pipelineStep("Photos", icon: "photo.stack", done: phaseOrder >= 1)
                    pipelineArrow
                    pipelineStep("Vision", icon: "eye", done: phaseOrder >= 3)
                    pipelineArrow
                    pipelineStep("Core ML", icon: "brain", done: phaseOrder >= 5)
                    pipelineArrow
                    pipelineStep("AVComp", icon: "film", done: phaseOrder >= 8)
                    pipelineArrow
                    pipelineStep("Export", icon: "square.and.arrow.up", done: phaseOrder >= 12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    private var phaseOrder: Int {
        switch viewModel.currentPhase {
        case .idle: return 0
        case .importingMedia: return 1
        case .detectingFaces: return 2
        case .classifyingScenes: return 3
        case .scoringStability: return 4
        case .analyzingAudio: return 5
        case .selectingBestShots: return 6
        case .composingTimeline: return 7
        case .syncingBeats: return 8
        case .applyingTransitions: return 9
        case .addingOverlays: return 10
        case .rendering: return 11
        case .completed: return 12
        }
    }

    private func pipelineStep(_ label: String, icon: String, done: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 28, height: 28)
                .background(done ? Color.purple.opacity(0.2) : Color(.systemGray5), in: Circle())
                .foregroundStyle(done ? .purple : .secondary)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(done ? .primary : .secondary)
        }
    }

    private var pipelineArrow: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 8))
            .foregroundStyle(.secondary)
    }

    // MARK: - Detail

    private var detailSection: some View {
        Group {
            if let project = viewModel.selectedProject {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(project.title, systemImage: "film")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(project.status.emoji + " " + project.status.rawValue)
                            .font(.caption)
                            .foregroundStyle(project.status.color)
                    }

                    HStack(spacing: 16) {
                        Label("\(project.clipCount)クリップ", systemImage: "photo.on.rectangle")
                        Label(project.bgmTrack.name, systemImage: "music.note")
                        Label(project.transitionStyle.rawValue, systemImage: "arrow.triangle.swap")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 16) {
            if viewModel.isProcessing {
                Button(role: .destructive) {
                    viewModel.cancelGeneration()
                } label: {
                    Text("キャンセル")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            } else if viewModel.currentPhase == .completed {
                Button {
                    viewModel.showGenerationSheet = false
                    viewModel.showExportConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("SNS に共有")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .bold()
                }

                Button {
                    viewModel.showGenerationSheet = false
                } label: {
                    Text("閉じる")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
