import Foundation
import NearbyInteraction
import MultipeerConnectivity

/// Nearby Interaction を使ったデバイス間の距離・方向検出管理
/// （モック：UWB ハードウェアが無い環境ではシミュレーションで代替）
@MainActor
@Observable
final class NearbyInteractionManager {
    static let shared = NearbyInteractionManager()

    // MARK: - State

    /// セッションが有効か
    private(set) var isSessionActive = false

    /// 検出されたピアデバイス
    private(set) var nearbyPeers: [PeerDevice] = []

    /// 最も近いピア
    var closestPeer: PeerDevice? {
        nearbyPeers.min(by: { $0.distance < $1.distance })
    }

    /// 共有準備完了のピア
    var readyPeer: PeerDevice? {
        nearbyPeers.first(where: { $0.phase == .readyToShare })
    }

    /// UWB がサポートされているか
    private(set) var isUWBSupported = true

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// 共有進捗（0.0〜1.0）
    private(set) var shareProgress: Double = 0.0

    /// 共有中フラグ
    private(set) var isSharing = false

    private var simulationTimer: Timer?

    private init() {}

    // MARK: - Session Management

    /// NISession を開始
    func startSession() {
        guard NISession.isSupported else {
            // シミュレーションモードに切り替え
            isUWBSupported = false
            startSimulation()
            return
        }

        isSessionActive = true
        startSimulation()
    }

    /// NISession を停止
    func stopSession() {
        isSessionActive = false
        simulationTimer?.invalidate()
        simulationTimer = nil
        nearbyPeers = []
    }

    /// 共有を実行
    func performShare(content: ShareableContent, to peer: PeerDevice) async -> Bool {
        isSharing = true
        shareProgress = 0.0

        // 共有進捗のシミュレーション
        for step in 1...10 {
            try? await Task.sleep(for: .milliseconds(150))
            shareProgress = Double(step) / 10.0
        }

        isSharing = false
        shareProgress = 0.0

        // 90%の確率で成功
        return Double.random(in: 0...1) < 0.9
    }

    // MARK: - MultipeerConnectivity

    /// MultipeerConnectivity によるピアのトークン交換（モック）
    func exchangeDiscoveryTokens() {
        // 実際のアプリでは MCSession を通じて NIDiscoveryToken を交換
        // モックではシミュレーションで代替
    }

    // MARK: - Simulation

    private func startSimulation() {
        isSessionActive = true

        // デモ用のピアデバイスをランダムに生成・更新
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSimulatedPeers()
            }
        }

        // 初期ピアを生成
        nearbyPeers = generateDemoPeers()
    }

    private func updateSimulatedPeers() {
        nearbyPeers = nearbyPeers.map { peer in
            // 距離をランダムに変動
            let newDistance = max(0.1, peer.distance + Float.random(in: -0.3...0.3))
            // 方向もわずかに変動
            let newDirection = SIMD3<Float>(
                peer.direction.x + Float.random(in: -0.1...0.1),
                peer.direction.y + Float.random(in: -0.05...0.05),
                peer.direction.z + Float.random(in: -0.1...0.1)
            )
            let isFacing = newDirection.z < -0.7

            return PeerDevice(
                name: peer.name,
                distance: newDistance,
                direction: newDirection,
                isFacing: isFacing,
                signalStrength: Double(max(0, 1.0 - newDistance / 10.0))
            )
        }

        // たまに新しいピアが出現/消失
        if Bool.random() && nearbyPeers.count < 4 {
            let names = ["iPhone (Taro)", "iPhone (Hanako)", "iPhone (Yuki)", "iPhone (Ken)"]
            let usedNames = Set(nearbyPeers.map(\.name))
            if let newName = names.first(where: { !usedNames.contains($0) }) {
                nearbyPeers.append(PeerDevice(
                    name: newName,
                    distance: Float.random(in: 2.0...5.0),
                    direction: SIMD3<Float>(Float.random(in: -1...1), 0, Float.random(in: -1...0)),
                    isFacing: false,
                    signalStrength: 0.3
                ))
            }
        }
    }

    private func generateDemoPeers() -> [PeerDevice] {
        [
            PeerDevice(
                name: "iPhone (Taro)",
                distance: 2.5,
                direction: SIMD3<Float>(0.3, 0.1, -0.8),
                isFacing: true,
                signalStrength: 0.6
            ),
            PeerDevice(
                name: "iPhone (Hanako)",
                distance: 4.2,
                direction: SIMD3<Float>(-0.5, 0.0, -0.4),
                isFacing: false,
                signalStrength: 0.3
            ),
        ]
    }
}
