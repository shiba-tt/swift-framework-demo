import Foundation

// MARK: - MuseumManager

@MainActor
@Observable
final class MuseumManager {

    static let shared = MuseumManager()

    // MARK: - State

    private(set) var artworks: [Artwork] = Artwork.samples
    private(set) var exhibitions: [Exhibition] = Exhibition.samples
    private(set) var room: MuseumRoom = MuseumRoom.sampleScanned
    private(set) var spotLights: [SpotLight] = []

    // MARK: - Artwork Management

    func addArtwork(_ artwork: Artwork) {
        artworks.append(artwork)
    }

    func removeArtwork(id: UUID) {
        artworks.removeAll { $0.id == id }
        for i in exhibitions.indices {
            exhibitions[i].artworkIDs.removeAll { $0 == id }
        }
    }

    func artwork(by id: UUID) -> Artwork? {
        artworks.first { $0.id == id }
    }

    // MARK: - Exhibition Management

    func addExhibition(_ exhibition: Exhibition) {
        exhibitions.append(exhibition)
    }

    func updateExhibition(_ exhibition: Exhibition) {
        guard let index = exhibitions.firstIndex(where: { $0.id == exhibition.id }) else { return }
        exhibitions[index] = exhibition
    }

    func removeExhibition(id: UUID) {
        exhibitions.removeAll { $0.id == id }
    }

    func togglePublish(exhibitionID: UUID) {
        guard let index = exhibitions.firstIndex(where: { $0.id == exhibitionID }) else { return }
        exhibitions[index].isPublished.toggle()
    }

    func artworks(for exhibition: Exhibition) -> [Artwork] {
        exhibition.artworkIDs.compactMap { artworkID in
            artworks.first { $0.id == artworkID }
        }
    }

    // MARK: - Room Management

    func startRoomScan() async {
        room = MuseumRoom(name: room.name, isScanned: false)

        try? await Task.sleep(for: .seconds(2))

        room = MuseumRoom.sampleScanned
    }

    // MARK: - Lighting

    func addSpotLight(for artworkID: UUID) {
        let light = SpotLight(targetArtworkID: artworkID)
        spotLights.append(light)
    }

    func updateSpotLight(_ light: SpotLight) {
        guard let index = spotLights.firstIndex(where: { $0.id == light.id }) else { return }
        spotLights[index] = light
    }

    func removeSpotLight(id: UUID) {
        spotLights.removeAll { $0.id == id }
    }

    func spotLight(for artworkID: UUID) -> SpotLight? {
        spotLights.first { $0.targetArtworkID == artworkID }
    }

    // MARK: - Statistics

    var totalArtworks: Int { artworks.count }
    var totalExhibitions: Int { exhibitions.count }
    var publishedExhibitions: Int { exhibitions.filter(\.isPublished).count }
}
