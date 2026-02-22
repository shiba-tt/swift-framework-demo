import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Controls（iOS 18+ コントロールセンターウィジェット）

/// ControlDeck のコントロールセンター用ウィジェット。
/// コントロールセンター、ロック画面、Action ボタンに配置可能。

// MARK: - Light Toggle Control

struct LightToggleControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "light-toggle") {
            ControlToggle("リビング照明", isOn: LightStateProvider.isOn, action: ToggleLightIntent()) { isOn in
                Label(isOn ? "ON" : "OFF", systemImage: isOn ? "lightbulb.fill" : "lightbulb")
            }
            .tint(.yellow)
        }
        .displayName("リビング照明")
        .description("リビングの照明をON/OFFします")
    }
}

// MARK: - Lock Toggle Control

struct LockToggleControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "lock-toggle") {
            ControlToggle("玄関ロック", isOn: LockStateProvider.isLocked, action: ToggleLockIntent()) { isLocked in
                Label(isLocked ? "施錠" : "解錠", systemImage: isLocked ? "lock.fill" : "lock.open.fill")
            }
            .tint(.red)
        }
        .displayName("玄関ロック")
        .description("玄関のスマートロックを操作します")
    }
}

// MARK: - Scene Button Control

struct SceneButtonControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "scene-execute") {
            ControlButton(action: ExecuteSceneIntent()) {
                Label("帰宅シーン", systemImage: "house.fill")
            }
            .tint(.cyan)
        }
        .displayName("帰宅シーン")
        .description("帰宅シーンを実行します")
    }
}

// MARK: - All Off Button Control

struct AllOffButtonControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "all-off") {
            ControlButton(action: AllOffIntent()) {
                Label("全消灯", systemImage: "power")
            }
            .tint(.red)
        }
        .displayName("全消灯")
        .description("すべてのデバイスをOFFにします")
    }
}

// MARK: - State Providers

struct LightStateProvider {
    static var isOn: Bool {
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        return defaults?.bool(forKey: "control_light_on") ?? true
    }
}

struct LockStateProvider {
    static var isLocked: Bool {
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        return defaults?.bool(forKey: "control_lock_locked") ?? true
    }
}

// MARK: - AppIntents

struct ToggleLightIntent: SetValueIntent {
    static var title: LocalizedStringResource = "照明切り替え"

    @Parameter(title: "ON/OFF")
    var value: Bool

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        defaults?.set(value, forKey: "control_light_on")
        return .result()
    }
}

struct ToggleLockIntent: SetValueIntent {
    static var title: LocalizedStringResource = "ロック切り替え"

    @Parameter(title: "施錠/解錠")
    var value: Bool

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        defaults?.set(value, forKey: "control_lock_locked")
        return .result()
    }
}

struct ExecuteSceneIntent: AppIntent {
    static var title: LocalizedStringResource = "帰宅シーン実行"

    func perform() async throws -> some IntentResult {
        // App Group 経由でシーン実行をトリガー
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        defaults?.set("帰宅", forKey: "pendingScene")
        return .result()
    }
}

struct AllOffIntent: AppIntent {
    static var title: LocalizedStringResource = "全消灯"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.controldeck")
        defaults?.set(true, forKey: "allOff")
        return .result()
    }
}
