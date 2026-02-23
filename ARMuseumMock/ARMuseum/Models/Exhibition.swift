import Foundation
import SwiftUI

// MARK: - Exhibition

struct Exhibition: Identifiable, Sendable {
    let id: UUID
    var name: String
    var description: String
    var theme: ExhibitionTheme
    var artworkIDs: [UUID]
    var createdDate: Date
    var isPublished: Bool
    var invitedFriends: [Friend]

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        theme: ExhibitionTheme = .gallery,
        artworkIDs: [UUID] = [],
        createdDate: Date = Date(),
        isPublished: Bool = false,
        invitedFriends: [Friend] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.theme = theme
        self.artworkIDs = artworkIDs
        self.createdDate = createdDate
        self.isPublished = isPublished
        self.invitedFriends = invitedFriends
    }

    var artworkCount: Int { artworkIDs.count }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: createdDate)
    }
}

// MARK: - ExhibitionTheme

enum ExhibitionTheme: String, CaseIterable, Sendable {
    case gallery = "ギャラリー"
    case modern = "モダンアート"
    case traditional = "和風"
    case outdoor = "屋外展示"
    case dark = "ダークルーム"

    var backgroundColor: Color {
        switch self {
        case .gallery: Color(white: 0.95)
        case .modern: .white
        case .traditional: Color(red: 0.95, green: 0.92, blue: 0.85)
        case .outdoor: Color(red: 0.85, green: 0.93, blue: 0.85)
        case .dark: Color(white: 0.1)
        }
    }

    var wallColor: Color {
        switch self {
        case .gallery: .white
        case .modern: Color(white: 0.98)
        case .traditional: Color(red: 0.9, green: 0.85, blue: 0.75)
        case .outdoor: Color(red: 0.6, green: 0.7, blue: 0.6)
        case .dark: Color(white: 0.15)
        }
    }

    var systemImage: String {
        switch self {
        case .gallery: "building.columns"
        case .modern: "square.split.diagonal"
        case .traditional: "house.lodge"
        case .outdoor: "tree"
        case .dark: "moon.stars"
        }
    }

    var textColor: Color {
        switch self {
        case .dark: .white
        default: .primary
        }
    }
}

// MARK: - Friend

struct Friend: Identifiable, Sendable {
    let id: UUID
    let name: String
    let avatarColor: Color
    var isOnline: Bool

    init(id: UUID = UUID(), name: String, avatarColor: Color = .blue, isOnline: Bool = false) {
        self.id = id
        self.name = name
        self.avatarColor = avatarColor
        self.isOnline = isOnline
    }
}

// MARK: - Sample Data

extension Exhibition {
    static let samples: [Exhibition] = {
        let artworkIDs = Artwork.samples.map(\.id)
        return [
            Exhibition(
                name: "私の最初の展覧会",
                description: "初めての作品をまとめた個人展。絵画と陶芸を中心に展示。",
                theme: .gallery,
                artworkIDs: Array(artworkIDs.prefix(4)),
                createdDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                isPublished: true,
                invitedFriends: Friend.samples
            ),
            Exhibition(
                name: "デジタルアートの世界",
                description: "テクノロジーとアートの融合をテーマにした実験的展示。",
                theme: .dark,
                artworkIDs: artworkIDs.count > 5 ? [artworkIDs[5]] : [],
                createdDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                isPublished: false,
                invitedFriends: []
            ),
        ]
    }()
}

extension Friend {
    static let samples: [Friend] = [
        Friend(name: "山田さん", avatarColor: .green, isOnline: true),
        Friend(name: "鈴木さん", avatarColor: .purple, isOnline: false),
        Friend(name: "佐藤さん", avatarColor: .orange, isOnline: true),
    ]
}
