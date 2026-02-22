import Foundation

// MARK: - CameraManager

@MainActor
@Observable
final class CameraManager {

    static let shared = CameraManager()

    private(set) var isSessionRunning = false
    private(set) var currentFPS: Double = 30.0
    private(set) var processingLoad: Double = 0.0
    private(set) var mockFrameCount: Int = 0

    private var frameTimer: Timer?

    private init() {}

    func startSession() {
        isSessionRunning = true
        mockFrameCount = 0

        frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.mockFrameCount += 1
                self.currentFPS = Double.random(in: 28.0...30.0)
                self.processingLoad = Double.random(in: 0.3...0.7)
            }
        }
    }

    func stopSession() {
        isSessionRunning = false
        frameTimer?.invalidate()
        frameTimer = nil
    }

    func capturePhoto(filter: CineFilter) -> CapturedMedia {
        CapturedMedia(
            mode: .photo,
            filter: filter,
            compositionScore: Double.random(in: 0.4...1.0)
        )
    }

    func startRecording() {
        // Mock: 録画開始
    }

    func stopRecording(filter: CineFilter, duration: TimeInterval) -> CapturedMedia {
        CapturedMedia(
            mode: .video,
            filter: filter,
            duration: duration,
            compositionScore: Double.random(in: 0.4...1.0)
        )
    }
}
