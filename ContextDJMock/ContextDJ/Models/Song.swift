import Foundation
import SwiftUI

// MARK: - Genre

enum Genre: String, Sendable, CaseIterable {
    case pop
    case rock
    case jazz
    case lofi
    case electronic
    case classical
    case hiphop
    case ambient

    var displayName: String {
        switch self {
        case .pop: "ポップ"
        case .rock: "ロック"
        case .jazz: "ジャズ"
        case .lofi: "ローファイ"
        case .electronic: "エレクトロニック"
        case .classical: "クラシック"
        case .hiphop: "ヒップホップ"
        case .ambient: "アンビエント"
        }
    }

    var icon: String {
        switch self {
        case .pop: "star.fill"
        case .rock: "guitars.fill"
        case .jazz: "music.quarternote.3"
        case .lofi: "headphones"
        case .electronic: "waveform"
        case .classical: "pianokeys"
        case .hiphop: "mic.fill"
        case .ambient: "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .pop: .pink
        case .rock: .red
        case .jazz: .orange
        case .lofi: .purple
        case .electronic: .cyan
        case .classical: .brown
        case .hiphop: .yellow
        case .ambient: .green
        }
    }
}

// MARK: - Song

struct Song: Identifiable, Sendable {
    let id: UUID
    let title: String
    let artist: String
    let genre: Genre
    let durationSeconds: Int
    let bpm: Int
    let energy: Double
    let artworkColor: Color

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        genre: Genre,
        durationSeconds: Int = 240,
        bpm: Int = 120,
        energy: Double = 0.7,
        artworkColor: Color = .blue
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.genre = genre
        self.durationSeconds = durationSeconds
        self.bpm = bpm
        self.energy = energy
        self.artworkColor = artworkColor
    }

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var energyLevel: String {
        switch energy {
        case 0..<0.3: "低"
        case 0.3..<0.6: "中"
        case 0.6..<0.8: "高"
        default: "最高"
        }
    }
}
