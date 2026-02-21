import Foundation
import AVFoundation
import AudioToolbox

// MARK: - PedalBoardViewModel

@MainActor
@Observable
final class PedalBoardViewModel {

    // MARK: - Public State

    var pedals: [EffectPedal] = []
    var presets: [PedalBoardPreset] = []
    var setlists: [Setlist] = []
    var selectedPreset: PedalBoardPreset?
    var selectedPedal: EffectPedal?

    var isEngineRunning = false
    var isRecording = false
    var showingAddPedal = false
    var showingPresetList = false
    var showingSetlistView = false
    var showingPluginBrowser = false
    var showingTuner = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let engineManager = AudioEngineManager.shared
    private let pluginManager = AUv3PluginManager.shared

    // MARK: - Computed Properties

    var audioMeter: AudioMeter { engineManager.audioMeter }
    var tunerData: TunerData { engineManager.tunerData }
    var recordingDuration: String { engineManager.formattedRecordingDuration }
    var enabledPedalCount: Int { pedals.filter(\.isEnabled).count }
    var totalPedalCount: Int { pedals.count }

    var sortedPedals: [EffectPedal] {
        pedals.sorted { $0.order < $1.order }
    }

    var availablePlugins: [AUv3PluginInfo] {
        pluginManager.availableEffects
    }

    // MARK: - Setup

    func setup() {
        // ファクトリープリセットを読み込み
        presets = FactoryPresets.all

        // プラグインスキャン
        pluginManager.scanInstalledPlugins()
    }

    // MARK: - Engine Control

    func startEngine() async {
        do {
            try await engineManager.startEngine(with: pedals)
            isEngineRunning = true
        } catch {
            errorMessage = "オーディオエンジンの起動に失敗: \(error.localizedDescription)"
        }
    }

    func stopEngine() {
        engineManager.stopEngine()
        isEngineRunning = false
    }

    func toggleEngine() async {
        if isEngineRunning {
            stopEngine()
        } else {
            await startEngine()
        }
    }

    // MARK: - Pedal Management

    func addPedal(type: EffectType) {
        let pedal = EffectPedal(
            name: type.displayName,
            type: type,
            parameters: type.defaultParameters,
            order: pedals.count
        )
        pedals.append(pedal)

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: pedals) }
        }
    }

    func removePedal(_ pedal: EffectPedal) {
        pedals.removeAll { $0.id == pedal.id }
        reorderPedals()

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: pedals) }
        }
    }

    func togglePedal(_ pedal: EffectPedal) {
        guard let index = pedals.firstIndex(where: { $0.id == pedal.id }) else { return }
        pedals[index].isEnabled.toggle()
        engineManager.togglePedal(pedalID: pedal.id, enabled: pedals[index].isEnabled)
    }

    func movePedal(from source: IndexSet, to destination: Int) {
        var sorted = sortedPedals
        sorted.move(fromOffsets: source, toOffset: destination)
        for (i, pedal) in sorted.enumerated() {
            if let index = pedals.firstIndex(where: { $0.id == pedal.id }) {
                pedals[index].order = i
            }
        }

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: pedals) }
        }
    }

    func updateParameter(pedalID: UUID, parameterIndex: Int, value: Float) {
        guard let pedalIndex = pedals.firstIndex(where: { $0.id == pedalID }),
              parameterIndex < pedals[pedalIndex].parameters.count
        else { return }

        pedals[pedalIndex].parameters[parameterIndex].value = value
        engineManager.updateParameter(
            pedalID: pedalID,
            parameterName: pedals[pedalIndex].parameters[parameterIndex].name,
            value: value
        )
    }

    // MARK: - Preset Management

    func loadPreset(_ preset: PedalBoardPreset) {
        pedals = preset.pedalConfigs.compactMap { config in
            guard let type = config.effectType else { return nil }
            var pedal = EffectPedal(
                name: type.displayName,
                type: type,
                isEnabled: config.isEnabled,
                parameters: type.defaultParameters,
                order: config.order
            )
            // プリセットのパラメータ値を適用
            for (paramName, paramValue) in config.parameterValues {
                if let paramIndex = pedal.parameters.firstIndex(where: { $0.name == paramName }) {
                    pedal.parameters[paramIndex].value = paramValue
                }
            }
            pedal.presetName = preset.name
            return pedal
        }

        selectedPreset = preset

        if isEngineRunning {
            Task { try? await engineManager.rebuildChain(with: pedals) }
        }
    }

    func saveCurrentAsPreset(name: String, category: PresetCategory) {
        let configs = pedals.map { pedal in
            var paramValues: [String: Float] = [:]
            for param in pedal.parameters {
                paramValues[param.name] = param.value
            }
            return PedalConfig(
                effectType: pedal.type,
                isEnabled: pedal.isEnabled,
                parameterValues: paramValues,
                order: pedal.order
            )
        }

        let preset = PedalBoardPreset(
            name: name,
            category: category,
            pedalConfigs: configs
        )
        presets.append(preset)
        selectedPreset = preset
    }

    func deletePreset(_ preset: PedalBoardPreset) {
        presets.removeAll { $0.id == preset.id }
        if selectedPreset?.id == preset.id {
            selectedPreset = nil
        }
    }

    func togglePresetFavorite(_ preset: PedalBoardPreset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index].isFavorite.toggle()
    }

    // MARK: - Setlist Management

    func createSetlist(name: String) {
        let setlist = Setlist(name: name)
        setlists.append(setlist)
    }

    func addSongToSetlist(
        setlistID: UUID,
        title: String,
        presetID: UUID,
        bpm: Int?
    ) {
        guard let index = setlists.firstIndex(where: { $0.id == setlistID }) else { return }
        let song = SetlistSong(
            title: title,
            presetID: presetID,
            bpm: bpm,
            order: setlists[index].songs.count
        )
        setlists[index].songs.append(song)
    }

    // MARK: - Recording

    func toggleRecording() {
        if isRecording {
            engineManager.stopRecording()
            isRecording = false
        } else {
            do {
                try engineManager.startRecording()
                isRecording = true
            } catch {
                errorMessage = "録音の開始に失敗: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Tuner

    func toggleTuner() {
        if showingTuner {
            engineManager.stopTuner()
        } else {
            engineManager.startTuner()
        }
        showingTuner.toggle()
    }

    // MARK: - Private

    private func reorderPedals() {
        for (i, pedal) in pedals.sorted(by: { $0.order < $1.order }).enumerated() {
            if let index = pedals.firstIndex(where: { $0.id == pedal.id }) {
                pedals[index].order = i
            }
        }
    }
}
