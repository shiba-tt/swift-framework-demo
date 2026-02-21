import Foundation

// MARK: - AudioMeter（オーディオメーター）

struct AudioMeter: Sendable {
    var inputLevel: Float
    var outputLevel: Float
    var inputPeak: Float
    var outputPeak: Float
    var latencyMs: Double
    var isClipping: Bool

    static let zero = AudioMeter(
        inputLevel: 0,
        outputLevel: 0,
        inputPeak: 0,
        outputPeak: 0,
        latencyMs: 0,
        isClipping: false
    )

    var inputLevelDB: Float {
        levelToDecibels(inputLevel)
    }

    var outputLevelDB: Float {
        levelToDecibels(outputLevel)
    }

    private func levelToDecibels(_ level: Float) -> Float {
        guard level > 0 else { return -Float.infinity }
        return 20 * log10(level)
    }
}

// MARK: - TunerData（チューナーデータ）

struct TunerData: Sendable {
    let frequency: Float
    let noteName: String
    let octave: Int
    let centsOff: Float
    let isInTune: Bool

    static let empty = TunerData(
        frequency: 0,
        noteName: "—",
        octave: 0,
        centsOff: 0,
        isInTune: false
    )

    var noteWithOctave: String {
        guard frequency > 0 else { return "—" }
        return "\(noteName)\(octave)"
    }

    var tuningStatus: TuningStatus {
        if abs(centsOff) < 3 { return .inTune }
        if centsOff > 0 { return .sharp }
        return .flat
    }
}

enum TuningStatus: Sendable {
    case flat
    case inTune
    case sharp

    var label: String {
        switch self {
        case .flat: "♭ フラット"
        case .inTune: "✓ チューニング完了"
        case .sharp: "♯ シャープ"
        }
    }

    var colorName: String {
        switch self {
        case .flat: "red"
        case .inTune: "green"
        case .sharp: "red"
        }
    }
}
