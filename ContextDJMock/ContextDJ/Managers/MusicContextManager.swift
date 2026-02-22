import Foundation
import SwiftUI

// MARK: - MusicContextManager

@MainActor
@Observable
final class MusicContextManager {
    static let shared = MusicContextManager()

    private(set) var recentPlaylists: [Playlist] = []
    private(set) var allSongs: [Song] = []

    private init() {
        allSongs = Self.generateSampleSongs()
    }

    // MARK: - Context Detection

    func detectCurrentContext() -> ContextCondition {
        ContextCondition(
            timeOfDay: TimeOfDay.current(),
            weather: WeatherCondition.allCases.randomElement(),
            location: LocationType.allCases.randomElement(),
            activity: ActivityType.allCases.randomElement()
        )
    }

    // MARK: - Playlist Generation

    func generatePlaylist(mood: MoodType, context: ContextCondition) -> Playlist {
        let matchingSongs = allSongs.filter { song in
            mood.preferredGenres.contains(song.genre)
        }.shuffled()

        let selectedSongs = Array(matchingSongs.prefix(8))

        let playlist = Playlist(
            name: "\(mood.displayName) — \(context.timeOfDay.displayName)",
            mood: mood,
            context: context,
            songs: selectedSongs
        )

        recentPlaylists.insert(playlist, at: 0)
        if recentPlaylists.count > 10 {
            recentPlaylists = Array(recentPlaylists.prefix(10))
        }

        return playlist
    }

    func generateContextualPlaylist() -> Playlist {
        let context = detectCurrentContext()
        let mood = suggestMood(for: context)
        return generatePlaylist(mood: mood, context: context)
    }

    func suggestMood(for context: ContextCondition) -> MoodType {
        switch context.timeOfDay {
        case .earlyMorning: return .relax
        case .morning: return .commute
        case .afternoon: return .focus
        case .evening: return .relax
        case .night: return .party
        case .lateNight: return .sleep
        }
    }

    func findSimilarSongs(to song: Song) -> [Song] {
        allSongs
            .filter { $0.id != song.id && $0.genre == song.genre }
            .sorted { abs($0.energy - song.energy) < abs($1.energy - song.energy) }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Sample Data

    private static func generateSampleSongs() -> [Song] {
        [
            // Pop
            Song(title: "Sunshine Melody", artist: "Hana", genre: .pop, durationSeconds: 215, bpm: 118, energy: 0.75, artworkColor: .pink),
            Song(title: "Dancing Stars", artist: "YUKI", genre: .pop, durationSeconds: 198, bpm: 125, energy: 0.85, artworkColor: .purple),
            Song(title: "Summer Breeze", artist: "Aoi", genre: .pop, durationSeconds: 232, bpm: 110, energy: 0.65, artworkColor: .cyan),
            Song(title: "Heartbeat City", artist: "Rina", genre: .pop, durationSeconds: 207, bpm: 130, energy: 0.80, artworkColor: .red),

            // Rock
            Song(title: "Thunder Road", artist: "KAZE", genre: .rock, durationSeconds: 264, bpm: 140, energy: 0.90, artworkColor: .red),
            Song(title: "Midnight Drive", artist: "ARASHI", genre: .rock, durationSeconds: 289, bpm: 135, energy: 0.85, artworkColor: .orange),
            Song(title: "Electric Storm", artist: "BOLT", genre: .rock, durationSeconds: 245, bpm: 150, energy: 0.95, artworkColor: .yellow),

            // Jazz
            Song(title: "Café Nocturne", artist: "Taro Sato Trio", genre: .jazz, durationSeconds: 356, bpm: 85, energy: 0.35, artworkColor: .orange),
            Song(title: "Velvet Moon", artist: "Yuko Tanaka", genre: .jazz, durationSeconds: 312, bpm: 75, energy: 0.30, artworkColor: .brown),
            Song(title: "Autumn Leaves Revisited", artist: "Jazz Collective", genre: .jazz, durationSeconds: 287, bpm: 90, energy: 0.40, artworkColor: .yellow),

            // Lo-fi
            Song(title: "Rainy Window Study", artist: "lofi_chill", genre: .lofi, durationSeconds: 180, bpm: 72, energy: 0.25, artworkColor: .purple),
            Song(title: "Late Night Coding", artist: "beats_to_study", genre: .lofi, durationSeconds: 195, bpm: 68, energy: 0.20, artworkColor: .indigo),
            Song(title: "Coffee & Pages", artist: "chillhop_daily", genre: .lofi, durationSeconds: 210, bpm: 75, energy: 0.30, artworkColor: .brown),
            Song(title: "Sunset Balcony", artist: "lofi_chill", genre: .lofi, durationSeconds: 168, bpm: 70, energy: 0.22, artworkColor: .orange),

            // Electronic
            Song(title: "Neon Pulse", artist: "DJ HIKARI", genre: .electronic, durationSeconds: 312, bpm: 128, energy: 0.92, artworkColor: .cyan),
            Song(title: "Digital Horizon", artist: "SYNTH_X", genre: .electronic, durationSeconds: 278, bpm: 135, energy: 0.88, artworkColor: .blue),
            Song(title: "Bass Drop Galaxy", artist: "WAVEFORM", genre: .electronic, durationSeconds: 245, bpm: 140, energy: 0.95, artworkColor: .purple),

            // Classical
            Song(title: "朝の光", artist: "東京フィル", genre: .classical, durationSeconds: 420, bpm: 60, energy: 0.15, artworkColor: .brown),
            Song(title: "月明かりソナタ", artist: "Kenji Yamamoto", genre: .classical, durationSeconds: 380, bpm: 55, energy: 0.10, artworkColor: .indigo),
            Song(title: "春の声", artist: "室内楽団", genre: .classical, durationSeconds: 350, bpm: 70, energy: 0.25, artworkColor: .green),

            // Hip-hop
            Song(title: "City Lights Flow", artist: "MC TAKU", genre: .hiphop, durationSeconds: 198, bpm: 95, energy: 0.78, artworkColor: .yellow),
            Song(title: "Tokyo Drift Beat", artist: "RYU-ONE", genre: .hiphop, durationSeconds: 215, bpm: 88, energy: 0.72, artworkColor: .red),
            Song(title: "Shibuya Cypher", artist: "CREW X", genre: .hiphop, durationSeconds: 267, bpm: 92, energy: 0.80, artworkColor: .orange),

            // Ambient
            Song(title: "Ocean Whisper", artist: "Nature Sound", genre: .ambient, durationSeconds: 480, bpm: 40, energy: 0.05, artworkColor: .blue),
            Song(title: "Forest Rain", artist: "Zen Garden", genre: .ambient, durationSeconds: 420, bpm: 45, energy: 0.08, artworkColor: .green),
            Song(title: "Starry Night Drift", artist: "Cosmos", genre: .ambient, durationSeconds: 390, bpm: 50, energy: 0.12, artworkColor: .indigo),
        ]
    }
}
