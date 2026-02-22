import Foundation
import NearbyInteraction
import MultipeerConnectivity

/// Nearby Interaction を使った空間オーディオ管理
/// （モック：UWB ハードウェアが無い環境ではシミュレーションで代替）
@MainActor
@Observable
final class SpatialAudioManager {
    static let shared = SpatialAudioManager()

    // MARK: - State

    /// セッションが有効か
    private(set) var isSessionActive = false

    /// 検出されたリスナー
    private(set) var listeners: [Listener] = []

    /// 現在再生中のトラック
    var currentTrack: AudioTrack?

    /// 再生中フラグ
    private(set) var isPlaying = false

    /// 再生進捗（0.0〜1.0）
    private(set) var playbackProgress: Double = 0.0

    /// セッションモード
    var sessionMode: SessionMode = .host

    /// UWB がサポートされているか
    private(set) var isUWBSupported = true

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// マスターボリューム（0.0〜1.0）
    var masterVolume: Double = 0.8

    private var simulationTimer: Timer?
    private var playbackTimer: Timer?

    private init() {}

    // MARK: - Session Management

    /// セッションを開始
    func startSession() {
        guard NISession.isSupported else {
            isUWBSupported = false
            startSimulation()
            return
        }

        isSessionActive = true
        startSimulation()
    }

    /// セッションを停止
    func stopSession() {
        isSessionActive = false
        simulationTimer?.invalidate()
        simulationTimer = nil
        listeners = []
        stopPlayback()
    }

    // MARK: - Playback

    /// トラックを再生
    func play(track: AudioTrack) {
        currentTrack = track
        isPlaying = true
        playbackProgress = 0.0

        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying, let track = self.currentTrack else { return }
                self.playbackProgress += 0.1 / Double(track.durationSeconds)
                if self.playbackProgress >= 1.0 {
                    self.playbackProgress = 0.0 // ループ再生
                }
            }
        }
    }

    /// 再生を一時停止
    func pausePlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    /// 再生を再開
    func resumePlayback() {
        guard let track = currentTrack else { return }
        isPlaying = true

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying else { return }
                self.playbackProgress += 0.1 / Double(track.durationSeconds)
                if self.playbackProgress >= 1.0 {
                    self.playbackProgress = 0.0
                }
            }
        }
    }

    /// 再生を停止
    func stopPlayback() {
        isPlaying = false
        playbackProgress = 0.0
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    // MARK: - Audio Effect Calculation

    /// リスナーに適用するエフェクトパラメータを計算
    func effectParameters(for listener: Listener) -> AudioEffectParams {
        let zone = listener.zone
        let pan = Double(listener.direction.x).clamped(to: -1.0...1.0)

        return AudioEffectParams(
            volume: zone.volume * masterVolume,
            pan: pan,
            bassBoost: zone.bassBoost,
            reverb: zone.reverb,
            zone: zone
        )
    }

    // MARK: - Simulation

    private func startSimulation() {
        isSessionActive = true

        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSimulatedListeners()
            }
        }

        listeners = generateDemoListeners()
    }

    private func updateSimulatedListeners() {
        listeners = listeners.map { listener in
            let newDistance = max(0.3, listener.distance + Float.random(in: -0.2...0.2))
            let newDirection = SIMD3<Float>(
                listener.direction.x + Float.random(in: -0.08...0.08),
                listener.direction.y + Float.random(in: -0.03...0.03),
                listener.direction.z + Float.random(in: -0.08...0.08)
            )

            return Listener(
                name: listener.name,
                distance: newDistance,
                direction: newDirection,
                signalStrength: Double(max(0, 1.0 - newDistance / 10.0))
            )
        }

        // たまにリスナーが出現/消失
        if Bool.random() && listeners.count < 5 {
            let names = ["iPhone (Taro)", "iPhone (Hanako)", "iPhone (Yuki)", "iPhone (Ken)", "iPhone (Mika)"]
            let usedNames = Set(listeners.map(\.name))
            if let newName = names.first(where: { !usedNames.contains($0) }) {
                listeners.append(Listener(
                    name: newName,
                    distance: Float.random(in: 1.5...8.0),
                    direction: SIMD3<Float>(Float.random(in: -1...1), 0, Float.random(in: -1...0)),
                    signalStrength: 0.3
                ))
            }
        }
    }

    private func generateDemoListeners() -> [Listener] {
        [
            Listener(
                name: "iPhone (Taro)",
                distance: 1.2,
                direction: SIMD3<Float>(0.3, 0.0, -0.9),
                signalStrength: 0.8
            ),
            Listener(
                name: "iPhone (Hanako)",
                distance: 3.5,
                direction: SIMD3<Float>(-0.6, 0.0, -0.5),
                signalStrength: 0.5
            ),
            Listener(
                name: "iPhone (Yuki)",
                distance: 6.8,
                direction: SIMD3<Float>(0.8, 0.0, -0.3),
                signalStrength: 0.2
            ),
        ]
    }
}

// MARK: - AudioEffectParams

struct AudioEffectParams: Sendable {
    let volume: Double
    let pan: Double
    let bassBoost: Double
    let reverb: Double
    let zone: SoundZone
}

// MARK: - Double Extension

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
