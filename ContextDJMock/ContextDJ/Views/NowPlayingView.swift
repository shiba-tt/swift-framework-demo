import SwiftUI

struct NowPlayingView: View {
    @Bindable var viewModel: ContextDJViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let song = viewModel.currentSong {
                        nowPlayingContent(song)
                    } else {
                        idleContent
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Context DJ")
        }
    }

    // MARK: - Idle Content

    private var idleContent: some View {
        VStack(spacing: 24) {
            contextBanner

            Text("ムードを選んで再生")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(MoodType.allCases) { mood in
                    moodCard(mood)
                }
            }

            quickPlayButton
        }
    }

    // MARK: - Context Banner

    private var contextBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)

            Text("あなたの状況に合わせた音楽")
                .font(.title3.bold())
                .foregroundStyle(.white)

            if let context = viewModel.currentContext {
                HStack(spacing: 8) {
                    Label(context.timeOfDay.displayName, systemImage: context.timeOfDay.icon)
                    if let weather = context.weather {
                        Label(weather.displayName, systemImage: weather.icon)
                    }
                    if let location = context.location {
                        Label(location.displayName, systemImage: location.icon)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            LinearGradient(
                colors: [.indigo, .purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Mood Card

    private func moodCard(_ mood: MoodType) -> some View {
        Button {
            viewModel.playWithMood(mood)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .font(.title2)
                    .foregroundStyle(mood.color)

                Text(mood.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(mood.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Quick Play Button

    private var quickPlayButton: some View {
        Button {
            viewModel.playContextual()
        } label: {
            Label("コンテキスト自動再生", systemImage: "waveform")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Now Playing Content

    private func nowPlayingContent(_ song: Song) -> some View {
        VStack(spacing: 20) {
            artwork(song)
            songInfo(song)
            progressBar(song)
            playbackControls
            contextTag
            queueSection
        }
    }

    // MARK: - Artwork

    private func artwork(_ song: Song) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [song.artworkColor, song.artworkColor.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 280)
            .overlay {
                VStack {
                    Image(systemName: song.genre.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(.white.opacity(0.8))

                    Text(song.genre.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .shadow(color: song.artworkColor.opacity(0.4), radius: 20, y: 10)
    }

    // MARK: - Song Info

    private func songInfo(_ song: Song) -> some View {
        VStack(spacing: 4) {
            Text(song.title)
                .font(.title2.bold())

            Text(song.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(song.bpm) BPM", systemImage: "metronome")
                Label("Energy: \(song.energyLevel)", systemImage: "bolt.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Progress Bar

    private func progressBar(_ song: Song) -> some View {
        VStack(spacing: 4) {
            ProgressView(value: viewModel.playbackProgress)
                .tint(song.artworkColor)

            HStack {
                Text(viewModel.progressText)
                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button { viewModel.previousSong() } label: {
                Image(systemName: "backward.fill")
                    .font(.title2)
            }

            Button { viewModel.togglePlayback() } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
            }

            Button { viewModel.nextSong() } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Context Tag

    private var contextTag: some View {
        Group {
            if let playlist = viewModel.currentPlaylist {
                HStack(spacing: 8) {
                    Image(systemName: playlist.mood.icon)
                        .foregroundStyle(playlist.mood.color)

                    Text(playlist.context.contextTag)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button { viewModel.findSimilar() } label: {
                        Label("似た曲", systemImage: "sparkles")
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Queue Section

    private var queueSection: some View {
        Group {
            let queued = viewModel.queuedSongs
            if !queued.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("次に再生")
                        .font(.headline)

                    ForEach(Array(queued.enumerated()), id: \.element.id) { offset, song in
                        HStack {
                            Text("\(offset + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            Circle()
                                .fill(song.artworkColor)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: song.genre.icon)
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                }

                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.subheadline)
                                Text(song.artist)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(song.durationText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.skipToSong(at: viewModel.currentSongIndex + offset + 1)
                        }
                    }
                }
            }
        }
    }
}
