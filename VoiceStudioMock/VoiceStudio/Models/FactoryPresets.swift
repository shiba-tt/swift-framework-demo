import Foundation

/// ファクトリープリセット定義
enum VoiceStudioPresets {
    static var all: [EffectPreset] {
        [podcastStandard, narration, interview]
    }

    /// ポッドキャスト標準プリセット
    static let podcastStandard = EffectPreset(
        name: "ポッドキャスト標準",
        category: .podcast,
        effects: [
            AudioEffect(
                name: "Noise Gate",
                type: .noiseGate,
                isEnabled: true,
                parameters: AudioEffectType.noiseGate.defaultParameters,
                order: 0
            ),
            AudioEffect(
                name: "De-Esser",
                type: .deEsser,
                isEnabled: true,
                parameters: AudioEffectType.deEsser.defaultParameters,
                order: 1
            ),
            AudioEffect(
                name: "Compressor",
                type: .compressor,
                isEnabled: true,
                parameters: AudioEffectType.compressor.defaultParameters,
                order: 2
            ),
            AudioEffect(
                name: "EQ",
                type: .eq,
                isEnabled: true,
                parameters: AudioEffectType.eq.defaultParameters,
                order: 3
            ),
            AudioEffect(
                name: "Limiter",
                type: .limiter,
                isEnabled: true,
                parameters: AudioEffectType.limiter.defaultParameters,
                order: 4
            ),
        ],
        targetLUFS: -16.0
    )

    /// ナレーション用プリセット
    static let narration: EffectPreset = {
        var gateParams = AudioEffectType.noiseGate.defaultParameters
        gateParams[0].value = -35 // より厳しいゲート

        var compParams = AudioEffectType.compressor.defaultParameters
        compParams[1].value = 4.0 // Ratio を上げる
        compParams[4].value = 8   // Makeup を上げる

        var eqParams = AudioEffectType.eq.defaultParameters
        eqParams[2].value = 3    // Mid をブースト
        eqParams[3].value = 2    // High をブースト

        return EffectPreset(
            name: "ナレーション",
            category: .narration,
            effects: [
                AudioEffect(name: "Noise Gate", type: .noiseGate, isEnabled: true, parameters: gateParams, order: 0),
                AudioEffect(name: "De-Esser", type: .deEsser, isEnabled: true, parameters: AudioEffectType.deEsser.defaultParameters, order: 1),
                AudioEffect(name: "Compressor", type: .compressor, isEnabled: true, parameters: compParams, order: 2),
                AudioEffect(name: "EQ", type: .eq, isEnabled: true, parameters: eqParams, order: 3),
                AudioEffect(name: "Limiter", type: .limiter, isEnabled: true, parameters: AudioEffectType.limiter.defaultParameters, order: 4),
            ],
            targetLUFS: -14.0
        )
    }()

    /// インタビュー用プリセット
    static let interview: EffectPreset = {
        var compParams = AudioEffectType.compressor.defaultParameters
        compParams[0].value = -20 // Threshold を少し上げる
        compParams[1].value = 2.5 // Ratio を下げる

        return EffectPreset(
            name: "インタビュー",
            category: .interview,
            effects: [
                AudioEffect(name: "Noise Gate", type: .noiseGate, isEnabled: true, parameters: AudioEffectType.noiseGate.defaultParameters, order: 0),
                AudioEffect(name: "De-Esser", type: .deEsser, isEnabled: false, parameters: AudioEffectType.deEsser.defaultParameters, order: 1),
                AudioEffect(name: "Compressor", type: .compressor, isEnabled: true, parameters: compParams, order: 2),
                AudioEffect(name: "EQ", type: .eq, isEnabled: true, parameters: AudioEffectType.eq.defaultParameters, order: 3),
                AudioEffect(name: "Limiter", type: .limiter, isEnabled: true, parameters: AudioEffectType.limiter.defaultParameters, order: 4),
            ],
            targetLUFS: -16.0
        )
    }()
}
