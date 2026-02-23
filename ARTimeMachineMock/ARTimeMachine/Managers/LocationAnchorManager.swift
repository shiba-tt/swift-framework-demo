import Foundation
import SwiftUI

// MARK: - LocationAnchorManager

/// ARKit の Location Anchors + Image Detection を使用して
/// 地理座標に歴史データをアンカリングするマネージャー（モック）
@MainActor
@Observable
final class LocationAnchorManager {

    static let shared = LocationAnchorManager()

    private init() {}

    // MARK: - State

    var isLocationAvailable = false
    var currentCity: String = "東京"
    var anchoredSpots: [UUID] = []
    var scanQuality: ScanQuality = .good

    // MARK: - Location Anchor (Mock)

    /// Location Anchors 対応都市かチェック（モック）
    func checkLocationAnchorSupport() async -> Bool {
        try? await Task.sleep(for: .seconds(0.5))
        isLocationAvailable = true
        return true
    }

    /// 現在地周辺の歴史スポットを検索（モック）
    func fetchNearbySpots() async -> [HistoricalSpot] {
        try? await Task.sleep(for: .seconds(1.0))
        return HistoricalSpot.samples
    }

    /// 特定スポットに Location Anchor を設置（モック）
    func placeAnchor(for spot: HistoricalSpot) async -> Bool {
        try? await Task.sleep(for: .seconds(0.8))
        anchoredSpots.append(spot.id)
        return true
    }

    /// Scene Reconstruction でスポットの現在メッシュを取得（モック）
    func captureSceneMesh(for spot: HistoricalSpot) async -> SceneMeshResult {
        try? await Task.sleep(for: .seconds(1.5))
        return SceneMeshResult(
            vertexCount: Int.random(in: 10000...50000),
            faceCount: Int.random(in: 5000...25000),
            boundingBoxSize: CGSize(
                width: Double.random(in: 10...50),
                height: Double.random(in: 5...30)
            ),
            quality: scanQuality
        )
    }

    /// 画像検出でランドマークのファサードを特定（モック）
    func detectLandmarkFacade() async -> FacadeDetectionResult? {
        try? await Task.sleep(for: .seconds(1.2))
        return FacadeDetectionResult(
            confidence: Double.random(in: 0.7...0.98),
            detectedFeatures: Int.random(in: 20...100),
            matchedLandmark: "東京駅丸の内駅舎"
        )
    }
}

// MARK: - ScanQuality

enum ScanQuality: String, CaseIterable, Sendable {
    case excellent = "優秀"
    case good = "良好"
    case fair = "普通"
    case poor = "不良"

    var color: Color {
        switch self {
        case .excellent: .green
        case .good: .blue
        case .fair: .orange
        case .poor: .red
        }
    }

    var systemImage: String {
        switch self {
        case .excellent: "checkmark.circle.fill"
        case .good: "checkmark.circle"
        case .fair: "exclamationmark.circle"
        case .poor: "xmark.circle"
        }
    }
}

// MARK: - SceneMeshResult

struct SceneMeshResult: Sendable {
    var vertexCount: Int
    var faceCount: Int
    var boundingBoxSize: CGSize
    var quality: ScanQuality

    var summary: String {
        "頂点: \(vertexCount.formatted()) / 面: \(faceCount.formatted()) / 品質: \(quality.rawValue)"
    }
}

// MARK: - FacadeDetectionResult

struct FacadeDetectionResult: Sendable {
    var confidence: Double
    var detectedFeatures: Int
    var matchedLandmark: String

    var confidenceText: String {
        "\(Int(confidence * 100))%"
    }
}
