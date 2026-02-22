import SwiftUI

struct Participant: Identifiable, Sendable {
    let id: UUID
    let name: String
    let avatarColor: ParticipantColor
    var syncStatus: SyncStatus
    var isMuted: Bool
    var isHost: Bool

    enum SyncStatus: String, Sendable {
        case synced = "同期中"
        case buffering = "バッファリング"
        case disconnected = "切断"

        var color: Color {
            switch self {
            case .synced: return .green
            case .buffering: return .yellow
            case .disconnected: return .red
            }
        }

        var systemImage: String {
            switch self {
            case .synced: return "checkmark.circle.fill"
            case .buffering: return "arrow.triangle.2.circlepath"
            case .disconnected: return "xmark.circle.fill"
            }
        }
    }

    enum ParticipantColor: String, CaseIterable, Sendable {
        case blue, purple, orange, pink, mint

        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .orange: return .orange
            case .pink: return .pink
            case .mint: return .mint
            }
        }
    }

    static let samples: [Participant] = [
        Participant(
            id: UUID(), name: "あなた", avatarColor: .blue,
            syncStatus: .synced, isMuted: false, isHost: true
        ),
        Participant(
            id: UUID(), name: "ユウキ", avatarColor: .purple,
            syncStatus: .synced, isMuted: false, isHost: false
        ),
        Participant(
            id: UUID(), name: "サクラ", avatarColor: .pink,
            syncStatus: .buffering, isMuted: true, isHost: false
        ),
        Participant(
            id: UUID(), name: "レン", avatarColor: .orange,
            syncStatus: .synced, isMuted: false, isHost: false
        ),
    ]
}
