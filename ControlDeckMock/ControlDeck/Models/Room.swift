import Foundation
import SwiftUI

// MARK: - Room

struct Room: Identifiable, Sendable {
    let id: UUID
    var name: String
    var icon: String
    var color: Color
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: Color = .blue,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.sortOrder = sortOrder
    }
}
