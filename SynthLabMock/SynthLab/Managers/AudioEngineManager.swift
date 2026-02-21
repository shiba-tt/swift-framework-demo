import Foundation
import AVFAudio
import CoreAudioKit

/// AVAudioEngine を使ったシンセサイザーのオーディオ処理管理
/// （モック：実際の音声処理はシミュレーションで代替）
@MainActor
@Observable
final class AudioEngineManager {
    static let shared = AudioEngineManager()

    // MARK: - State

    /// オーディオエンジンが動作中か
    private(set) var isRunning = false

    /// 現在の出力レベル（RMS）
    private(set) var outputLevel: Float = 0.0

    /// 現在再生中のノートのMIDI番号
    private(set) var activeNotes: Set<Int> = []

    /// 接続されたAUv3プラグインの数
    private(set) var connectedPluginCount = 0

    /// レイテンシー（ms）
    private(set) var latencyMs: Double = 5.2

    /// サンプルレート
    let sampleRate: Double = 44100.0

    /// バッファサイズ
    let bufferSize: Int = 256

    private var levelTimer: Timer?

    private init() {}

    // MARK: - Engine Control

    /// オーディオエンジンを開始
    func start() throws {
        isRunning = true
        connectedPluginCount = 3

        // デモ用：出力レベルをシミュレート
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isRunning else { return }
                if self.activeNotes.isEmpty {
                    self.outputLevel = max(self.outputLevel - 0.05, 0.0)
                } else {
                    self.outputLevel = Float.random(in: 0.3...0.8)
                }
            }
        }
    }

    /// オーディオエンジンを停止
    func stop() {
        isRunning = false
        outputLevel = 0.0
        activeNotes = []
        levelTimer?.invalidate()
        levelTimer = nil
    }

    // MARK: - Note Control

    /// ノートオン（鍵盤を押した）
    func noteOn(_ midiNote: Int) {
        activeNotes.insert(midiNote)
        outputLevel = 0.6
    }

    /// ノートオフ（鍵盤を離した）
    func noteOff(_ midiNote: Int) {
        activeNotes.remove(midiNote)
    }

    /// 全ノートオフ
    func allNotesOff() {
        activeNotes.removeAll()
    }

    // MARK: - AUv3 Plugin Management

    /// インストール済みの AUv3 コンポーネントを検索（モック）
    func discoverAUv3Components() -> [MockAUComponent] {
        [
            MockAUComponent(name: "SynthLab Oscillator", manufacturer: "SynthLab", type: .generator),
            MockAUComponent(name: "SynthLab Filter", manufacturer: "SynthLab", type: .effect),
            MockAUComponent(name: "SynthLab Amp", manufacturer: "SynthLab", type: .effect),
            MockAUComponent(name: "SynthLab LFO", manufacturer: "SynthLab", type: .generator),
            MockAUComponent(name: "SynthLab Envelope", manufacturer: "SynthLab", type: .effect),
        ]
    }
}

/// モック AUv3 コンポーネント
struct MockAUComponent: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let manufacturer: String
    let type: AUComponentType
}

/// AUv3 コンポーネントのタイプ
enum AUComponentType: String, Sendable {
    case generator = "Generator"
    case effect = "Effect"
    case midiProcessor = "MIDI Processor"
}
