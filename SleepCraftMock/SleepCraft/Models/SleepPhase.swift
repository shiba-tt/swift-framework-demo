import Foundation

/// 睡眠ステージを表す列挙型
enum SleepPhase: String, Codable, Sendable, CaseIterable, Identifiable {
    /// 覚醒
    case awake
    /// レム睡眠（浅い）
    case rem
    /// コア睡眠（中程度）
    case core
    /// 深い睡眠
    case deep

    var id: String { rawValue }

    /// 表示名
    var label: String {
        switch self {
        case .awake: "覚醒"
        case .rem: "レム睡眠"
        case .core: "コア睡眠"
        case .deep: "深い睡眠"
        }
    }

    /// システムアイコン名
    var systemImageName: String {
        switch self {
        case .awake: "eye.fill"
        case .rem: "moon.haze.fill"
        case .core: "moon.fill"
        case .deep: "moon.zzz.fill"
        }
    }

    /// 睡眠の深さスコア（0 = 浅い, 3 = 深い）
    var depthScore: Int {
        switch self {
        case .awake: 0
        case .rem: 1
        case .core: 2
        case .deep: 3
        }
    }

    /// スマートアラームに適しているか（浅い睡眠で起こす）
    var isSuitableForWakeUp: Bool {
        switch self {
        case .awake, .rem: true
        case .core, .deep: false
        }
    }

    /// テーマカラー名
    var colorName: String {
        switch self {
        case .awake: "yellow"
        case .rem: "cyan"
        case .core: "blue"
        case .deep: "indigo"
        }
    }
}
