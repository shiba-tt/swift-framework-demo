import Foundation

/// スペクトログラム表示用のデータ
struct SpectrumData: Sendable {
    let bands: [Float]
    let timestamp: Date

    init(bands: [Float], timestamp: Date = .now) {
        self.bands = bands
        self.timestamp = timestamp
    }

    /// ダミースペクトラムデータを生成
    static func generateRandom(bandCount: Int = 32) -> SpectrumData {
        let bands = (0..<bandCount).map { i in
            let base = Float.random(in: 0.05...0.6)
            let lowBoost: Float = i < 8 ? 0.2 : 0.0
            let midBoost: Float = (i >= 8 && i < 20) ? 0.1 : 0.0
            return min(1.0, base + lowBoost + midBoost)
        }
        return SpectrumData(bands: bands)
    }
}

/// 騒音レベルの評価
enum NoiseLevel: Sendable {
    case quiet       // ~40 dB
    case moderate    // 40~60 dB
    case loud        // 60~80 dB
    case veryLoud    // 80~100 dB
    case dangerous   // 100+ dB

    init(decibel: Double) {
        switch decibel {
        case ..<40: self = .quiet
        case 40..<60: self = .moderate
        case 60..<80: self = .loud
        case 80..<100: self = .veryLoud
        default: self = .dangerous
        }
    }

    var label: String {
        switch self {
        case .quiet: "静か"
        case .moderate: "普通"
        case .loud: "やや騒がしい"
        case .veryLoud: "騒がしい"
        case .dangerous: "危険"
        }
    }

    var emoji: String {
        switch self {
        case .quiet: "🤫"
        case .moderate: "🔈"
        case .loud: "🔉"
        case .veryLoud: "🔊"
        case .dangerous: "⚠️"
        }
    }

    var description: String {
        switch self {
        case .quiet: "図書館レベル"
        case .moderate: "通常の会話レベル"
        case .loud: "掃除機レベル"
        case .veryLoud: "電車内レベル"
        case .dangerous: "聴覚保護が必要"
        }
    }
}
