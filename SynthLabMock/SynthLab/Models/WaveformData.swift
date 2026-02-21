import Foundation

/// 波形データ生成ユーティリティ（デモ用）
enum WaveformGenerator {
    /// 指定された波形タイプのサンプルデータを生成
    static func generate(
        type: WaveformType,
        frequency: Double = 440.0,
        sampleCount: Int = 256,
        sampleRate: Double = 44100.0
    ) -> [Double] {
        (0..<sampleCount).map { i in
            let t = Double(i) / sampleRate
            let phase = 2.0 * .pi * frequency * t
            switch type {
            case .sine:
                return sin(phase)
            case .square:
                return sin(phase) >= 0 ? 1.0 : -1.0
            case .sawtooth:
                let normalized = (frequency * t).truncatingRemainder(dividingBy: 1.0)
                return 2.0 * normalized - 1.0
            case .triangle:
                let normalized = (frequency * t).truncatingRemainder(dividingBy: 1.0)
                return normalized < 0.5
                    ? 4.0 * normalized - 1.0
                    : 3.0 - 4.0 * normalized
            case .noise:
                return Double.random(in: -1.0...1.0)
            }
        }
    }

    /// フィルター適用後の周波数応答カーブを生成（デモ用の近似）
    static func filterResponse(
        type: FilterType,
        cutoff: Double,
        resonance: Double,
        pointCount: Int = 128
    ) -> [Double] {
        let maxFreq = 20000.0
        return (0..<pointCount).map { i in
            let freq = maxFreq * Double(i) / Double(pointCount)
            let normalizedCutoff = cutoff / maxFreq
            let normalizedFreq = freq / maxFreq

            switch type {
            case .lowPass:
                let ratio = normalizedFreq / max(normalizedCutoff, 0.001)
                let base = 1.0 / (1.0 + pow(ratio, 4.0))
                let peak = resonance * exp(-pow(ratio - 1.0, 2) * 10.0)
                return min(base + peak, 1.0)
            case .highPass:
                let ratio = normalizedCutoff / max(normalizedFreq, 0.001)
                let base = 1.0 / (1.0 + pow(ratio, 4.0))
                let peak = resonance * exp(-pow(normalizedFreq / max(normalizedCutoff, 0.001) - 1.0, 2) * 10.0)
                return min(base + peak, 1.0)
            case .bandPass:
                let ratio = abs(normalizedFreq - normalizedCutoff) / max(normalizedCutoff * 0.3, 0.001)
                return exp(-ratio * ratio * (3.0 - resonance * 2.0))
            case .notch:
                let ratio = abs(normalizedFreq - normalizedCutoff) / max(normalizedCutoff * 0.3, 0.001)
                return 1.0 - exp(-ratio * ratio * (3.0 - resonance * 2.0))
            }
        }
    }

    /// ADSR エンベロープカーブを生成
    static func envelopeCurve(
        attack: Double,
        decay: Double,
        sustain: Double,
        release: Double,
        pointCount: Int = 128
    ) -> [Double] {
        let totalTime = attack + decay + 0.3 + release
        return (0..<pointCount).map { i in
            let t = totalTime * Double(i) / Double(pointCount)
            if t < attack {
                // Attack phase
                return t / max(attack, 0.001)
            } else if t < attack + decay {
                // Decay phase
                let decayProgress = (t - attack) / max(decay, 0.001)
                return 1.0 - (1.0 - sustain) * decayProgress
            } else if t < attack + decay + 0.3 {
                // Sustain phase
                return sustain
            } else {
                // Release phase
                let releaseProgress = (t - attack - decay - 0.3) / max(release, 0.001)
                return sustain * max(1.0 - releaseProgress, 0.0)
            }
        }
    }

    /// LFO 波形を生成
    static func lfoWaveform(
        rate: Double,
        depth: Double,
        pointCount: Int = 128
    ) -> [Double] {
        (0..<pointCount).map { i in
            let phase = 2.0 * .pi * rate * Double(i) / Double(pointCount)
            return sin(phase) * depth
        }
    }
}
