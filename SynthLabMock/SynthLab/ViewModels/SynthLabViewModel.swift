import Foundation
import SwiftUI

/// SynthLab のメインビューモデル
@MainActor
@Observable
final class SynthLabViewModel {
    // MARK: - State

    /// 現在のモード
    var currentMode: AppMode = .freePlay

    /// シンセモジュール一覧
    private(set) var modules: [SynthModule] = []

    /// 選択中のモジュール
    var selectedModule: SynthModule?

    /// 現在のレッスン
    private(set) var currentLesson: Lesson?

    /// レッスン進捗（完了したレッスン番号）
    private(set) var completedLessons: Set<Int> = []

    /// 全レッスン一覧
    private(set) var lessons: [Lesson] = []

    /// プリセット一覧
    private(set) var presets: [SynthPreset] = []

    /// 選択中のプリセット
    var selectedPreset: SynthPreset?

    /// オシレーター波形タイプ
    var waveformType: WaveformType = .sawtooth

    /// フィルタータイプ
    var filterType: FilterType = .lowPass

    /// 波形表示用データ
    private(set) var waveformData: [Double] = []

    /// フィルター応答カーブ
    private(set) var filterResponseData: [Double] = []

    /// エンベロープカーブ
    private(set) var envelopeData: [Double] = []

    /// LFO 波形データ
    private(set) var lfoData: [Double] = []

    /// エンジンが動作中か
    private(set) var isPlaying = false

    /// レッスン表示フラグ
    var showLessonList = false

    /// プリセット表示フラグ
    var showPresetList = false

    // MARK: - Dependencies

    let audioEngine = AudioEngineManager.shared

    // MARK: - Init

    init() {
        setupModules()
        setupLessons()
        setupPresets()
        updateWaveforms()
    }

    // MARK: - App Mode

    enum AppMode: String, CaseIterable, Identifiable, Sendable {
        case lesson = "レッスン"
        case freePlay = "フリープレイ"

        var id: String { rawValue }
    }

    // MARK: - Actions

    /// オーディオの再生/停止
    func togglePlayback() {
        if isPlaying {
            audioEngine.stop()
        } else {
            try? audioEngine.start()
        }
        isPlaying = audioEngine.isRunning
    }

    /// モジュールの有効/無効切り替え
    func toggleModule(_ module: SynthModule) {
        guard let index = modules.firstIndex(where: { $0.id == module.id }) else { return }
        modules[index].isEnabled.toggle()
    }

    /// パラメータを更新
    func updateParameter(moduleID: UUID, parameterID: UUID, value: Double) {
        guard let moduleIndex = modules.firstIndex(where: { $0.id == moduleID }),
              let paramIndex = modules[moduleIndex].parameters.firstIndex(where: { $0.id == parameterID })
        else { return }

        modules[moduleIndex].parameters[paramIndex].value = value

        // 選択中モジュールも同期
        if selectedModule?.id == moduleID {
            selectedModule = modules[moduleIndex]
        }

        updateWaveforms()
    }

    /// 波形タイプを変更
    func setWaveform(_ type: WaveformType) {
        waveformType = type
        updateWaveforms()
    }

    /// フィルタータイプを変更
    func setFilterType(_ type: FilterType) {
        filterType = type
        updateWaveforms()
    }

    /// プリセットを適用
    func applyPreset(_ preset: SynthPreset) {
        selectedPreset = preset
        waveformType = preset.oscillatorWaveform
        filterType = preset.filterType

        // フィルターモジュールのパラメータを更新
        if let filterIndex = modules.firstIndex(where: { $0.type == .filter }) {
            if let cutoffIndex = modules[filterIndex].parameters.firstIndex(where: { $0.name == "Cutoff" }) {
                modules[filterIndex].parameters[cutoffIndex].value = preset.filterCutoff
            }
            if let resIndex = modules[filterIndex].parameters.firstIndex(where: { $0.name == "Resonance" }) {
                modules[filterIndex].parameters[resIndex].value = preset.filterResonance
            }
        }

        // エンベロープモジュールのパラメータを更新
        if let envIndex = modules.firstIndex(where: { $0.type == .envelope }) {
            let envParams = [
                ("Attack", preset.attackTime),
                ("Decay", preset.decayTime),
                ("Sustain", preset.sustainLevel),
                ("Release", preset.releaseTime),
            ]
            for (name, val) in envParams {
                if let pIndex = modules[envIndex].parameters.firstIndex(where: { $0.name == name }) {
                    modules[envIndex].parameters[pIndex].value = val
                }
            }
        }

        // LFO モジュールのパラメータを更新
        if let lfoIndex = modules.firstIndex(where: { $0.type == .lfo }) {
            if let rateIndex = modules[lfoIndex].parameters.firstIndex(where: { $0.name == "Rate" }) {
                modules[lfoIndex].parameters[rateIndex].value = preset.lfoRate
            }
            if let depthIndex = modules[lfoIndex].parameters.firstIndex(where: { $0.name == "Depth" }) {
                modules[lfoIndex].parameters[depthIndex].value = preset.lfoDepth
            }
        }

        updateWaveforms()
    }

