import SwiftUI

// MARK: - CineFilter

enum CineFilter: String, CaseIterable, Identifiable, Sendable {
    case nolan = "ノーラン"
    case wesAnderson = "ウェス・アンダーソン"
    case ghibli = "ジブリ"
    case tarantino = "タランティーノ"
    case lynch = "リンチ"
    case kubrick = "キューブリック"
    case wonKarWai = "ウォン・カーウァイ"
    case villeneuve = "ヴィルヌーヴ"

    var id: String { rawValue }

    var directorName: String {
        switch self {
        case .nolan: "Christopher Nolan"
        case .wesAnderson: "Wes Anderson"
        case .ghibli: "Studio Ghibli"
        case .tarantino: "Quentin Tarantino"
        case .lynch: "David Lynch"
        case .kubrick: "Stanley Kubrick"
        case .wonKarWai: "Wong Kar-wai"
        case .villeneuve: "Denis Villeneuve"
        }
    }

    var emoji: String {
        switch self {
        case .nolan: "🌀"
        case .wesAnderson: "🎨"
        case .ghibli: "🍃"
        case .tarantino: "🔫"
        case .lynch: "🌲"
        case .kubrick: "👁️"
        case .wonKarWai: "🌃"
        case .villeneuve: "🏜️"
        }
    }

    var description: String {
        switch self {
        case .nolan: "ダークブルー基調・高コントラスト・IMAX風"
        case .wesAnderson: "パステルカラー・左右対称・暖色系"
        case .ghibli: "柔らかい水彩風・自然な緑と空色"
        case .tarantino: "高彩度・フィルムグレイン・70年代風"
        case .lynch: "ダーク・不穏な色調・低彩度"
        case .kubrick: "冷たい対称構図・クリーンな色調"
        case .wonKarWai: "ネオン・暖色ぼかし・夜景向き"
        case .villeneuve: "デサチュレート・広大な構図・SF風"
        }
    }

    var representativeWork: String {
        switch self {
        case .nolan: "インターステラー / TENET"
        case .wesAnderson: "グランド・ブダペスト・ホテル"
        case .ghibli: "千と千尋の神隠し"
        case .tarantino: "パルプ・フィクション"
        case .lynch: "ツイン・ピークス"
        case .kubrick: "2001年宇宙の旅"
        case .wonKarWai: "花様年華"
        case .villeneuve: "ブレードランナー 2049 / DUNE"
        }
    }

    var parameters: FilterParameters {
        switch self {
        case .nolan:
            FilterParameters(
                brightness: -0.05, contrast: 1.3, saturation: 0.8,
                temperature: 5500, tint: -10,
                vignetteIntensity: 0.8, grainAmount: 0.05,
                primaryTone: .blue
            )
        case .wesAnderson:
            FilterParameters(
                brightness: 0.08, contrast: 0.9, saturation: 1.2,
                temperature: 7000, tint: 15,
                vignetteIntensity: 0.3, grainAmount: 0.02,
                primaryTone: .pink
            )
        case .ghibli:
            FilterParameters(
                brightness: 0.1, contrast: 0.85, saturation: 1.1,
                temperature: 6500, tint: 5,
                vignetteIntensity: 0.2, grainAmount: 0.0,
                primaryTone: .green
            )
        case .tarantino:
            FilterParameters(
                brightness: 0.0, contrast: 1.4, saturation: 1.3,
                temperature: 6000, tint: 0,
                vignetteIntensity: 0.6, grainAmount: 0.15,
                primaryTone: .yellow
            )
        case .lynch:
            FilterParameters(
                brightness: -0.1, contrast: 1.2, saturation: 0.6,
                temperature: 4500, tint: -20,
                vignetteIntensity: 1.0, grainAmount: 0.1,
                primaryTone: .indigo
            )
        case .kubrick:
            FilterParameters(
                brightness: 0.0, contrast: 1.1, saturation: 0.9,
                temperature: 5000, tint: 0,
                vignetteIntensity: 0.4, grainAmount: 0.03,
                primaryTone: .cyan
            )
        case .wonKarWai:
            FilterParameters(
                brightness: -0.03, contrast: 1.15, saturation: 1.4,
                temperature: 8000, tint: 20,
                vignetteIntensity: 0.5, grainAmount: 0.08,
                primaryTone: .orange
            )
        case .villeneuve:
            FilterParameters(
                brightness: -0.08, contrast: 1.25, saturation: 0.5,
                temperature: 5200, tint: -5,
                vignetteIntensity: 0.3, grainAmount: 0.04,
                primaryTone: .gray
            )
        }
    }

    var color: Color {
        parameters.primaryTone
    }
}

// MARK: - FilterParameters

struct FilterParameters: Sendable {
    let brightness: Double
    let contrast: Double
    let saturation: Double
    let temperature: Double
    let tint: Double
    let vignetteIntensity: Double
    let grainAmount: Double
    let primaryTone: Color
}

// MARK: - CompositionAdvice

enum CompositionAdvice: String, CaseIterable, Identifiable, Sendable {
    case ruleOfThirds = "三分割法"
    case goldenRatio = "黄金比"
    case symmetry = "対称構図"
    case leadingLines = "導線構図"
    case framing = "フレーミング"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ruleOfThirds: "grid.3x3.topleft.fill"
        case .goldenRatio: "spiral"
        case .symmetry: "arrow.left.and.right"
        case .leadingLines: "point.topleft.down.to.point.bottomright.curvepath"
        case .framing: "rectangle.center.inset.filled"
        }
    }

    var suggestion: String {
        switch self {
        case .ruleOfThirds: "被写体を三分割線の交点に配置しましょう"
        case .goldenRatio: "少し右に寄ると黄金比に近づきます"
        case .symmetry: "左右対称の構図が見つかりました"
        case .leadingLines: "奥行きのある導線が効果的です"
        case .framing: "自然なフレームで被写体を囲みましょう"
        }
    }
}

// MARK: - CaptureMode

enum CaptureMode: String, CaseIterable, Identifiable, Sendable {
    case photo = "写真"
    case video = "動画"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .photo: "camera.fill"
        case .video: "video.fill"
        }
    }
}

// MARK: - CapturedMedia

struct CapturedMedia: Identifiable, Sendable {
    let id: UUID
    let mode: CaptureMode
    let filter: CineFilter
    let capturedAt: Date
    let duration: TimeInterval?
    let compositionScore: Double

    init(
        id: UUID = UUID(),
        mode: CaptureMode,
        filter: CineFilter,
        capturedAt: Date = .now,
        duration: TimeInterval? = nil,
        compositionScore: Double = 0.0
    ) {
        self.id = id
        self.mode = mode
        self.filter = filter
        self.capturedAt = capturedAt
        self.duration = duration
        self.compositionScore = compositionScore
    }

    var formattedDuration: String {
        guard let duration else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var scoreLabel: String {
        switch compositionScore {
        case 0.9...: "映画的構図"
        case 0.7..<0.9: "良い構図"
        case 0.5..<0.7: "まずまず"
        default: "改善の余地あり"
        }
    }

    var scoreColor: Color {
        switch compositionScore {
        case 0.9...: .yellow
        case 0.7..<0.9: .green
        case 0.5..<0.7: .blue
        default: .gray
        }
    }
}
