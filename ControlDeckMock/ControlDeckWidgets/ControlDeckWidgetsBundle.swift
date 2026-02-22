import WidgetKit
import SwiftUI

// MARK: - ControlDeck Widget Bundle

@main
struct ControlDeckWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ControlDeckWidget()
        LightToggleControl()
        LockToggleControl()
        SceneButtonControl()
        AllOffButtonControl()
    }
}
