import Foundation
import SwiftUI

// MARK: - ARTimeMachineViewModel

@MainActor
@Observable
final class ARTimeMachineViewModel {

    // MARK: - State

    var spots: [HistoricalSpot] = HistoricalSpot.samples
    var selectedSpot: HistoricalSpot?
    var selectedTimePeriod: TimePeriod?
    var isARActive = false
    var isScanning = false
    var isLoading = false

    // Time Slider
    var sliderYear: Double = 2025
    var minYear: Double = 1600
    var maxYear: Double = 2060

    // AR Overlay
    var overlayMode: AROverlayMode = .semiTransparent
    var overlayOpacity: Double = 0.7

    // Filter
    var selectedCategory: SpotCategory?
    var searchText = ""
    var showFavoritesOnly = false

    // Scene Mesh
    var sceneMeshResult: SceneMeshResult?
    var facadeResult: FacadeDetectionResult?

    // Photo
    var capturedPhotoCount = 0
    var showingPhotoCapture = false

    // Detail
    var showingSpotDetail = false
    var showingHistory = false

    // MARK: - Dependencies

    let locationManager = LocationAnchorManager.shared

    // MARK: - Computed

    var filteredSpots: [HistoricalSpot] {
        var result = spots
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var favoriteCount: Int {
        spots.filter(\.isFavorite).count
    }

    var currentTimePeriod: TimePeriod? {
        guard let spot = selectedSpot else { return nil }
        let year = Int(sliderYear)
        return spot.timePeriods
            .sorted { abs($0.year - year) < abs($1.year - year) }
            .first
    }

    var currentEra: HistoricalEra? {
        currentTimePeriod?.era
    }

    var nearestYears: [Int] {
        guard let spot = selectedSpot else { return [] }
        return spot.timePeriods.map(\.year).sorted()
    }

    // MARK: - Spot Actions

    func selectSpot(_ spot: HistoricalSpot) {
        selectedSpot = spot
        if let oldest = spot.oldestYear, let newest = spot.newestYear {
            minYear = Double(oldest)
            maxYear = Double(newest)
            sliderYear = Double(newest)
        }
        showingSpotDetail = true
    }

    func deselectSpot() {
        selectedSpot = nil
        selectedTimePeriod = nil
        showingSpotDetail = false
        isARActive = false
        sceneMeshResult = nil
        facadeResult = nil
    }

    func toggleFavorite(_ spot: HistoricalSpot) {
        guard let index = spots.firstIndex(where: { $0.id == spot.id }) else { return }
        spots[index].isFavorite.toggle()
        if selectedSpot?.id == spot.id {
            selectedSpot = spots[index]
        }
    }

    // MARK: - AR Actions

    func startAR() async {
        isARActive = true
        isScanning = true

        _ = await locationManager.checkLocationAnchorSupport()

        if let spot = selectedSpot {
            _ = await locationManager.placeAnchor(for: spot)
            sceneMeshResult = await locationManager.captureSceneMesh(for: spot)
            facadeResult = await locationManager.detectLandmarkFacade()
        }

        isScanning = false
    }

    func stopAR() {
        isARActive = false
        sceneMeshResult = nil
        facadeResult = nil
    }

    // MARK: - Time Slider Actions

    func setYear(_ year: Double) {
        sliderYear = year
        selectedTimePeriod = currentTimePeriod
    }

    func snapToNearestPeriod() {
        guard let period = currentTimePeriod else { return }
        sliderYear = Double(period.year)
        selectedTimePeriod = period
    }

    func jumpToYear(_ year: Int) {
        sliderYear = Double(year)
        selectedTimePeriod = currentTimePeriod
    }

    // MARK: - Overlay Actions

    func setOverlayMode(_ mode: AROverlayMode) {
        overlayMode = mode
    }

    func setOverlayOpacity(_ opacity: Double) {
        overlayOpacity = opacity
    }

    // MARK: - Photo Actions

    func captureARPhoto() {
        capturedPhotoCount += 1
        showingPhotoCapture = true
    }

    func dismissPhotoCapture() {
        showingPhotoCapture = false
    }

    // MARK: - Data Refresh

    func refreshSpots() async {
        isLoading = true
        let fetched = await locationManager.fetchNearbySpots()
        spots = fetched
        isLoading = false
    }
}
