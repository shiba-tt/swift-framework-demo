import SwiftUI
import WidgetKit

@main
struct LiveBoardWidgetsBundle: WidgetBundle {
    var body: some Widget {
        LiveBoardWidget()
        LiveBoardLiveActivity()
    }
}
