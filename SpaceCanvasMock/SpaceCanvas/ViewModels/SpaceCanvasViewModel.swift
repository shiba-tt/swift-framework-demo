import Foundation

@MainActor
@Observable
final class SpaceCanvasViewModel {
    let manager = SpaceCanvasManager.shared

    // MARK: - UI State

    var selectedTab: AppTab = .canvas
    var selectedColor: StrokeColor = .cyan
    var selectedThickness: BrushThickness = .medium
    var showColorPicker = false
    var showArtistList = false
    var showSaveDialog = false
    var saveTitle = ""
    var showSettings = false

    enum AppTab: String, CaseIterable, Sendable {
        case canvas = "キャンバス"
        case gallery = "ギャラリー"
        case artists = "アーティスト"

        var systemImageName: String {
            switch self {
            case .canvas: return "paintbrush.pointed.fill"
            case .gallery: return "photo.stack"
            case .artists: return "person.3.fill"
            }
        }
    }

    // MARK: - Computed Delegates

    var isSessionActive: Bool { manager.isSessionActive }
    var isARActive: Bool { manager.isARActive }
    var isDrawing: Bool { manager.isDrawing }
    var strokes: [Stroke] { manager.strokes }
    var currentStroke: Stroke? { manager.currentStroke }
    var artists: [Artist] { manager.artists }
    var artworkHistory: [ArtworkInfo] { manager.artworkHistory }
    var totalStrokes: Int { manager.totalStrokes }
    var totalPoints: Int { manager.totalPoints }
    var connectedArtists: Int { manager.connectedArtists }
    var sessionDurationText: String { manager.sessionDurationText }
    var sessionDuration: TimeInterval { manager.sessionDuration }

    var currentStrokePointCount: Int {
        currentStroke?.points.count ?? 0
    }

    // MARK: - Actions

    func startSession() {
        manager.startSession()
    }

    func endSession() {
        manager.endSession()
    }

    func toggleDrawing() {
        if isDrawing {
            manager.stopDrawing()
        } else {
            manager.startDrawing(
                color: selectedColor,
                thickness: selectedThickness.rawValue
            )
        }
    }

    func clearCanvas() {
        manager.clearCanvas()
    }

    func undoLastStroke() {
        manager.undoLastStroke()
    }

    func saveArtwork() {
        let title = saveTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        manager.saveArtwork(title: title)
        saveTitle = ""
        showSaveDialog = false
    }

    func deleteArtwork(_ artwork: ArtworkInfo) {
        manager.deleteArtwork(artwork)
    }
}
