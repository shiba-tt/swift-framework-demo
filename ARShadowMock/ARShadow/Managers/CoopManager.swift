import Foundation

// MARK: - CoopManager

/// MultipeerConnectivity を使用した協力プレイ管理（モック）
@MainActor
@Observable
final class CoopManager {

    static let shared = CoopManager()

    // MARK: - State

    var isHosting = false
    var isConnected = false
    var connectedPlayers: [CoopPlayer] = []
    var sessionCode: String = ""

    // MARK: - Actions

    func hostSession() async {
        isHosting = true
        sessionCode = generateSessionCode()

        // 接続シミュレーション
        try? await Task.sleep(for: .seconds(2))

        connectedPlayers = [
            CoopPlayer(name: "プレイヤー1", role: .lightController, isReady: true),
        ]
        isConnected = true
    }

    func joinSession(code: String) async -> Bool {
        sessionCode = code

        // 接続シミュレーション
        try? await Task.sleep(for: .seconds(1.5))

        isConnected = true
        connectedPlayers = [
            CoopPlayer(name: "ホスト", role: .objectPlacer, isReady: true),
        ]
        return true
    }

    func disconnect() {
        isHosting = false
        isConnected = false
        connectedPlayers = []
        sessionCode = ""
    }

    // MARK: - Private

    private func generateSessionCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    private init() {}
}

// MARK: - CoopPlayer

struct CoopPlayer: Identifiable, Sendable {
    let id = UUID()
    var name: String
    var role: PlayerRole
    var isReady: Bool
}

// MARK: - PlayerRole

enum PlayerRole: String, CaseIterable, Sendable {
    case lightController = "光源担当"
    case objectPlacer = "物体配置担当"

    var systemImage: String {
        switch self {
        case .lightController: "sun.max.fill"
        case .objectPlacer: "cube.fill"
        }
    }
}
