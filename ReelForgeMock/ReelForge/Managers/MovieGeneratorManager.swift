import SwiftUI

/// AI ショートムービー自動生成の処理を管理するマネージャー
///
/// Photos Framework / Vision / Core ML / AVComposition / AVAudioEngine を
/// 組み合わせた生成パイプラインをモックで再現する。
@MainActor
@Observable
final class MovieGeneratorManager {

    static let shared = MovieGeneratorManager()

    // MARK: - State

    private(set) var isAnalyzing = false
    private(set) var isComposing = false
    private(set) var analysisProgress: Double = 0
    private(set) var compositionProgress: Double = 0
    private(set) var currentPhase: GenerationPhase = .idle

    private(set) var clips: [MediaClip] = MediaClip.samples
    private(set) var availableBGMs: [BGMTrack] = BGMTrack.samples
    private(set) var projects: [ReelProject] = []

    private var analysisTimer: Timer?
    private var compositionTimer: Timer?

    private init() {
        projects = [ReelProject.sample]
    }

    // MARK: - Generation Phase

    enum GenerationPhase: String, Sendable {
        case idle = "待機中"
        case importingMedia = "メディア読込中"
        case detectingFaces = "笑顔検出中"
        case classifyingScenes = "シーン分類中"
        case scoringStability = "手ブレ解析中"
        case analyzingAudio = "音声解析中"
        case selectingBestShots = "ベストショット選定中"
        case composingTimeline = "タイムライン生成中"
        case syncingBeats = "ビート同期中"
        case applyingTransitions = "トランジション適用中"
        case addingOverlays = "テロップ配置中"
        case rendering = "レンダリング中"
        case completed = "完了"

        var emoji: String {
            switch self {
            case .idle: return "💤"
            case .importingMedia: return "📥"
            case .detectingFaces: return "😊"
            case .classifyingScenes: return "🏷️"
            case .scoringStability: return "📐"
            case .analyzingAudio: return "🔊"
            case .selectingBestShots: return "⭐"
            case .composingTimeline: return "🎞️"
            case .syncingBeats: return "🎵"
            case .applyingTransitions: return "🌀"
            case .addingOverlays: return "✏️"
            case .rendering: return "⚙️"
            case .completed: return "✅"
            }
        }

        var progress: Double {
            switch self {
            case .idle: return 0
            case .importingMedia: return 0.05
            case .detectingFaces: return 0.15
            case .classifyingScenes: return 0.25
            case .scoringStability: return 0.35
            case .analyzingAudio: return 0.45
            case .selectingBestShots: return 0.55
            case .composingTimeline: return 0.65
            case .syncingBeats: return 0.75
            case .applyingTransitions: return 0.82
            case .addingOverlays: return 0.90
            case .rendering: return 0.95
            case .completed: return 1.0
            }
        }
    }

    // MARK: - Analysis

    func startAnalysis() {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        analysisProgress = 0
        currentPhase = .importingMedia

        let phases: [GenerationPhase] = [
            .importingMedia, .detectingFaces, .classifyingScenes,
            .scoringStability, .analyzingAudio, .selectingBestShots,
        ]
        var phaseIndex = 0

        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else {
                    timer.invalidate()
                    return
                }
                phaseIndex += 1
                if phaseIndex < phases.count {
                    self.currentPhase = phases[phaseIndex]
                    self.analysisProgress = phases[phaseIndex].progress
                } else {
                    timer.invalidate()
                    self.currentPhase = .selectingBestShots
                    self.analysisProgress = 0.55
                    self.isAnalyzing = false
                }
            }
        }
    }

    func startComposition(project: ReelProject) {
        guard !isComposing else { return }
        isComposing = true
        compositionProgress = 0
        currentPhase = .composingTimeline

        let phases: [GenerationPhase] = [
            .composingTimeline, .syncingBeats, .applyingTransitions,
            .addingOverlays, .rendering, .completed,
        ]
        var phaseIndex = 0

        compositionTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else {
                    timer.invalidate()
                    return
                }
                phaseIndex += 1
                if phaseIndex < phases.count {
                    self.currentPhase = phases[phaseIndex]
                    self.compositionProgress = phases[phaseIndex].progress - 0.6
                } else {
                    timer.invalidate()
                    self.currentPhase = .completed
                    self.compositionProgress = 1.0
                    self.isComposing = false

                    if let index = self.projects.firstIndex(where: { $0.id == project.id }) {
                        self.projects[index].status = .ready
                    }
                }
            }
        }
    }

    func cancelGeneration() {
        analysisTimer?.invalidate()
        compositionTimer?.invalidate()
        isAnalyzing = false
        isComposing = false
        analysisProgress = 0
        compositionProgress = 0
        currentPhase = .idle
    }

    // MARK: - Clip Management

    func toggleClipSelection(_ clip: MediaClip) {
        guard let index = clips.firstIndex(where: { $0.id == clip.id }) else { return }
        let old = clips[index]
        clips[index] = MediaClip(
            id: old.id, type: old.type, duration: old.duration,
            thumbnail: old.thumbnail, createdAt: old.createdAt,
            smileScore: old.smileScore, stabilityScore: old.stabilityScore,
            sceneCategory: old.sceneCategory, isSelected: !old.isSelected,
            trimStart: old.trimStart, trimEnd: old.trimEnd
        )
    }

    var selectedClipCount: Int {
        clips.filter(\.isSelected).count
    }

    var totalSelectedDuration: TimeInterval {
        clips.filter(\.isSelected).reduce(0) { $0 + $1.trimmedDuration }
    }

    var totalSelectedDurationText: String {
        let seconds = Int(totalSelectedDuration)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Project Management

    func createProject(title: String, bgm: BGMTrack, transition: TransitionStyle, duration: TargetDuration) -> ReelProject {
        let project = ReelProject(
            id: UUID(),
            title: title,
            clips: clips,
            bgmTrack: bgm,
            transitionStyle: transition,
            targetDuration: duration,
            textOverlays: [],
            createdAt: Date(),
            status: .draft
        )
        projects.insert(project, at: 0)
        return project
    }

    func deleteProject(_ project: ReelProject) {
        projects.removeAll { $0.id == project.id }
    }

    // MARK: - Statistics

    var sceneCategorySummary: [(SceneCategory, Int)] {
        var counts: [SceneCategory: Int] = [:]
        for clip in clips {
            counts[clip.sceneCategory, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }
}
