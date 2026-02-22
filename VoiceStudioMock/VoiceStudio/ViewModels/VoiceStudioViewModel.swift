import Foundation
import SwiftUI

/// VoiceStudio のメインビューモデル
@MainActor
@Observable
final class VoiceStudioViewModel {
    // MARK: - State

    /// エフェクトチェーン
    var effects: [AudioEffect] = []

    /// プリセット一覧
    var presets: [EffectPreset] = []

    /// 選択中のプリセット
    var selectedPreset: EffectPreset?

    /// 録音セッション履歴
    var sessions: [RecordingSession] = []

    /// 現在の録音セッション
    var currentSession: RecordingSession?

    /// 選択中のエフェクト（詳細表示用）
    var selectedEffect: AudioEffect?

    /// エンジン実行中フラグ
    var isEngineRunning = false

    /// 録音中フラグ
    var isRecording = false

    /// LUFS ターゲット値
    var targetLUFS: Double = -16.0

    /// エフェクト追加画面の表示フラグ
    var showingAddEffect = false

    /// プリセット一覧の表示フラグ
    var showingPresetList = false

    /// セッション一覧の表示フラグ
    var showingSessionList = false

    /// エラーメッセージ
    var errorMessage: String?

    // MARK: - Computed

    var audioMeter: VoiceAudioMeter { engineManager.audioMeter }
    var recordingDuration: String { engineManager.formattedRecordingDuration }
    var enabledEffectCount: Int { effects.filter(\.isEnabled).count }

    var sortedEffects: [AudioEffect] {
        effects.sorted { $0.order < $1.order }
    }

    var lufsStatus: LUFSStatus {
        let current = audioMeter.lufs
        let diff = abs(current - targetLUFS)
        if diff < 1.0 { return .onTarget }
        if current > targetLUFS { return .tooLoud }
        return .tooQuiet
    }

    // MARK: - Dependencies

    private let engineManager = AudioEngineManager.shared

    // MARK: - Setup

    func setup() {
        presets = VoiceStudioPresets.all
        loadPreset(VoiceStudioPresets.podcastStandard)
        generateDemoSessions()
    }

    // MARK: - Engine Control

    func startEngine() async {
        do {
            try await engineManager.startEngine(with: effects)
            isEngineRunning = true
        } catch {
            errorMessage = "オーディオエンジンの起動に失敗: \(error.localizedDescription)"
        }
    }

    func stopEngine() {
        engineManager.stopEngine()
        isEngineRunning = false
        isRecording = false
        currentSession = nil
    }

    func toggleEngine() async {
        if isEngineRunning {
            stopEngine()
        } else {
            await startEngine()
        }
    }

    // MARK: - Recording

    func startRecording() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "VoiceStudio_\(formatter.string(from: .now)).m4a"

        do {
            try engineManager.startRecording(fileName: fileName)
            isRecording = true

            currentSession = RecordingSession(
                title: "エピソード \(sessions.count + 1)",
                createdDate: Date(),
                duration: 0,
                status: .recording,
                presetName: selectedPreset?.name
            )
        } catch {
            errorMessage = "録音の開始に失敗: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        engineManager.stopRecording()
        isRecording = false

        if var session = currentSession {
            session.duration = engineManager.recordingDuration
            session.status = .completed
            sessions.insert(session, at: 0)
            currentSession = nil
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    // MARK: - Effect Management

    func addEffect(type: AudioEffectType) {
        let effect = AudioEffect(
            name: type.displayName,
            type: type,
            isEnabled: true,
            parameters: type.defaultParameters,
            order: effects.count
        )
        effects.append(effect)

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: effects) }
        }
    }

    func removeEffect(_ effect: AudioEffect) {
        effects.removeAll { $0.id == effect.id }
        reorderEffects()

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: effects) }
        }
    }

    func toggleEffect(_ effect: AudioEffect) {
        guard let index = effects.firstIndex(where: { $0.id == effect.id }) else { return }
        effects[index].isEnabled.toggle()
        engineManager.toggleEffect(effectID: effect.id, enabled: effects[index].isEnabled)
    }

    func moveEffect(from source: IndexSet, to destination: Int) {
        var sorted = sortedEffects
        sorted.move(fromOffsets: source, toOffset: destination)
        for (i, effect) in sorted.enumerated() {
            if let index = effects.firstIndex(where: { $0.id == effect.id }) {
                effects[index].order = i
            }
        }

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: effects) }
        }
    }

    func updateParameter(effectID: UUID, parameterIndex: Int, value: Float) {
        guard let effectIndex = effects.firstIndex(where: { $0.id == effectID }),
              parameterIndex < effects[effectIndex].parameters.count
        else { return }

        effects[effectIndex].parameters[parameterIndex].value = value
        engineManager.updateParameter(
            effectID: effectID,
            parameterName: effects[effectIndex].parameters[parameterIndex].name,
            value: value
        )
    }

    // MARK: - Preset Management

    func loadPreset(_ preset: EffectPreset) {
        effects = preset.effects
        targetLUFS = preset.targetLUFS
        selectedPreset = preset

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: effects) }
        }
    }

    func saveCurrentAsPreset(name: String) {
        let preset = EffectPreset(
            name: name,
            category: .custom,
            effects: effects,
            targetLUFS: targetLUFS
        )
        presets.append(preset)
        selectedPreset = preset
    }

    // MARK: - Private

    private func reorderEffects() {
        for (i, effect) in effects.sorted(by: { $0.order < $1.order }).enumerated() {
            if let index = effects.firstIndex(where: { $0.id == effect.id }) {
                effects[index].order = i
            }
        }
    }

    private func generateDemoSessions() {
        let calendar = Calendar.current
        sessions = (1...5).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            return RecordingSession(
                title: "エピソード \(6 - dayOffset)",
                createdDate: date,
                duration: Double.random(in: 600...3600),
                status: .completed,
                presetName: ["ポッドキャスト標準", "ナレーション", "インタビュー"].randomElement()
            )
        }
    }
}

/// LUFS ステータス
enum LUFSStatus {
    case onTarget
    case tooLoud
    case tooQuiet

    var label: String {
        switch self {
        case .onTarget: "適正"
        case .tooLoud: "音量過大"
        case .tooQuiet: "音量不足"
        }
    }

    var color: String {
        switch self {
        case .onTarget: "green"
        case .tooLoud: "red"
        case .tooQuiet: "yellow"
        }
    }
}
