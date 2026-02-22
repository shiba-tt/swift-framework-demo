import Foundation
import SwiftUI

// MARK: - VoteOption

struct VoteOption: Identifiable, Sendable {
    let id: UUID
    let label: String
    let subtitle: String?
    var voteCount: Int
    let color: Color

    init(
        id: UUID = UUID(),
        label: String,
        subtitle: String? = nil,
        voteCount: Int = 0,
        color: Color = .blue
    ) {
        self.id = id
        self.label = label
        self.subtitle = subtitle
        self.voteCount = voteCount
        self.color = color
    }

    func votePercentage(totalVotes: Int) -> Double {
        guard totalVotes > 0 else { return 0 }
        return Double(voteCount) / Double(totalVotes) * 100
    }
}

// MARK: - LightShowColor

enum LightShowColor: String, Sendable, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case white

    var displayName: String {
        switch self {
        case .red: "レッド"
        case .blue: "ブルー"
        case .green: "グリーン"
        case .yellow: "イエロー"
        case .purple: "パープル"
        case .white: "ホワイト"
        }
    }

    var color: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .green: .green
        case .yellow: .yellow
        case .purple: .purple
        case .white: .white
        }
    }
}

// MARK: - SeatInfo

struct SeatInfo: Sendable {
    let section: String
    let row: String
    let seat: String
    let nfcTagID: String

    var displayName: String {
        "\(section) \(row)列 \(seat)番"
    }
}
