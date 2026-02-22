import Foundation
import SwiftUI

// MARK: - PlaybackState

enum PlaybackState: Sendable {
    case idle
    case playing
    case paused
}

// MARK: - ContextDJViewModel

@MainActor
@Observable
final class ContextDJViewModel {

    // MARK: - State

    private(set) var currentPlaylist: Playlist?
    private(set) var currentSongIndex: Int = 0
    private(set) var recentPlaylists: [Playlist] = []
    var playbackState: PlaybackState = .idle
    var selectedMood: MoodType?
    var currentContext: ContextCondition?
    var playbackProgress: Double = 0
    var showingMoodPicker = false
    var showingSimilarSongs = false
    private(set) var similarSongs: [Song] = []

    // MARK: - Dependencies

    private let contextManager = MusicContextManager.shared
    private var progressTimer: Timer?

    // MARK: - Computed

    var currentSong: Song? {
        guard let playlist = currentPlaylist,
              currentSongIndex < playlist.songs.count else {
            return nil
        }
        return playlist.songs[currentSongIndex]
    }

    var isPlaying: Bool {
        playbackState == .playing
    }

    var suggestedMoods: [MoodType] {
        let context = currentContext ?? contextManager.detectCurrentContext()
        let primaryMood = contextManager.suggestMood(for: context)
        var moods = [primaryMood]
        for mood in MoodType.allCases where mood != primaryMood && moods.count < 3 {
            moods.append(mood)
        }
        return moods
    }

    var progressText: String {
        guard let song = currentSong else { return "0:00 / 0:00" }
        let current = Int(Double(song.durationSeconds) * playbackProgress)
        let total = song.durationSeconds
        let currentMin = current / 60
        let currentSec = current % 60
        let totalMin = total / 60
        let totalSec = total % 60
        return String(format: "%d:%02d / %d:%02d", currentMin, currentSec, totalMin, totalSec)
    }

    var queuedSongs: [Song] {
        guard let playlist = currentPlaylist else { return [] }
        let remaining = playlist.songs.dropFirst(currentSongIndex + 1)
        return Array(remaining)
    }

    // MARK: - Actions

    func loadInitialState() {
        currentContext = contextManager.detectCurrentContext()
        recentPlaylists = contextManager.recentPlaylists
    }

    func playContextual() {
        let playlist = contextManager.generateContextualPlaylist()
        startPlaylist(playlist)
    }

    func playWithMood(_ mood: MoodType) {
        let context = currentContext ?? contextManager.detectCurrentContext()
        let playlist = contextManager.generatePlaylist(mood: mood, context: context)
        startPlaylist(playlist)
        selectedMood = mood
    }

    func togglePlayback() {
        switch playbackState {
        case .idle:
            playContextual()
        case .playing:
            pausePlayback()
        case .paused:
            resumePlayback()
        }
    }

    func nextSong() {
        guard let playlist = currentPlaylist else { return }
        if currentSongIndex < playlist.songs.count - 1 {
            currentSongIndex += 1
            playbackProgress = 0
        }
    }

    func previousSong() {
        if playbackProgress > 0.1 {
            playbackProgress = 0
        } else if currentSongIndex > 0 {
            currentSongIndex -= 1
            playbackProgress = 0
        }
    }

    func skipToSong(at index: Int) {
        guard let playlist = currentPlaylist, index < playlist.songs.count else { return }
        currentSongIndex = index
        playbackProgress = 0
        playbackState = .playing
        startProgressSimulation()
    }

    func findSimilar() {
        guard let song = currentSong else { return }
        similarSongs = contextManager.findSimilarSongs(to: song)
        showingSimilarSongs = true
    }

    func refreshContext() {
        currentContext = contextManager.detectCurrentContext()
    }

    // MARK: - Private

    private func startPlaylist(_ playlist: Playlist) {
        currentPlaylist = playlist
        currentSongIndex = 0
        playbackProgress = 0
        playbackState = .playing
        recentPlaylists = contextManager.recentPlaylists
        startProgressSimulation()
    }

    private func pausePlayback() {
        playbackState = .paused
        stopProgressSimulation()
    }

    private func resumePlayback() {
        playbackState = .playing
        startProgressSimulation()
    }

    private func startProgressSimulation() {
        stopProgressSimulation()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.playbackState == .playing else { return }
                guard let song = self.currentSong else { return }
                let increment = 0.5 / Double(song.durationSeconds)
                self.playbackProgress = min(1.0, self.playbackProgress + increment)

                if self.playbackProgress >= 1.0 {
                    self.nextSong()
                }
            }
        }
    }

    private func stopProgressSimulation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
