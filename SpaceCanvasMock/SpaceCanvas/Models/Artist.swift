import SwiftUI

struct Artist: Identifiable, Sendable {
    let id: UUID
    let name: String
    let assignedColor: StrokeColor
    var distance: Float?
    var direction: SIMD3<Float>?
    var isConnected: Bool
    var strokeCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        assignedColor: StrokeColor,
        distance: Float? = nil,
        direction: SIMD3<Float>? = nil,
        isConnected: Bool = true,
        strokeCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.assignedColor = assignedColor
        self.distance = distance
        self.direction = direction
        self.isConnected = isConnected
        self.strokeCount = strokeCount
    }

    var distanceText: String {
        guard let d = distance else { return "---" }
        if d < 1 {
            return String(format: "%.0f cm", d * 100)
        }
        return String(format: "%.1f m", d)
    }

    var statusText: String {
        isConnected ? "接続中" : "切断"
    }

    var statusColor: Color {
        isConnected ? .green : .red
    }

    static let samples: [Artist] = [
        Artist(name: "あなた", assignedColor: .cyan, distance: nil,
               isConnected: true, strokeCount: 12),
        Artist(name: "ハルカ", assignedColor: .pink, distance: 1.8,
               direction: SIMD3(0.6, 0.1, -0.8), isConnected: true, strokeCount: 8),
        Artist(name: "ソウタ", assignedColor: .green, distance: 2.5,
               direction: SIMD3(-0.4, -0.1, -0.9), isConnected: true, strokeCount: 5),
    ]
}

struct ArtworkInfo: Identifiable, Sendable {
    let id: UUID
    let title: String
    let artistCount: Int
    let totalStrokes: Int
    let totalPoints: Int
    let createdAt: Date
    let duration: TimeInterval

    var durationText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    static let samples: [ArtworkInfo] = [
        ArtworkInfo(
            id: UUID(), title: "星空の龍", artistCount: 3,
            totalStrokes: 25, totalPoints: 1250,
            createdAt: Date().addingTimeInterval(-3600), duration: 720
        ),
        ArtworkInfo(
            id: UUID(), title: "虹の花", artistCount: 2,
            totalStrokes: 18, totalPoints: 890,
            createdAt: Date().addingTimeInterval(-86400), duration: 480
        ),
        ArtworkInfo(
            id: UUID(), title: "未来都市", artistCount: 4,
            totalStrokes: 42, totalPoints: 2100,
            createdAt: Date().addingTimeInterval(-172800), duration: 1200
        ),
        ArtworkInfo(
            id: UUID(), title: "海の生き物", artistCount: 2,
            totalStrokes: 15, totalPoints: 750,
            createdAt: Date().addingTimeInterval(-259200), duration: 360
        ),
    ]
}
