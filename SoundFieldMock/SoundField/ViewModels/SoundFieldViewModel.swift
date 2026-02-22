import Foundation

/// SoundField のメイン ViewModel
@MainActor
@Observable
final class SoundFieldViewModel {
    // MARK: - Dependencies

    let audioManager = SpatialAudioManager.shared

    // MARK: - State

    var selectedTab: AppTab = .field

    enum AppTab: String, CaseIterable, Sendable {
        case field = "フィールド"
        case tracks = "トラック"
        case mixer = "ミキサー"
        case settings = "設定"

        var systemImageName: String {
            switch self {
            case .field:    "dot.radiowaves.left.and.right"
            case .tracks:   "music.note.list"
            case .mixer:    "slider.horizontal.3"
            case .settings: "gearshape.fill"
            }
        }
    }

    // MARK: - Track Library

    private(set) var trackLibrary: [AudioTrack] = []

    var tracksByGenre: [(genre: AudioGenre, tracks: [AudioTrack])] {
        let grouped = Dictionary(grouping: trackLibrary) { $0.genre }
        return grouped
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (genre: $0.key, tracks: $0.value) }
    }

    // MARK: - Mixer State

    var showListenerDetail = false
    var selectedListener: Listener?

    // MARK: - Init

    init() {
        setupDemoTracks()
    }

    // MARK: - Actions

    /// セッション開始
    func startSession() {
        audioManager.startSession()
    }

    /// セッション停止
    func stopSession() {
        audioManager.stopSession()
    }

    /// トラックを選択して再生
    func selectAndPlay(_ track: AudioTrack) {
        audioManager.play(track: track)
        selectedTab = .field
    }

    /// 再生/一時停止トグル
    func togglePlayback() {
        if audioManager.isPlaying {
            audioManager.pausePlayback()
        } else {
            audioManager.resumePlayback()
        }
    }

    /// リスナーの詳細エフェクト情報を取得
    func effectParams(for listener: Listener) -> AudioEffectParams {
        audioManager.effectParameters(for: listener)
    }

    // MARK: - Private

    private func setupDemoTracks() {
        trackLibrary = [
            AudioTrack(title: "Neon Pulse", artist: "DJ Akira", genre: .electronic, durationSeconds: 245, bpm: 128),
            AudioTrack(title: "Digital Horizon", artist: "SynthWave", genre: .electronic, durationSeconds: 312, bpm: 140),
            AudioTrack(title: "Ocean Drift", artist: "Calm Waves", genre: .ambient, durationSeconds: 420, bpm: 70),
            AudioTrack(title: "Morning Dew", artist: "Nature Sound", genre: .ambient, durationSeconds: 380, bpm: 60),
            AudioTrack(title: "Rainy Cafe", artist: "ChillHop", genre: .lofi, durationSeconds: 198, bpm: 85),
            AudioTrack(title: "Study Session", artist: "LoFi Girl", genre: .lofi, durationSeconds: 256, bpm: 80),
            AudioTrack(title: "Deep Groove", artist: "House Master", genre: .house, durationSeconds: 330, bpm: 124),
            AudioTrack(title: "Sunset Terrace", artist: "Beach Beats", genre: .house, durationSeconds: 288, bpm: 120),
            AudioTrack(title: "Blue Note Walk", artist: "Trio Jazz", genre: .jazz, durationSeconds: 275, bpm: 110),
            AudioTrack(title: "Midnight Sax", artist: "Smooth Jazz Co.", genre: .jazz, durationSeconds: 345, bpm: 95),
        ]
    }
}