    /// レッスンを開始
    func startLesson(_ lesson: Lesson) {
        currentLesson = lesson
        currentMode = .lesson

        // フォーカスモジュールを選択
        if let module = modules.first(where: { $0.type == lesson.focusModule }) {
            selectedModule = module
        }
    }

    /// レッスンを完了
    func completeLesson() {
        if let lesson = currentLesson {
            completedLessons.insert(lesson.number)
        }
        currentLesson = nil
    }

    /// ノートオン（MIDI鍵盤シミュレーション）
    func noteOn(_ midiNote: Int) {
        audioEngine.noteOn(midiNote)
    }

    /// ノートオフ
    func noteOff(_ midiNote: Int) {
        audioEngine.noteOff(midiNote)
    }

    // MARK: - Private

    /// 波形データを再計算
    private func updateWaveforms() {
        // オシレーター波形
        let oscFreq: Double
        if let oscModule = modules.first(where: { $0.type == .oscillator }),
           let freqParam = oscModule.parameters.first(where: { $0.name == "Frequency" }) {
            oscFreq = freqParam.value
        } else {
            oscFreq = 440.0
        }
        waveformData = WaveformGenerator.generate(type: waveformType, frequency: oscFreq)

        // フィルター応答
        let cutoff: Double
        let resonance: Double
        if let filterModule = modules.first(where: { $0.type == .filter }) {
            cutoff = filterModule.parameters.first(where: { $0.name == "Cutoff" })?.value ?? 8000.0
            resonance = filterModule.parameters.first(where: { $0.name == "Resonance" })?.value ?? 0.3
        } else {
            cutoff = 8000.0
            resonance = 0.3
        }
        filterResponseData = WaveformGenerator.filterResponse(
            type: filterType,
            cutoff: cutoff,
            resonance: resonance
        )

        // エンベロープ
        if let envModule = modules.first(where: { $0.type == .envelope }) {
            let a = envModule.parameters.first(where: { $0.name == "Attack" })?.value ?? 0.01
            let d = envModule.parameters.first(where: { $0.name == "Decay" })?.value ?? 0.2
            let s = envModule.parameters.first(where: { $0.name == "Sustain" })?.value ?? 0.7
            let r = envModule.parameters.first(where: { $0.name == "Release" })?.value ?? 0.3
            envelopeData = WaveformGenerator.envelopeCurve(attack: a, decay: d, sustain: s, release: r)
        }

        // LFO
        if let lfoModule = modules.first(where: { $0.type == .lfo }) {
            let rate = lfoModule.parameters.first(where: { $0.name == "Rate" })?.value ?? 2.0
            let depth = lfoModule.parameters.first(where: { $0.name == "Depth" })?.value ?? 0.5
            lfoData = WaveformGenerator.lfoWaveform(rate: rate, depth: depth)
        }
    }

