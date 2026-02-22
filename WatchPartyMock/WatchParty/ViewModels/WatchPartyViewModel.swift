import Foundation

@MainActor
@Observable
final class WatchPartyViewModel {
    let manager = WatchPartyManager.shared

    // MARK: - UI State

    var selectedTab: AppTab = .party
    var selectedContent: VideoContent?
    var showContentPicker = false
    var showParticipantList = false
    var showChat = false
    var chatInputText = ""
    var showInviteSheet = false
    var inviteName = ""

    // MARK: - Content Library

    let videoLibrary: [VideoContent] = VideoContent.samples

    enum AppTab: String, CaseIterable, Sendable {
        case party = "パーティ"
        case library = "ライブラリ"
        case history = "履歴"

        var systemImageName: String {
            switch self {
            case .party: return "play.rectangle.fill"
            case .library: return "film.stack"
            case .history: return "clock.fill"
            }
        }
    }

    // MARK: - Computed Delegates

    var isSessionActive: Bool { manager.isSessionActive }
    var isPlaying: Bool { manager.isPlaying }
    var currentTime: TimeInterval { manager.currentTime }
    var playbackRate: Float { manager.playbackRate }
    var volume: Float { manager.volume }
    var participants: [Participant] { manager.participants }
    var reactions: [Reaction] { manager.reactions }
    var chatMessages: [ChatMessage] { manager.chatMessages }
    var isVoiceChatEnabled: Bool { manager.isVoiceChatEnabled }
    var isMicMuted: Bool { manager.isMicMuted }
    var isPiPActive: Bool { manager.isPiPActive }
    var syncedCount: Int { manager.syncedCount }
    var totalParticipants: Int { manager.totalParticipants }
    var recentReactions: [Reaction] { manager.recentReactions }

    var currentTimeText: String {
        formatTime(currentTime)
    }

    var durationText: String {
        guard let content = selectedContent else { return "0:00" }
        return formatTime(content.durationSeconds)
    }

    var progress: Double {
        guard let content = selectedContent, content.durationSeconds > 0 else { return 0 }
        return currentTime / content.durationSeconds
    }

    var playbackRateText: String {
        if playbackRate == 1.0 { return "1x" }
        return String(format: "%.1fx", playbackRate)
    }

    // MARK: - Actions

    func selectAndPlay(_ content: VideoContent) {
        selectedContent = content
        showContentPicker = false
        if !manager.isSessionActive {
            manager.startSession()
        }
        manager.seek(to: 0)
    }

    func togglePlayback() {
        manager.togglePlayback()
    }

    func seekForward() {
        manager.seek(to: currentTime + 15)
    }

    func seekBackward() {
        manager.seek(to: currentTime - 15)
    }

    func seek(to fraction: Double) {
        guard let content = selectedContent else { return }
        let time = fraction * content.durationSeconds
        manager.seek(to: time)
    }

    func cyclePlaybackRate() {
        let rates: [Float] = [0.5, 1.0, 1.25, 1.5, 2.0]
        let currentIndex = rates.firstIndex(of: playbackRate) ?? 1
        let nextIndex = (currentIndex + 1) % rates.count
        manager.setPlaybackRate(rates[nextIndex])
    }

    func sendReaction(_ emoji: String) {
        manager.sendReaction(emoji, from: "あなた")
    }

    func sendChatMessage() {
        let text = chatInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        manager.sendChatMessage(text, from: "あなた")
        chatInputText = ""
    }

    func toggleVoiceChat() {
        manager.toggleVoiceChat()
    }

    func toggleMic() {
        manager.toggleMic()
    }

    func togglePiP() {
        manager.togglePiP()
    }

    func endSession() {
        manager.endSession()
        selectedContent = nil
    }

    func inviteParticipant() {
        let name = inviteName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        manager.inviteParticipant(name: name)
        inviteName = ""
        showInviteSheet = false
    }

    func removeParticipant(_ participant: Participant) {
        manager.removeParticipant(participant)
    }

    // MARK: - Private

    private func formatTime(_ time: TimeInterval) -> String {
        let total = max(0, Int(time))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
