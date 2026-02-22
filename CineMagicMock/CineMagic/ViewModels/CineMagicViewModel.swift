import Foundation

// MARK: - CineMagicViewModel

@MainActor
@Observable
final class CineMagicViewModel {

    // MARK: - Types

    enum AppTab: Hashable, Sendable {
        case camera
        case gallery
    }

    // MARK: - State

    var selectedTab: AppTab = .camera
    var selectedFilter: CineFilter = .nolan
    var captureMode: CaptureMode = .photo
    var isRecording = false
    var recordingDuration: TimeInterval = 0
    var showFilterDetail = false
    var showCompositionGuide = false
    var currentAdvice: CompositionAdvice = .ruleOfThirds
    var capturedMedia: [CapturedMedia] = []
    var showCaptureResult = false
    var latestCapture: CapturedMedia?
    var customBrightness: Double = 0.0
    var customContrast: Double = 1.0
    var customSaturation: Double = 1.0
    var showCustomParameters = false

    // MARK: - Dependencies

    private let cameraManager = CameraManager.shared
    private var recordingTimer: Timer?
    private var adviceTimer: Timer?

    // MARK: - Computed

    var isSessionRunning: Bool {
        cameraManager.isSessionRunning
    }

    var currentFPS: Double {
        cameraManager.currentFPS
    }

    var processingLoad: Double {
        cameraManager.processingLoad
    }

    var formattedRecordingDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        let tenths = Int((recordingDuration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }

    var photoCount: Int {
        capturedMedia.filter { $0.mode == .photo }.count
    }

    var videoCount: Int {
        capturedMedia.filter { $0.mode == .video }.count
    }

    var averageScore: Double {
        guard !capturedMedia.isEmpty else { return 0.0 }
        return capturedMedia.map(\.compositionScore).reduce(0, +) / Double(capturedMedia.count)
    }

    // MARK: - Actions

    func startCamera() {
        cameraManager.startSession()
        startAdviceRotation()
    }

    func stopCamera() {
        cameraManager.stopSession()
        adviceTimer?.invalidate()
        adviceTimer = nil
    }

    func selectFilter(_ filter: CineFilter) {
        selectedFilter = filter
        applyFilterDefaults()
    }

    func capturePhoto() {
        let media = cameraManager.capturePhoto(filter: selectedFilter)
        capturedMedia.insert(media, at: 0)
        latestCapture = media
        showCaptureResult = true
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func deleteMedia(_ media: CapturedMedia) {
        capturedMedia.removeAll { $0.id == media.id }
    }

    // MARK: - Private

    private func startRecording() {
        isRecording = true
        recordingDuration = 0
        cameraManager.startRecording()

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 0.1
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil

        let media = cameraManager.stopRecording(
            filter: selectedFilter,
            duration: recordingDuration
        )
        capturedMedia.insert(media, at: 0)
        latestCapture = media
        showCaptureResult = true
    }

    private func applyFilterDefaults() {
        let params = selectedFilter.parameters
        customBrightness = params.brightness
        customContrast = params.contrast
        customSaturation = params.saturation
    }

    private func startAdviceRotation() {
        adviceTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let allAdvices = CompositionAdvice.allCases
                if let currentIndex = allAdvices.firstIndex(of: self.currentAdvice) {
                    let nextIndex = (currentIndex + 1) % allAdvices.count
                    self.currentAdvice = allAdvices[nextIndex]
                }
            }
        }
    }
}