    /// モジュールの初期セットアップ
    private func setupModules() {
        modules = [
            SynthModule(
                type: .oscillator,
                parameters: [
                    SynthParameter(name: "Frequency", unit: "Hz", value: 440.0, minValue: 20.0, maxValue: 8000.0, step: 1.0),
                    SynthParameter(name: "Detune", unit: "cents", value: 0.0, minValue: -100.0, maxValue: 100.0, step: 1.0),
                    SynthParameter(name: "Level", unit: "", value: 0.8, minValue: 0.0, maxValue: 1.0, step: 0.01),
                ]
            ),
            SynthModule(
                type: .filter,
                parameters: [
                    SynthParameter(name: "Cutoff", unit: "Hz", value: 8000.0, minValue: 20.0, maxValue: 20000.0, step: 1.0),
                    SynthParameter(name: "Resonance", unit: "", value: 0.3, minValue: 0.0, maxValue: 1.0, step: 0.01),
                    SynthParameter(name: "Drive", unit: "", value: 0.0, minValue: 0.0, maxValue: 1.0, step: 0.01),
                ]
            ),
            SynthModule(
                type: .envelope,
                parameters: [
                    SynthParameter(name: "Attack", unit: "s", value: 0.01, minValue: 0.001, maxValue: 2.0, step: 0.001),
                    SynthParameter(name: "Decay", unit: "s", value: 0.2, minValue: 0.001, maxValue: 2.0, step: 0.001),
                    SynthParameter(name: "Sustain", unit: "", value: 0.7, minValue: 0.0, maxValue: 1.0, step: 0.01),
                    SynthParameter(name: "Release", unit: "s", value: 0.3, minValue: 0.001, maxValue: 5.0, step: 0.001),
                ]
            ),
            SynthModule(
                type: .lfo,
                parameters: [
                    SynthParameter(name: "Rate", unit: "Hz", value: 2.0, minValue: 0.1, maxValue: 20.0, step: 0.1),
                    SynthParameter(name: "Depth", unit: "", value: 0.5, minValue: 0.0, maxValue: 1.0, step: 0.01),
                ]
            ),
            SynthModule(
                type: .amplifier,
                parameters: [
                    SynthParameter(name: "Gain", unit: "dB", value: 0.0, minValue: -60.0, maxValue: 12.0, step: 0.1),
                    SynthParameter(name: "Pan", unit: "", value: 0.0, minValue: -1.0, maxValue: 1.0, step: 0.01),
                ]
            ),
        ]
    }

    /// レッスンの初期セットアップ
    private func setupLessons() {
        lessons = [
            Lesson(
                number: 1,
                title: "音の始まり：オシレーター",
                description: "シンセサイザーの音がどこから生まれるのかを学びましょう。波形の種類による音色の違いを体験します。",
                focusModule: .oscillator,
                hint: "波形タイプを切り替えると、同じ音程でも音色がまったく変わります。サイン波は「丸い音」、ノコギリ波は「明るい音」です。",
                steps: [
                    LessonStep(instruction: "サイン波を選択して音を聴いてみましょう", parameterName: nil, targetValue: nil),
                    LessonStep(instruction: "ノコギリ波に切り替えて音色の違いを感じましょう", parameterName: nil, targetValue: nil),
                    LessonStep(instruction: "Frequency を 220Hz に変更して低い音を聴きましょう", parameterName: "Frequency", targetValue: 220.0),
                ]
            ),
            Lesson(
                number: 2,
                title: "音を削る：フィルター",
                description: "フィルターは音の周波数成分を削ることで音色を変化させます。カットオフとレゾナンスの効果を学びます。",
                focusModule: .filter,
                hint: "カットオフ周波数を下げると高い倍音が削られ、音が「丸く」なります。スライダーを動かしながら波形の変化を観察しましょう。",
                steps: [
                    LessonStep(instruction: "カットオフを 2000Hz まで下げてみましょう", parameterName: "Cutoff", targetValue: 2000.0),
                    LessonStep(instruction: "レゾナンスを 0.8 に上げてカットオフ付近の強調を聴きましょう", parameterName: "Resonance", targetValue: 0.8),
                    LessonStep(instruction: "フィルタータイプを HPF に変えて違いを確認しましょう", parameterName: nil, targetValue: nil),
                ]
            ),
            Lesson(
                number: 3,
                title: "時間の変化：エンベロープ",
                description: "ADSR エンベロープが鍵盤を押してから離すまでの音量変化を制御する仕組みを学びます。",
                focusModule: .envelope,
                hint: "Attack は音の立ち上がり、Decay は減衰、Sustain は持続レベル、Release は鍵盤を離した後の余韻です。",
                steps: [
                    LessonStep(instruction: "Attack を 0.5s にしてゆっくり立ち上がる音を作りましょう", parameterName: "Attack", targetValue: 0.5),
                    LessonStep(instruction: "Release を 2.0s にして長い余韻を作りましょう", parameterName: "Release", targetValue: 2.0),
                    LessonStep(instruction: "Sustain を 0.3 にして減衰の大きい音にしましょう", parameterName: "Sustain", targetValue: 0.3),
                ]
            ),
            Lesson(
                number: 4,
                title: "揺らぎの魔法：LFO",
                description: "LFO（Low Frequency Oscillator）でパラメータを周期的に変調させ、音に動きと表情を与えます。",
                focusModule: .lfo,
                hint: "Rate は揺れの速さ、Depth は揺れの深さです。遅い Rate で深い Depth はビブラートやワウ効果になります。",
                steps: [
                    LessonStep(instruction: "Rate を 5.0Hz に設定してみましょう", parameterName: "Rate", targetValue: 5.0),
                    LessonStep(instruction: "Depth を 0.8 に上げて揺れを強調しましょう", parameterName: "Depth", targetValue: 0.8),
                ]
            ),
            Lesson(
                number: 5,
                title: "音を仕上げる：アンプ",
                description: "最終段のアンプで音量バランスと定位を調整し、サウンドを仕上げます。",
                focusModule: .amplifier,
                hint: "Gain はデシベル単位で音量を調整します。Pan は左右の定位です。",
                steps: [
                    LessonStep(instruction: "Gain を -6dB に設定しましょう", parameterName: "Gain", targetValue: -6.0),
                    LessonStep(instruction: "Pan を 0.5（やや右）に設定しましょう", parameterName: "Pan", targetValue: 0.5),
                ]
            ),
        ]
    }

