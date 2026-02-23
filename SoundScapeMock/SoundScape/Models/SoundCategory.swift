import SwiftUI

/// 環境音のカテゴリ分類
enum SoundCategory: String, CaseIterable, Identifiable, Sendable {
    case bird = "鳥の声"
    case car = "車の走行音"
    case wind = "風"
    case voice = "人の話し声"
    case rain = "雨"
    case music = "音楽"
    case keyboard = "キーボード"
    case dog = "犬の鳴き声"
    case siren = "サイレン"
    case silence = "静寂"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .bird: "🐦"
        case .car: "🚗"
        case .wind: "💨"
        case .voice: "🗣️"
        case .rain: "🌧️"
        case .music: "🎵"
        case .keyboard: "⌨️"
        case .dog: "🐕"
        case .siren: "🚨"
        case .silence: "🤫"
        }
    }

    var color: Color {
        switch self {
        case .bird: .green
        case .car: .gray
        case .wind: .cyan
        case .voice: .orange
        case .rain: .blue
        case .music: .purple
        case .keyboard: .indigo
        case .dog: .brown
        case .siren: .red
        case .silence: .secondary
        }
    }

    var systemImageName: String {
        switch self {
        case .bird: "bird"
        case .car: "car.fill"
        case .wind: "wind"
        case .voice: "person.wave.2"
        case .rain: "cloud.rain.fill"
        case .music: "music.note"
        case .keyboard: "keyboard"
        case .dog: "dog.fill"
        case .siren: "light.beacon.max.fill"
        case .silence: "speaker.slash"
        }
    }
}
