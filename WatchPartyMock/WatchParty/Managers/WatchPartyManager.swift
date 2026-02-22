import Foundation

@MainActor
@Observable
final class WatchPartyManager {
    static let shared = WatchPartyManager()
    private init() {
        participants = Participant.samples
        reactions = Reaction.samples
        chatMessages = ChatMessage.samples
    }

    // MARK: - Session State

    private(set) var isSessionActive = false
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 1425
    private(set) var playbackRate: Float = 1.0
    private(set) var volume: Float = 0.8

    // MARK: - Participants

    private(set) var participants: [Participant] = []

    // MARK: - Reactions & Chat

    private(set) var reactions: [Reaction] = []
    private(set) var chatMessages: [ChatMessage] = []

    // MARK: - Voice Chat

    private(set) var isVoiceChatEnabled = false
    private(set) var isMicMuted = false

    // MARK: - PiP

    private(set) var isPiPActive = false

    // MARK: - Simulation

    private var playbackTimer: Timer?
    private var syncSimulationTimer: Timer?

    // MARK: - Computed

    var syncedCount: Int {
        participants.filter { $0.syncStatus == .synced }.count
    }

    var totalParticipants: Int {
        participants.count
    }

    var hostName: String {
        participants.first { $0.isHost }?.name ?? "不明"
    }

    var recentReactions: [Reaction] {
        Array(reactions.suffix(6))
    }

    // MARK: - Session Control

    func startSession() {
        isSessionActive = true
        isPlaying = true
        startPlayback()
        startSyncSimulation()
    }

    func endSession() {
        isSessionActive = false
        isPlaying = false
        stopPlayback()
        stopSyncSimulation()
    }

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startPlayback()
        } else {
            stopPlayback()
        }
    }

    func seek(to time: TimeInterval) {
        currentTime = max(0, time)
    }

    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
    }

    func setVolume(_ vol: Float) {
        volume = max(0, min(1, vol))
    }

    // MARK: - Voice Chat

    func toggleVoiceChat() {
        isVoiceChatEnabled.toggle()
        if !isVoiceChatEnabled {
            isMicMuted = false
        }
    }

    func toggleMic() {
        isMicMuted.toggle()
    }

    // MARK: - PiP

    func togglePiP() {
        isPiPActive.toggle()
    }

    // MARK: - Reactions

    func sendReaction(_ emoji: String, from senderName: String) {
        let reaction = Reaction(
            id: UUID(),
            emoji: emoji,
            participantName: senderName,
            timestamp: currentTime,
            date: Date()
        )
        reactions.append(reaction)
    }

    // MARK: - Chat

    func sendChatMessage(_ text: String, from senderName: String) {
        let message = ChatMessage(
            id: UUID(),
            text: text,
            senderName: senderName,
            timestamp: currentTime,
            date: Date()
        )
        chatMessages.append(message)
    }

    // MARK: - Participant Management

    func inviteParticipant(name: String) {
        let colors = Participant.ParticipantColor.allCases
        let color = colors[participants.count % colors.count]
        let participant = Participant(
            id: UUID(), name: name, avatarColor: color,
            syncStatus: .synced, isMuted: false, isHost: false
        )
        participants.append(participant)
    }

    func removeParticipant(_ participant: Participant) {
        participants.removeAll { $0.id == participant.id }
    }

    // MARK: - Private

    private func startPlayback() {
        stopPlayback()
        playbackTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying else { return }
                self.currentTime += Double(self.playbackRate)
            }
        }
    }

    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func startSyncSimulation() {
        stopSyncSimulation()
        syncSimulationTimer = Timer.scheduledTimer(
            withTimeInterval: 3.0, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.simulateSyncChange()
            }
        }
    }

    private func stopSyncSimulation() {
        syncSimulationTimer?.invalidate()
        syncSimulationTimer = nil
    }

    private func simulateSyncChange() {
        guard participants.count > 1 else { return }
        let index = Int.random(in: 1..<participants.count)
        let statuses: [Participant.SyncStatus] = [.synced, .synced, .synced, .buffering]
        participants[index].syncStatus = statuses.randomElement() ?? .synced
    }
}
