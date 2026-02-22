import Foundation

@MainActor
@Observable
final class SpaceCanvasManager {
    static let shared = SpaceCanvasManager()
    private init() {
        artists = Artist.samples
        artworkHistory = ArtworkInfo.samples
        generateDemoStrokes()
    }

    // MARK: - Session State

    private(set) var isSessionActive = false
    private(set) var isARActive = false
    private(set) var isDrawing = false
    private(set) var sessionDuration: TimeInterval = 0

    // MARK: - Canvas Data

    private(set) var strokes: [Stroke] = []
    private(set) var currentStroke: Stroke?

    // MARK: - Artists

    private(set) var artists: [Artist] = []

    // MARK: - History

    private(set) var artworkHistory: [ArtworkInfo] = []

    // MARK: - UWB

    private(set) var isUWBSupported = true

    // MARK: - Simulation

    private var drawingTimer: Timer?
    private var sessionTimer: Timer?
    private var peerSimulationTimer: Timer?

    // MARK: - Computed

    var totalStrokes: Int { strokes.count }

    var totalPoints: Int { strokes.reduce(0) { $0 + $1.pointCount } }

    var connectedArtists: Int { artists.filter(\.isConnected).count }

    var sessionDurationText: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var myArtist: Artist? { artists.first { $0.name == "あなた" } }

    // MARK: - Session Control

    func startSession() {
        isSessionActive = true
        isARActive = true
        sessionDuration = 0
        startSessionTimer()
        startPeerSimulation()
    }

    func endSession() {
        isSessionActive = false
        isARActive = false
        stopDrawing()
        stopSessionTimer()
        stopPeerSimulation()
    }

    // MARK: - Drawing

    func startDrawing(color: StrokeColor, thickness: Float) {
        guard isSessionActive else { return }
        isDrawing = true
        currentStroke = Stroke(
            artistName: "あなた", color: color, thickness: thickness
        )
        startDrawingSimulation(color: color, thickness: thickness)
    }

    func stopDrawing() {
        isDrawing = false
        if let stroke = currentStroke, !stroke.points.isEmpty {
            strokes.append(stroke)
            if let idx = artists.firstIndex(where: { $0.name == "あなた" }) {
                artists[idx].strokeCount += 1
            }
        }
        currentStroke = nil
        stopDrawingSimulation()
    }

    func clearCanvas() {
        strokes.removeAll()
        for idx in artists.indices {
            artists[idx].strokeCount = 0
        }
    }

    func undoLastStroke() {
        guard !strokes.isEmpty else { return }
        let removed = strokes.removeLast()
        if let idx = artists.firstIndex(where: { $0.name == removed.artistName }) {
            artists[idx].strokeCount = max(0, artists[idx].strokeCount - 1)
        }
    }

    func saveArtwork(title: String) {
        let artwork = ArtworkInfo(
            id: UUID(), title: title, artistCount: connectedArtists,
            totalStrokes: totalStrokes, totalPoints: totalPoints,
            createdAt: Date(), duration: sessionDuration
        )
        artworkHistory.insert(artwork, at: 0)
    }

    func deleteArtwork(_ artwork: ArtworkInfo) {
        artworkHistory.removeAll { $0.id == artwork.id }
    }

    // MARK: - Private Simulation

    private func startSessionTimer() {
        stopSessionTimer()
        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.sessionDuration += 1
            }
        }
    }

    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private func startDrawingSimulation(color: StrokeColor, thickness: Float) {
        stopDrawingSimulation()
        var angle: Float = 0
        var baseX: Float = Float.random(in: -0.3...0.3)
        var baseZ: Float = Float.random(in: -0.5...(-0.2))
        let baseY: Float = Float.random(in: 0.0...0.5)

        drawingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.08, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isDrawing else { return }
                angle += 0.15
                baseX += Float.random(in: -0.01...0.01)
                baseZ += Float.random(in: -0.01...0.01)

                let point = StrokePoint(
                    position: SIMD3(
                        baseX + sin(angle) * 0.05,
                        baseY + cos(angle * 0.7) * 0.03,
                        baseZ + sin(angle * 0.5) * 0.04
                    ),
                    color: color,
                    thickness: thickness
                )
                self.currentStroke?.points.append(point)
            }
        }
    }

    private func stopDrawingSimulation() {
        drawingTimer?.invalidate()
        drawingTimer = nil
    }

    private func startPeerSimulation() {
        stopPeerSimulation()
        peerSimulationTimer = Timer.scheduledTimer(
            withTimeInterval: 4.0, repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.simulatePeerActivity()
            }
        }
    }

    private func stopPeerSimulation() {
        peerSimulationTimer?.invalidate()
        peerSimulationTimer = nil
    }

    private func simulatePeerActivity() {
        for idx in artists.indices where artists[idx].name != "あなた" {
            artists[idx].distance = Float.random(in: 1.0...4.0)

            if Bool.random() && Bool.random() {
                let colors = StrokeColor.allCases
                let color = colors.randomElement() ?? .red
                var peerStroke = Stroke(
                    artistName: artists[idx].name,
                    color: color,
                    thickness: Float.random(in: 1.5...6.0)
                )
                let pointCount = Int.random(in: 10...30)
                var x = Float.random(in: -0.4...0.4)
                var y = Float.random(in: -0.2...0.5)
                var z = Float.random(in: -0.6...(-0.1))
                for _ in 0..<pointCount {
                    x += Float.random(in: -0.02...0.02)
                    y += Float.random(in: -0.01...0.01)
                    z += Float.random(in: -0.02...0.02)
                    peerStroke.points.append(
                        StrokePoint(position: SIMD3(x, y, z), color: color)
                    )
                }
                strokes.append(peerStroke)
                artists[idx].strokeCount += 1
            }
        }
    }

    private func generateDemoStrokes() {
        let colors: [StrokeColor] = [.cyan, .pink, .green, .blue, .purple]
        let names = ["あなた", "ハルカ", "ソウタ"]

        for i in 0..<5 {
            let name = names[i % names.count]
            let color = colors[i % colors.count]
            var stroke = Stroke(
                artistName: name, color: color,
                thickness: Float.random(in: 2.0...5.0)
            )
            let pointCount = Int.random(in: 15...40)
            var x = Float.random(in: -0.3...0.3)
            var y = Float.random(in: -0.1...0.4)
            var z = Float.random(in: -0.5...(-0.1))
            for _ in 0..<pointCount {
                x += Float.random(in: -0.015...0.015)
                y += Float.random(in: -0.01...0.01)
                z += Float.random(in: -0.015...0.015)
                stroke.points.append(
                    StrokePoint(position: SIMD3(x, y, z), color: color)
                )
            }
            strokes.append(stroke)
        }
    }
}
