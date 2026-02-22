import Foundation

// MARK: - ARTimeTravelerViewModel

@MainActor
@Observable
final class ARTimeTravelerViewModel {

    // MARK: - State

    var selectedSpot: HistoricalSpot?
    var selectedEra: HistoricalEra?
    var isARActive = false
    var isAudioPlaying = false
    var audioProgress: Double = 0
    var showingSpotDetail = false
    var sliderYear: Double = 2025

    // MARK: - Dependencies

    private let spotManager = SpotManager.shared
    private var audioTimer: Timer?

    // MARK: - Computed

    var spots: [HistoricalSpot] {
        spotManager.spots
    }

    var visitRecords: [VisitRecord] {
        spotManager.visitRecords
    }

    var totalVisits: Int {
        spotManager.totalVisits
    }

    var uniqueSpotsVisited: Int {
        spotManager.uniqueSpotsVisited
    }

    var currentSnapshot: EraSnapshot? {
        guard let spot = selectedSpot, let era = selectedEra else { return nil }
        return spot.snapshot(for: era)
    }

    var availableEras: [HistoricalEra] {
        selectedSpot?.availableEras ?? []
    }

    var closestEra: HistoricalEra? {
        guard let spot = selectedSpot else { return nil }
        let targetYear = Int(sliderYear)
        return spot.snapshots.min { snap1, snap2 in
            abs(snap1.era.year - targetYear) < abs(snap2.era.year - targetYear)
        }?.era
    }

    var yearRangeForSlider: ClosedRange<Double> {
        guard let spot = selectedSpot,
              let minYear = spot.snapshots.map(\.era.year).min(),
              let maxYear = spot.snapshots.map(\.era.year).max() else {
            return 1600...2025
        }
        return Double(minYear)...Double(maxYear)
    }

    // MARK: - Actions

    func selectSpot(_ spot: HistoricalSpot) {
        selectedSpot = spot
        selectedEra = spot.snapshots.last?.era
        sliderYear = Double(spot.snapshots.last?.era.year ?? 2025)
        showingSpotDetail = true
    }

    func selectEra(_ era: HistoricalEra) {
        selectedEra = era
        sliderYear = Double(era.year)
    }

    func updateSliderYear(_ year: Double) {
        sliderYear = year
        if let era = closestEra {
            selectedEra = era
        }
    }

    func startAR() {
        isARActive = true
    }

    func stopAR() {
        isARActive = false
        stopAudio()
    }

    func toggleAudioGuide() {
        if isAudioPlaying {
            stopAudio()
        } else {
            startAudio()
        }
    }

    func recordVisit() {
        guard let spot = selectedSpot else { return }
        let viewedEras = availableEras
        spotManager.recordVisit(
            spotID: spot.id,
            spotName: spot.name,
            erasViewed: viewedEras,
            audioGuideListened: isAudioPlaying || audioProgress > 0
        )
    }

    func scanNFCTag(tagID: String) {
        guard let spot = spotManager.spot(byNFCTag: tagID) else { return }
        selectSpot(spot)
        startAR()
    }

    // MARK: - Audio Simulation

    private func startAudio() {
        isAudioPlaying = true
        audioProgress = 0
        audioTimer?.invalidate()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.audioProgress += 0.5 / (self.currentSnapshot?.audioGuideDuration ?? 60)
                if self.audioProgress >= 1.0 {
                    self.audioProgress = 1.0
                    self.stopAudio()
                }
            }
        }
    }

    private func stopAudio() {
        isAudioPlaying = false
        audioTimer?.invalidate()
        audioTimer = nil
    }
}
