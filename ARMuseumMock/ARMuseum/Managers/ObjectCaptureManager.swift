import Foundation
import SwiftUI

// MARK: - ObjectCaptureManager

@MainActor
@Observable
final class ObjectCaptureManager {

    static let shared = ObjectCaptureManager()

    // MARK: - State

    var captureState: CaptureState = .idle
    var capturedPhotoCount = 0
    var requiredPhotoCount = 60
    var processingProgress: Double = 0
    var capturedModel: CapturedModel?

    // MARK: - Actions

    func startCapture() {
        captureState = .capturing
        capturedPhotoCount = 0
    }

    func capturePhoto() async {
        guard captureState == .capturing else { return }
        capturedPhotoCount += 1
        try? await Task.sleep(for: .milliseconds(200))

        if capturedPhotoCount >= requiredPhotoCount {
            await processCapture()
        }
    }

    func simulateQuickCapture() async {
        captureState = .capturing
        capturedPhotoCount = 0

        for i in 1...requiredPhotoCount {
            capturedPhotoCount = i
            try? await Task.sleep(for: .milliseconds(30))
        }

        await processCapture()
    }

    func processCapture() async {
        captureState = .processing
        processingProgress = 0

        for i in 1...20 {
            try? await Task.sleep(for: .milliseconds(100))
            processingProgress = Double(i) / 20.0
        }

        capturedModel = CapturedModel(
            id: UUID(),
            fileName: "object_\(UUID().uuidString.prefix(8)).usdz",
            quality: .medium,
            vertexCount: Int.random(in: 15000...80000),
            fileSize: Int.random(in: 2_000_000...15_000_000),
            createdDate: Date()
        )

        captureState = .completed
    }

    func reset() {
        captureState = .idle
        capturedPhotoCount = 0
        processingProgress = 0
        capturedModel = nil
    }
}

// MARK: - CaptureState

enum CaptureState: String, Sendable {
    case idle = "待機中"
    case capturing = "撮影中"
    case processing = "処理中"
    case completed = "完了"
    case failed = "失敗"
}

// MARK: - CapturedModel

struct CapturedModel: Identifiable, Sendable {
    let id: UUID
    let fileName: String
    let quality: ModelQuality
    let vertexCount: Int
    let fileSize: Int
    let createdDate: Date

    var formattedFileSize: String {
        let mb = Double(fileSize) / 1_000_000.0
        return String(format: "%.1f MB", mb)
    }

    var formattedVertexCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: vertexCount)) ?? "\(vertexCount)"
    }
}

// MARK: - ModelQuality

enum ModelQuality: String, CaseIterable, Sendable {
    case preview = "プレビュー"
    case reduced = "軽量"
    case medium = "標準"
    case full = "高品質"
    case raw = "最高品質"

    var description: String {
        switch self {
        case .preview: "素早い確認用"
        case .reduced: "Web・共有向け"
        case .medium: "AR展示に最適"
        case .full: "高精細な展示用"
        case .raw: "最大限の品質"
        }
    }
}
