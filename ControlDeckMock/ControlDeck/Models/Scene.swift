import Foundation
import SwiftUI

// MARK: - Scene

struct HomeScene: Identifiable, Sendable {
    let id: UUID
    var name: String
    var icon: String
    var color: Color
    var actions: [SceneAction]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: Color = .blue,
        actions: [SceneAction] = [],
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.actions = actions
        self.isActive = isActive
    }

    var actionSummary: String {
        actions.map { $0.description }.joined(separator: "、")
    }
}

// MARK: - SceneAction

struct SceneAction: Identifiable, Sendable {
    let id: UUID
    let deviceName: String
    let action: String
    let description: String

    init(
        id: UUID = UUID(),
        deviceName: String,
        action: String,
        description: String
    ) {
        self.id = id
        self.deviceName = deviceName
        self.action = action
        self.description = description
    }
}

// MARK: - DeviceLog

struct DeviceLog: Identifiable, Sendable {
    let id: UUID
    let deviceName: String
    let deviceEmoji: String
    let action: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        deviceName: String,
        deviceEmoji: String,
        action: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.deviceName = deviceName
        self.deviceEmoji = deviceEmoji
        self.action = action
        self.timestamp = timestamp
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}
