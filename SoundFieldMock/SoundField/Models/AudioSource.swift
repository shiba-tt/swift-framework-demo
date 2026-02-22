import Foundation
import SwiftUI

// MARK: - AudioTrack（再生する音楽トラック）

struct AudioTrack: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let artist: String
    let genre: AudioGenre
    let durationSeconds: Int
    let bpm: Int

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - AudioGenre（ジャンル）

enum AudioGenre: String, CaseIterable, Sendable {
    case electronic = "Electronic"
    case ambient = "Ambient"
    case lofi = "Lo-Fi"
    case house = "House"
    case jazz = "Jazz"

    var color: Color {
        switch self {
        case .electronic: .purple
        case .ambient:    .teal
        case .lofi:       .orange
        case .house:      .pink
        case .jazz:       .yellow
        }
    }

    var icon: String {
        switch self {
        case .electronic: "bolt.fill"
        case .ambient:    "leaf.fill"
        case .lofi:       "headphones"
        case .house:      "speaker.wave.3.fill"
        case .jazz:       "music.quarternote.3"
        }
    }
}

// MARK: - SoundZone（距離ゾーン別のエフェクト）

enum SoundZone: String, Sendable {
    case intimate  = "Intimate"
    case near      = "Near"
    case mid       = "Mid"
    case far       = "Far"

    /// 距離（メートル）からゾーンを判定
    static func from(distance: Float) -> SoundZone {
        switch distance {
        case ..<1.0:  .intimate
        case ..<3.0:  .near
        case ..<6.0:  .mid
        default:      .far
        }
    }

    var displayName: String {
        switch self {
        case .intimate: "至近距離"
        case .near:     "近距離"
        case .mid:      "中距離"
        case .far:      "遠距離"
        }
    }

    var effectDescription: String {
        switch self {
        case .intimate: "Bass Boost + 最大音量"
        case .near:     "バランスサウンド"
        case .mid:      "リバーブ追加"
        case .far:      "エコー + 小音量"
        }
    }

    var color: Color {
        switch self {
        case .intimate: .red
        case .near:     .green
        case .mid:      .blue
        case .far:      .purple
        }
    }

    var icon: String {
        switch self {
        case .intimate: "speaker.wave.3.fill"
        case .near:     "speaker.wave.2.fill"
        case .mid:      "speaker.wave.1.fill"
        case .far:      "speaker.fill"
        }
    }

    /// ゾーンに応じた音量（0.0〜1.0）
    var volume: Double {
        switch self {
        case .intimate: 1.0
        case .near:     0.75
        case .mid:      0.45
        case .far:      0.2
        }
    }

    /// ゾーンに応じた Bass ブースト量
    var bassBoost: Double {
        switch self {
        case .intimate: 0.8
        case .near:     0.4
        case .mid:      0.1
        case .far:      0.0
        }
    }

    /// ゾーンに応じたリバーブ量
    var reverb: Double {
        switch self {
        case .intimate: 0.0
        case .near:     0.2
        case .mid:      0.5
        case .far:      0.8
        }
    }
}

// MARK: - Listener（リスナーデバイス）

struct Listener: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let distance: Float
    let direction: SIMD3<Float>
    let signalStrength: Double

    var zone: SoundZone {
        SoundZone.from(distance: distance)
    }

    var distanceText: String {
        if distance < 1.0 {
            return String(format: "%.0f cm", distance * 100)
        }
        return String(format: "%.1f m", distance)
    }

    /// 方向を角度（度）に変換
    var angleDegrees: Double {
        let angle = atan2(Double(direction.x), Double(-direction.z))
        return angle * 180 / .pi
    }
}

// MARK: - SessionMode（セッションモード）

enum SessionMode: String, CaseIterable, Sendable {
    case host = "ホスト"
    case listener = "リスナー"

    var icon: String {
        switch self {
        case .host:     "music.note.house.fill"
        case .listener: "ear.fill"
        }
    }

    var description: String {
        switch self {
        case .host:     "音源を再生し、リスナーの位置に応じてエフェクトを適用"
        case .listener: "ホストの音楽を空間オーディオで体験"
        }
    }
}
