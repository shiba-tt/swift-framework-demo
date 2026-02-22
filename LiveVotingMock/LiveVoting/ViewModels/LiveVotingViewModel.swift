import Foundation
import SwiftUI

// MARK: - LiveVotingViewModel

@MainActor
@Observable
final class LiveVotingViewModel {

    // MARK: - State

    private(set) var events: [Event] = []
    var selectedEvent: Event?
    var selectedSession: VotingSession?
    var selectedOptionID: UUID?
    var showingVoteConfirmation = false
    var showingResults = false
    var lightShowActive = false
    var lightShowColor: Color = .clear
    var voteSubmitted = false
    var participantCount: Int = 0

    // MARK: - Dependencies

    private let votingManager = VotingManager.shared
    private var simulationTimer: Timer?

    // MARK: - Computed

    var activeEvents: [Event] {
        votingManager.events.filter { $0.status == .live }
    }

    var currentSessions: [VotingSession] {
        selectedEvent?.activeSessions ?? []
    }

    var totalParticipants: Int {
        selectedEvent?.totalParticipants ?? 0
    }

    func hasVoted(session: VotingSession) -> Bool {
        votingManager.hasVoted(sessionID: session.id)
    }

    func votePercentage(option: VoteOption, in session: VotingSession) -> Double {
        option.votePercentage(totalVotes: session.totalVotes)
    }

    // MARK: - Actions

    func loadEvents() {
        events = votingManager.events
        startParticipantSimulation()
    }

    func selectEvent(_ event: Event) {
        selectedEvent = event
        selectedSession = nil
        selectedOptionID = nil
    }

    func selectSession(_ session: VotingSession) {
        selectedSession = session
        selectedOptionID = nil
        voteSubmitted = false
    }

    func selectOption(_ optionID: UUID) {
        selectedOptionID = optionID
    }

    func submitVote() {
        guard let event = selectedEvent,
              let session = selectedSession,
              let optionID = selectedOptionID else {
            return
        }

        let success = votingManager.castVote(
            eventID: event.id,
            sessionID: session.id,
            optionID: optionID
        )

        if success {
            voteSubmitted = true
            refreshEventData()

            if session.sessionType == .lightShow,
               let option = session.options.first(where: { $0.id == optionID }) {
                activateLightShow(color: option.color)
            }
        }
    }

    func showSessionResults(_ session: VotingSession) {
        guard let event = selectedEvent else { return }
        votingManager.closeSession(eventID: event.id, sessionID: session.id)
        refreshEventData()
        showingResults = true
    }

    func activateLightShow(color: Color) {
        lightShowColor = color
        lightShowActive = true
    }

    func deactivateLightShow() {
        lightShowActive = false
        lightShowColor = .clear
    }

    func reset() {
        selectedEvent = nil
        selectedSession = nil
        selectedOptionID = nil
        showingVoteConfirmation = false
        showingResults = false
        voteSubmitted = false
        deactivateLightShow()
        stopParticipantSimulation()
    }

    // MARK: - Private

    private func refreshEventData() {
        events = votingManager.events
        if let eventID = selectedEvent?.id {
            selectedEvent = events.first(where: { $0.id == eventID })
        }
        if let sessionID = selectedSession?.id {
            selectedSession = selectedEvent?.sessions.first(where: { $0.id == sessionID })
        }
    }

    private func startParticipantSimulation() {
        participantCount = Int.random(in: 8000...15000)
        simulationTimer?.invalidate()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.participantCount += Int.random(in: 1...10)
            }
        }
    }

    private func stopParticipantSimulation() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
}
