import Foundation
import SwiftUI

// MARK: - ARMuseumViewModel

@MainActor
@Observable
final class ARMuseumViewModel {

    // MARK: - State

    var selectedExhibition: Exhibition?
    var selectedArtwork: Artwork?
    var isARActive = false
    var isScanning = false
    var showingArtworkDetail = false
    var showingAddArtwork = false
    var showingObjectCapture = false
    var showingExhibitionEditor = false
    var showingLightEditor = false
    var showingInvite = false
    var currentFrameStyle: FrameStyle = .classic

    // 新規作品追加フォーム
    var newArtworkTitle = ""
    var newArtworkArtist = ""
    var newArtworkDescription = ""
    var newArtworkCategory: ArtworkCategory = .other
    var newArtworkDisplayType: DisplayType = .wallFrame

    // MARK: - Dependencies

    private let museumManager = MuseumManager.shared
    let objectCaptureManager = ObjectCaptureManager.shared

    // MARK: - Computed

    var artworks: [Artwork] { museumManager.artworks }
    var exhibitions: [Exhibition] { museumManager.exhibitions }
    var room: MuseumRoom { museumManager.room }
    var totalArtworks: Int { museumManager.totalArtworks }
    var totalExhibitions: Int { museumManager.totalExhibitions }

    func artworks(for exhibition: Exhibition) -> [Artwork] {
        museumManager.artworks(for: exhibition)
    }

    func spotLight(for artworkID: UUID) -> SpotLight? {
        museumManager.spotLight(for: artworkID)
    }

    // MARK: - Exhibition Actions

    func selectExhibition(_ exhibition: Exhibition) {
        selectedExhibition = exhibition
    }

    func createExhibition(name: String, description: String, theme: ExhibitionTheme) {
        let exhibition = Exhibition(
            name: name,
            description: description,
            theme: theme,
            artworkIDs: [],
            createdDate: Date()
        )
        museumManager.addExhibition(exhibition)
        selectedExhibition = exhibition
    }

    func addArtworkToExhibition(_ artworkID: UUID) {
        guard var exhibition = selectedExhibition else { return }
        guard !exhibition.artworkIDs.contains(artworkID) else { return }
        exhibition.artworkIDs.append(artworkID)
        museumManager.updateExhibition(exhibition)
        selectedExhibition = exhibition
    }

    func removeArtworkFromExhibition(_ artworkID: UUID) {
        guard var exhibition = selectedExhibition else { return }
        exhibition.artworkIDs.removeAll { $0 == artworkID }
        museumManager.updateExhibition(exhibition)
        selectedExhibition = exhibition
    }

    func togglePublish() {
        guard let exhibition = selectedExhibition else { return }
        museumManager.togglePublish(exhibitionID: exhibition.id)
        selectedExhibition = museumManager.exhibitions.first { $0.id == exhibition.id }
    }

    func deleteExhibition(_ exhibition: Exhibition) {
        museumManager.removeExhibition(id: exhibition.id)
        if selectedExhibition?.id == exhibition.id {
            selectedExhibition = nil
        }
    }

    // MARK: - Artwork Actions

    func selectArtwork(_ artwork: Artwork) {
        selectedArtwork = artwork
        showingArtworkDetail = true
    }

    func addArtwork() {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .brown]
        let artwork = Artwork(
            title: newArtworkTitle,
            artist: newArtworkArtist,
            description: newArtworkDescription,
            category: newArtworkCategory,
            displayType: newArtworkDisplayType,
            modelFileName: objectCaptureManager.capturedModel?.fileName,
            thumbnailColor: colors.randomElement() ?? .blue
        )
        museumManager.addArtwork(artwork)
        resetNewArtworkForm()
        showingAddArtwork = false
    }

    func deleteArtwork(_ artwork: Artwork) {
        museumManager.removeArtwork(id: artwork.id)
        if selectedArtwork?.id == artwork.id {
            selectedArtwork = nil
            showingArtworkDetail = false
        }
    }

    // MARK: - Room Actions

    func startRoomScan() async {
        isScanning = true
        await museumManager.startRoomScan()
        isScanning = false
    }

    // MARK: - AR Actions

    func enterAR(for exhibition: Exhibition) {
        selectedExhibition = exhibition
        isARActive = true
    }

    func exitAR() {
        isARActive = false
    }

    // MARK: - Lighting

    func addSpotLight(for artworkID: UUID) {
        museumManager.addSpotLight(for: artworkID)
    }

    // MARK: - Object Capture

    func startObjectCapture() async {
        showingObjectCapture = true
        await objectCaptureManager.simulateQuickCapture()
    }

    // MARK: - Private

    private func resetNewArtworkForm() {
        newArtworkTitle = ""
        newArtworkArtist = ""
        newArtworkDescription = ""
        newArtworkCategory = .other
        newArtworkDisplayType = .wallFrame
        objectCaptureManager.reset()
    }
}
