import Foundation
import SwiftUI

/// ジェネラティブアートのパーティクル
struct EnergyParticle: Identifiable, Sendable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: Double
    var opacity: Double
    var color: Color
    var type: ParticleType
}

/// パーティクルの種類
enum ParticleType: Sendable {
    case leaf    // クリーン時：葉のパーティクル
    case wind    // 風力：風のパーティクル
    case sun     // 太陽光：光のパーティクル
    case smoke   // ダーティ時：煙のパーティクル

    var systemImage: String {
        switch self {
        case .leaf: "leaf.fill"
        case .wind: "wind"
        case .sun: "sun.max.fill"
        case .smoke: "cloud.fill"
        }
    }
}

/// アートの波形データ
struct WaveData: Sendable {
    let amplitude: Double
    let frequency: Double
    let phase: Double
    let color: Color
}

/// アートテーマ
enum ArtTheme: String, CaseIterable, Sendable {
    case wave = "波形"
    case particle = "パーティクル"
    case gradient = "グラデーション"

    var icon: String {
        switch self {
        case .wave: "waveform"
        case .particle: "sparkles"
        case .gradient: "paintpalette.fill"
        }
    }
}
