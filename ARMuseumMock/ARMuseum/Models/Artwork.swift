import Foundation
import SwiftUI

// MARK: - Artwork

struct Artwork: Identifiable, Sendable {
    let id: UUID
    var title: String
    var artist: String
    var createdDate: Date
    var description: String
    var category: ArtworkCategory
    var displayType: DisplayType
    var modelFileName: String?
    var thumbnailColor: Color
    var scaleMultiplier: Double

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        createdDate: Date = Date(),
        description: String = "",
        category: ArtworkCategory = .other,
        displayType: DisplayType = .wallFrame,
        modelFileName: String? = nil,
        thumbnailColor: Color = .blue,
        scaleMultiplier: Double = 1.0
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.createdDate = createdDate
        self.description = description
        self.category = category
        self.displayType = displayType
        self.modelFileName = modelFileName
        self.thumbnailColor = thumbnailColor
        self.scaleMultiplier = scaleMultiplier
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: createdDate)
    }
}

// MARK: - ArtworkCategory

enum ArtworkCategory: String, CaseIterable, Sendable {
    case painting = "絵画"
    case sculpture = "彫刻"
    case ceramics = "陶芸"
    case craft = "工芸"
    case photography = "写真"
    case digital = "デジタル"
    case other = "その他"

    var systemImage: String {
        switch self {
        case .painting: "paintbrush.fill"
        case .sculpture: "cube.fill"
        case .ceramics: "mug.fill"
        case .craft: "scissors"
        case .photography: "camera.fill"
        case .digital: "desktopcomputer"
        case .other: "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .painting: .purple
        case .sculpture: .brown
        case .ceramics: .orange
        case .craft: .green
        case .photography: .gray
        case .digital: .cyan
        case .other: .secondary
        }
    }
}

// MARK: - DisplayType

enum DisplayType: String, CaseIterable, Sendable {
    case wallFrame = "壁掛け額縁"
    case pedestal = "台座"
    case floating = "浮遊展示"
    case showcase = "ショーケース"

    var systemImage: String {
        switch self {
        case .wallFrame: "photo.artframe"
        case .pedestal: "square.3.layers.3d.top.filled"
        case .floating: "sparkles"
        case .showcase: "cube.transparent"
        }
    }
}

// MARK: - FrameStyle

enum FrameStyle: String, CaseIterable, Sendable {
    case classic = "クラシック"
    case modern = "モダン"
    case minimal = "ミニマル"
    case ornate = "装飾"
    case none = "なし"

    var borderWidth: CGFloat {
        switch self {
        case .classic: 8
        case .modern: 4
        case .minimal: 2
        case .ornate: 12
        case .none: 0
        }
    }

    var borderColor: Color {
        switch self {
        case .classic: Color(red: 0.6, green: 0.45, blue: 0.2)
        case .modern: .white
        case .minimal: .gray
        case .ornate: Color(red: 0.75, green: 0.6, blue: 0.2)
        case .none: .clear
        }
    }
}

// MARK: - Sample Data

extension Artwork {
    static let samples: [Artwork] = [
        Artwork(
            title: "夕焼けの海",
            artist: "田中太郎",
            createdDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            description: "湘南の海岸から見た夕日をアクリル絵の具で表現した作品",
            category: .painting,
            displayType: .wallFrame,
            thumbnailColor: .orange,
            scaleMultiplier: 1.0
        ),
        Artwork(
            title: "静寂の器",
            artist: "鈴木花子",
            createdDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            description: "備前焼の手法を用いた一点物の花器。窯変が美しい仕上がり",
            category: .ceramics,
            displayType: .pedestal,
            modelFileName: "vase_001.usdz",
            thumbnailColor: .brown,
            scaleMultiplier: 0.8
        ),
        Artwork(
            title: "都市の記憶",
            artist: "佐藤一郎",
            createdDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
            description: "東京の路地裏を撮影したモノクロ写真シリーズの一枚",
            category: .photography,
            displayType: .wallFrame,
            thumbnailColor: .gray,
            scaleMultiplier: 1.2
        ),
        Artwork(
            title: "風の形",
            artist: "山田美咲",
            createdDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            description: "ステンレスワイヤーで風の動きを表現した立体作品",
            category: .sculpture,
            displayType: .floating,
            modelFileName: "wind_sculpture.usdz",
            thumbnailColor: .cyan,
            scaleMultiplier: 1.5
        ),
        Artwork(
            title: "春の庭",
            artist: "田中太郎",
            createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            description: "実家の庭に咲く桜を水彩画で描いた作品",
            category: .painting,
            displayType: .wallFrame,
            thumbnailColor: .pink,
            scaleMultiplier: 0.9
        ),
        Artwork(
            title: "デジタル花火",
            artist: "木村翔",
            createdDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            description: "プロシージャル生成による花火のデジタルアート",
            category: .digital,
            displayType: .showcase,
            thumbnailColor: .indigo,
            scaleMultiplier: 1.0
        ),
    ]
}
