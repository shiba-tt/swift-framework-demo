import Foundation
import SwiftUI

// MARK: - ShadowEngine

/// ARKit の Scene Reconstruction + Depth API を使用して影を計算するエンジン（モック）
/// 実際のアプリでは Metal カスタムシェーダーでリアルタイム影計算を行う
@MainActor
final class ShadowEngine: Sendable {

    static let shared = ShadowEngine()

    private init() {}

    // MARK: - Shadow Calculation (Mock)

    /// 光源位置と物体配置から影の一致度を計算（モック）
    func calculateMatchAccuracy(
        lightSource: LightSource,
        objects: [VirtualObject],
        targetShape: ShadowShape
    ) -> Double {
        guard !objects.isEmpty else { return 0 }

        // モック: 光源の位置、物体の数と配置に基づいてスコアを算出
        let lightFactor = calculateLightFactor(lightSource)
        let objectFactor = calculateObjectFactor(objects, targetShape: targetShape)
        let combinedScore = (lightFactor * 0.4 + objectFactor * 0.6)

        return min(max(combinedScore, 0), 1.0)
    }

    // MARK: - Room Mesh Analysis (Mock)

    /// Scene Reconstruction で取得した部屋メッシュの解析（モック）
    func analyzeRoomMesh() async -> RoomMeshInfo {
        // LiDAR スキャンのシミュレーション
        try? await Task.sleep(for: .seconds(1.5))

        return RoomMeshInfo(
            floorArea: Double.random(in: 8...25),
            wallCount: Int.random(in: 3...5),
            furnitureCount: Int.random(in: 2...8),
            projectionSurfaces: Int.random(in: 3...6),
            lightCondition: LightCondition.allCases.randomElement() ?? .moderate
        )
    }

    // MARK: - Private

    private func calculateLightFactor(_ light: LightSource) -> Double {
        // 光源が上方にあるほどスコアが高い（自然な影が作りやすい）
        let heightScore = 1.0 - light.position.y
        let intensityScore = light.intensity
        return (heightScore * 0.6 + intensityScore * 0.4)
    }

    private func calculateObjectFactor(_ objects: [VirtualObject], targetShape: ShadowShape) -> Double {
        let objectCount = Double(objects.count)
        let diversityBonus = Set(objects.map(\.shape)).count > 1 ? 0.15 : 0.0

        // 物体が多いほど複雑な影が作れる
        let countScore = min(objectCount / 4.0, 1.0)

        // スケールと回転のバリエーション
        let scaleVariety = objects.map(\.scale).reduce(0, +) / objectCount
        let rotationVariety = objects.map { abs($0.rotation) }.reduce(0, +) / (objectCount * .pi)

        return min((countScore * 0.4 + scaleVariety * 0.2 + rotationVariety * 0.2 + diversityBonus + 0.1), 1.0)
    }
}

// MARK: - RoomMeshInfo

struct RoomMeshInfo: Sendable {
    var floorArea: Double
    var wallCount: Int
    var furnitureCount: Int
    var projectionSurfaces: Int
    var lightCondition: LightCondition

    var description: String {
        "床面積: \(String(format: "%.1f", floorArea))㎡ / 壁: \(wallCount)面 / 家具: \(furnitureCount)個 / 投影面: \(projectionSurfaces)箇所"
    }
}

// MARK: - LightCondition

enum LightCondition: String, CaseIterable, Sendable {
    case bright = "明るい"
    case moderate = "適度"
    case dim = "薄暗い"
    case dark = "暗い"

    var suitability: String {
        switch self {
        case .bright: "影が薄くなりがち。光源を強めに"
        case .moderate: "影パズルに最適な環境です"
        case .dim: "影がくっきり出やすい良い環境"
        case .dark: "暗すぎる場合は照明をつけてください"
        }
    }

    var color: Color {
        switch self {
        case .bright: .yellow
        case .moderate: .green
        case .dim: .blue
        case .dark: .purple
        }
    }
}
