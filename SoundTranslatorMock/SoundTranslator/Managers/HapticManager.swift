import Foundation

// MARK: - HapticManager

/// 触覚フィードバック管理（モック）
/// 重要な音（サイレン、クラクション等）を振動パターンで通知
@MainActor
@Observable
final class HapticManager {

    static let shared = HapticManager()

    // MARK: - State

    var isEnabled = true
    var lastHapticEvent: String?

    // MARK: - Haptic Patterns

    func triggerHaptic(for alertLevel: AlertLevel) {
        guard isEnabled else { return }

        switch alertLevel {
        case .safe:
            // 通知なし
            break
        case .caution:
            lastHapticEvent = "軽い振動: 注意喚起"
        case .danger:
            lastHapticEvent = "強い連続振動: 危険通知"
        }
    }

    private init() {}
}