    /// プリセットの初期セットアップ
    private func setupPresets() {
        presets = [
            SynthPreset(
                name: "Warm Bass",
                category: .bass,
                description: "太くて温かみのあるベースサウンド",
                oscillatorWaveform: .sawtooth,
                filterCutoff: 800.0,
                filterResonance: 0.3,
                filterType: .lowPass,
                attackTime: 0.005,
                decayTime: 0.3,
                sustainLevel: 0.6,
                releaseTime: 0.15,
                lfoRate: 0.5,
                lfoDepth: 0.1
            ),
            SynthPreset(
                name: "Screaming Lead",
                category: .lead,
                description: "鋭いリードサウンド",
                oscillatorWaveform: .sawtooth,
                filterCutoff: 4000.0,
                filterResonance: 0.6,
                filterType: .lowPass,
                attackTime: 0.01,
                decayTime: 0.1,
                sustainLevel: 0.8,
                releaseTime: 0.2,
                lfoRate: 5.0,
                lfoDepth: 0.15
            ),
            SynthPreset(
                name: "Ambient Pad",
                category: .pad,
                description: "広がりのあるパッドサウンド",
                oscillatorWaveform: .triangle,
                filterCutoff: 3000.0,
                filterResonance: 0.2,
                filterType: .lowPass,
                attackTime: 1.5,
                decayTime: 0.8,
                sustainLevel: 0.9,
                releaseTime: 3.0,
                lfoRate: 0.3,
                lfoDepth: 0.4
            ),
            SynthPreset(
                name: "Laser FX",
                category: .fx,
                description: "レーザー風のエフェクトサウンド",
                oscillatorWaveform: .square,
                filterCutoff: 12000.0,
                filterResonance: 0.9,
                filterType: .bandPass,
                attackTime: 0.001,
                decayTime: 0.5,
                sustainLevel: 0.0,
                releaseTime: 0.8,
                lfoRate: 15.0,
                lfoDepth: 0.9
            ),
            SynthPreset(
                name: "Electric Piano",
                category: .keys,
                description: "エレピ風のキーボードサウンド",
                oscillatorWaveform: .sine,
                filterCutoff: 5000.0,
                filterResonance: 0.15,
                filterType: .lowPass,
                attackTime: 0.005,
                decayTime: 1.0,
                sustainLevel: 0.3,
                releaseTime: 0.5,
                lfoRate: 4.0,
                lfoDepth: 0.05
            ),
        ]
    }
}
