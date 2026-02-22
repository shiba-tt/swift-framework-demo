import Foundation

/// ボイスエフェクトのプリセット定義
enum VoicePreset: String, CaseIterable, Identifiable, Sendable {
    case robot = "ロボット"
    case helium = "ヘリウム"
    case demon = "デーモン"
    case underwater = "水中"
    case alien = "宇宙人"
    case announcer = "アナウンサー"
    case chipmunk = "チップマンク"
    case echo = "エコー"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .robot:      return "🤖"
        case .helium:     return "🎈"
        case .demon:      return "👹"
        case .underwater: return "🌊"
        case .alien:      return "👽"
        case .announcer:  return "🎭"
        case .chipmunk:   return "🐿️"
        case .echo:       return "🔊"
        }
    }

    var systemImageName: String {
        switch self {
        case .robot:      return "cpu"
        case .helium:     return "balloon.fill"
        case .demon:      return "flame.fill"
        case .underwater: return "water.waves"
        case .alien:      return "sparkles"
        case .announcer:  return "mic.badge.xmark"
        case .chipmunk:   return "hare.fill"
        case .echo:       return "repeat"
        }
    }

    var description: String {
        switch self {
        case .robot:      return "メタリックなロボットボイス"
        case .helium:     return "ヘリウムガスを吸ったような高音"
        case .demon:      return "低く歪んだ悪魔の声"
        case .underwater: return "水中で話しているような音"
        case .alien:      return "宇宙人のような不思議な声"
        case .announcer:  return "響き渡るアナウンサーボイス"
        case .chipmunk:   return "超高音のかわいいボイス"
        case .echo:       return "山びこのようなエコー効果"
        }
    }

    /// プリセットのオーディオパラメータ
    var parameters: VoiceParameters {
        switch self {
        case .robot:
            return VoiceParameters(pitch: 0, rate: 1.0, reverb: 20, delay: 5, distortion: 60, eqLow: 5, eqMid: -3, eqHigh: 8)
        case .helium:
            return VoiceParameters(pitch: 800, rate: 1.1, reverb: 10, delay: 0, distortion: 0, eqLow: -5, eqMid: 0, eqHigh: 10)
        case .demon:
            return VoiceParameters(pitch: -600, rate: 0.85, reverb: 40, delay: 10, distortion: 30, eqLow: 10, eqMid: 0, eqHigh: -5)
        case .underwater:
            return VoiceParameters(pitch: -100, rate: 0.95, reverb: 70, delay: 20, distortion: 0, eqLow: 8, eqMid: -8, eqHigh: -10)
        case .alien:
            return VoiceParameters(pitch: 400, rate: 1.05, reverb: 50, delay: 30, distortion: 20, eqLow: -3, eqMid: 5, eqHigh: 8)
        case .announcer:
            return VoiceParameters(pitch: -200, rate: 0.9, reverb: 35, delay: 0, distortion: 0, eqLow: 3, eqMid: 5, eqHigh: 2)
        case .chipmunk:
            return VoiceParameters(pitch: 1200, rate: 1.3, reverb: 5, delay: 0, distortion: 0, eqLow: -8, eqMid: 3, eqHigh: 10)
        case .echo:
            return VoiceParameters(pitch: 0, rate: 1.0, reverb: 60, delay: 50, distortion: 0, eqLow: 0, eqMid: 0, eqHigh: 0)
        }
    }
}
