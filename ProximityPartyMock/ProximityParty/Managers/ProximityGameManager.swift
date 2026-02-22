import Foundation

/// Nearby Interaction + MultipeerConnectivity を統合するゲームマネージャー（モック実装）
final class ProximityGameManager: @unchecked Sendable {
    static let shared = ProximityGameManager()

    private var simulationTimer: Timer?
    private(set) var isUWBSupported = true
    var onPlayersUpdated: (([Player]) -> Void)?
    var onTagEvent: ((Player, Player) -> Void)?

    private init() {}

    /// UWB デバイスサポートチェック
    func checkDeviceSupport() -> Bool {
        isUWBSupported
    }

    /// デモプレイヤーを生成
    func generateDemoPlayers(count: Int) -> [Player] {
        let names = ["ゆうた", "さくら", "けんじ", "みほ", "たくや", "あやか", "しょうた", "なつき"]
        let emojis = ["🐻", "🐱", "🐶", "🐰", "🦊", "🐼", "🐨", "🐸"]
        let colors = PlayerColor.allCases

        return (0..<min(count, names.count)).map { i in
            let angle = Float.random(in: 0...(2 * .pi))
            let distance = Float.random(in: 1.5...8.0)
            return Player(
                id: UUID(),
                name: names[i],
                avatarEmoji: emojis[i],
                color: colors[i % colors.count],
                distance: distance,
                direction: SIMD3<Float>(sin(angle), 0, -cos(angle)),
                isTagged: false
            )
        }
    }

    /// シミュレーション開始（0.5 秒ごとにプレイヤー位置を更新）
    func startSimulation(players: [Player], onUpdate: @escaping ([Player]) -> Void) {
        stopSimulation()
        var currentPlayers = players

        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            currentPlayers = currentPlayers.map { player in
                var updated = player
                // 距離をランダムに変動
                let distanceDelta = Float.random(in: -0.3...0.3)
                updated.distance = max(0.3, min(15.0, player.distance + distanceDelta))

                // 方向をわずかに変動
                let angleDelta = Float.random(in: -0.1...0.1)
                let currentAngle = atan2(player.direction.x, -player.direction.z)
                let newAngle = currentAngle + angleDelta
                updated.direction = SIMD3<Float>(sin(newAngle), 0, -cos(newAngle))

                return updated
            }
            onUpdate(currentPlayers)
        }
    }

    /// シミュレーション停止
    func stopSimulation() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    /// タグ判定（鬼ごっこ用）
    func checkTagDistance(tagger: Player, target: Player, threshold: Float) -> Bool {
        target.distance <= threshold
    }

    /// 宝探し距離ヒントを生成
    func treasureHint(distance: Float) -> TreasureHint {
        switch distance {
        case 0..<0.5:   return .burning
        case 0.5..<1.5: return .hot
        case 1.5..<3.0: return .warm
        case 3.0..<5.0: return .cool
        default:        return .cold
        }
    }

    /// クイズの正解距離を生成
    func generateQuizDistance() -> Float {
        Float.random(in: 1.0...10.0)
    }

    /// クイズスコアを計算（誤差が小さいほど高得点）
    func calculateQuizScore(guess: Float, actual: Float) -> Int {
        let error = abs(guess - actual)
        if error < 0.1 { return 100 }
        if error < 0.3 { return 80 }
        if error < 0.5 { return 60 }
        if error < 1.0 { return 40 }
        if error < 2.0 { return 20 }
        return 10
    }
}

/// 宝探しの距離ヒント
enum TreasureHint: String, Sendable {
    case burning = "激アツ!!"
    case hot = "アツい!"
    case warm = "あたたかい"
    case cool = "つめたい"
    case cold = "氷のように冷たい..."

    var icon: String {
        switch self {
        case .burning: return "flame.fill"
        case .hot: return "thermometer.sun.fill"
        case .warm: return "thermometer.medium"
        case .cool: return "thermometer.snowflake"
        case .cold: return "snowflake"
        }
    }

    var pulseSpeed: Double {
        switch self {
        case .burning: return 0.2
        case .hot: return 0.4
        case .warm: return 0.8
        case .cool: return 1.5
        case .cold: return 3.0
        }
    }
}
