import SwiftUI
import WidgetKit
import AlarmKit
import ActivityKit

/// SleepCraft の Live Activity 定義
struct SleepCraftLiveActivity: Widget {
    var body: some WidgetConfiguration {
        AlarmLiveActivityConfiguration(SleepCraftAlarmMetadata.self)
    }
}
