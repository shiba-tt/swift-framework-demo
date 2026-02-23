import SwiftUI

@MainActor
@Observable
final class ReelForgeViewModel {

    // MARK: - Tab

    enum Tab: String, Sendable {
        case create = "作成"
        case projects = "プロジェクト"
        case library = "ライブラリ"
    }

    var selectedTab: Tab = .create

    // MARK: - State

    var selectedBGM: BGMTrack?
    var selectedTransition: TransitionStyle = .beatSync
    var selectedDuration: TargetDuration = .standard45
    var projectTitle: String = ""
    var showBGMPicker = false
    var showGenerationSheet = false
    var showProjectDetail = false
    var selectedProject: ReelProject?
    var showExportConfirmation = false

    private let manager = MovieGeneratorManager.shared

    // MARK: - Proxied State

    var clips: [MediaClip] { manager.clips }
    var projects: [ReelProject] { manager.projects }
    var availableBGMs: [BGMTrack] { manager.availableBGMs }
    var isAnalyzing: Bool { manager.isAnalyzing }
    var isComposing: Bool { manager.isComposing }
    var analysisProgress: Double { manager.analysisProgress }
    var compositionProgress: Double { manager.compositionProgress }
    var currentPhase: MovieGeneratorManager.GenerationPhase { manager.currentPhase }
    var selectedClipCount: Int { manager.selectedClipCount }
    var totalSelectedDurationText: String { manager.totalSelectedDurationText }

    var isProcessing: Bool { isAnalyzing || isComposing }

    var sceneCategorySummary: [(SceneCategory, Int)] { manager.sceneCategorySummary }

    // MARK: - Computed

    var canGenerate: Bool {
        selectedClipCount >= 2 && selectedBGM != nil
    }

    var overallProgress: Double {
        if isAnalyzing {
            return analysisProgress
        } else if isComposing {
            return 0.55 + compositionProgress * 0.45
        }
        return 0
    }

    // MARK: - Actions

    func toggleClipSelection(_ clip: MediaClip) {
        manager.toggleClipSelection(clip)
    }

    func startGeneration() {
        let title = projectTitle.isEmpty ? "新しいリール" : projectTitle
        let bgm = selectedBGM ?? BGMTrack.samples[0]
        let project = manager.createProject(
            title: title, bgm: bgm,
            transition: selectedTransition,
            duration: selectedDuration
        )
        selectedProject = project
        showGenerationSheet = true
        manager.startAnalysis()

        // After analysis, start composition automatically
        Task {
            while manager.isAnalyzing {
                try? await Task.sleep(for: .milliseconds(200))
            }
            if let proj = manager.projects.first(where: { $0.id == project.id }) {
                manager.startComposition(project: proj)
            }
        }
    }

    func cancelGeneration() {
        manager.cancelGeneration()
        showGenerationSheet = false
    }

    func deleteProject(_ project: ReelProject) {
        manager.deleteProject(project)
    }

    func selectBGM(_ bgm: BGMTrack) {
        selectedBGM = bgm
        showBGMPicker = false
    }
}
