import SwiftUI

// MARK: - ReelProject

struct ReelProject: Identifiable, Sendable {
    let id: UUID
    var title: String
    var clips: [MediaClip]
    var bgmTrack: BGMTrack
    var transitionStyle: TransitionStyle
    var targetDuration: TargetDuration
    var textOverlays: [TextOverlay]
    let createdAt: Date
    var status: ProjectStatus

    var selectedClips: [MediaClip] {
        clips.filter(\.isSelected)
    }

    var totalDuration: TimeInterval {
        selectedClips.reduce(0) { $0 + $1.trimmedDuration }
    }

    var totalDurationText: String {
        let seconds = Int(totalDuration)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    var clipCount: Int {
        selectedClips.count
    }

    var averageScore: Double {
        guard !selectedClips.isEmpty else { return 0 }
        return selectedClips.reduce(0) { $0 + $1.overallScore } / Double(selectedClips.count)
    }
}

// MARK: - BGMTrack

struct BGMTrack: Identifiable, Sendable {
    let id: UUID
    let name: String
    let artist: String
    let bpm: Int
    let genre: MusicGenre
    let duration: TimeInterval

    var bpmText: String { "\(bpm) BPM" }

    var durationText: String {
        let seconds = Int(duration)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - MusicGenre

enum MusicGenre: String, Sendable, CaseIterable, Identifiable {
    case pop = "ポップ"
    case lofi = "Lo-Fi"
    case cinematic = "シネマティック"
    case acoustic = "アコースティック"
    case electronic = "エレクトロニック"
    case jazz = "ジャズ"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .pop: return "🎵"
        case .lofi: return "🎧"
        case .cinematic: return "🎬"
        case .acoustic: return "🎸"
        case .electronic: return "🎛️"
        case .jazz: return "🎷"
        }
    }

    var color: Color {
        switch self {
        case .pop: return .pink
        case .lofi: return .purple
        case .cinematic: return .indigo
        case .acoustic: return .orange
        case .electronic: return .cyan
        case .jazz: return .yellow
        }
    }
}

// MARK: - TransitionStyle

enum TransitionStyle: String, Sendable, CaseIterable, Identifiable {
    case crossDissolve = "クロスディゾルブ"
    case slide = "スライド"
    case zoom = "ズーム"
    case whip = "ウィップパン"
    case glitch = "グリッチ"
    case beatSync = "ビート同期"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .crossDissolve: return "🌫️"
        case .slide: return "➡️"
        case .zoom: return "🔍"
        case .whip: return "💨"
        case .glitch: return "⚡"
        case .beatSync: return "🎵"
        }
    }

    var description: String {
        switch self {
        case .crossDissolve: return "滑らかにフェードで切り替え"
        case .slide: return "横方向にスライドして切り替え"
        case .zoom: return "ズームインしながら次のシーンへ"
        case .whip: return "高速パンで勢いよく切り替え"
        case .glitch: return "デジタルグリッチ効果で切り替え"
        case .beatSync: return "BGMのビートに合わせて切り替え"
        }
    }

    var transitionDuration: TimeInterval {
        switch self {
        case .crossDissolve: return 0.8
        case .slide: return 0.5
        case .zoom: return 0.6
        case .whip: return 0.3
        case .glitch: return 0.2
        case .beatSync: return 0.4
        }
    }
}

// MARK: - TargetDuration

enum TargetDuration: String, Sendable, CaseIterable, Identifiable {
    case short15 = "15秒"
    case medium30 = "30秒"
    case standard45 = "45秒"
    case long60 = "60秒"

    var id: String { rawValue }

    var seconds: TimeInterval {
        switch self {
        case .short15: return 15
        case .medium30: return 30
        case .standard45: return 45
        case .long60: return 60
        }
    }

    var label: String {
        switch self {
        case .short15: return "15秒 (TikTok)"
        case .medium30: return "30秒 (Reels)"
        case .standard45: return "45秒 (標準)"
        case .long60: return "60秒 (YouTube Shorts)"
        }
    }
}

// MARK: - TextOverlay

struct TextOverlay: Identifiable, Sendable {
    let id: UUID
    var text: String
    var position: OverlayPosition
    var style: TextStyle
    var appearAt: TimeInterval
    var disappearAt: TimeInterval
}

enum OverlayPosition: String, Sendable, CaseIterable, Identifiable {
    case top = "上部"
    case center = "中央"
    case bottom = "下部"

    var id: String { rawValue }
}

enum TextStyle: String, Sendable, CaseIterable, Identifiable {
    case title = "タイトル"
    case subtitle = "サブタイトル"
    case caption = "キャプション"
    case bold = "ボールド"

    var id: String { rawValue }
}

// MARK: - ProjectStatus

enum ProjectStatus: String, Sendable {
    case draft = "下書き"
    case analyzing = "AI分析中"
    case composing = "合成中"
    case ready = "完成"
    case exported = "書き出し済み"

    var emoji: String {
        switch self {
        case .draft: return "📝"
        case .analyzing: return "🤖"
        case .composing: return "🎬"
        case .ready: return "✅"
        case .exported: return "📤"
        }
    }

    var color: Color {
        switch self {
        case .draft: return .secondary
        case .analyzing: return .blue
        case .composing: return .purple
        case .ready: return .green
        case .exported: return .orange
        }
    }
}

// MARK: - Sample Data

extension BGMTrack {
    static let samples: [BGMTrack] = [
        BGMTrack(id: UUID(), name: "Summer Vibes", artist: "Chill Beats", bpm: 110, genre: .pop, duration: 120),
        BGMTrack(id: UUID(), name: "Midnight Coffee", artist: "Lo-Fi Dreams", bpm: 85, genre: .lofi, duration: 180),
        BGMTrack(id: UUID(), name: "Epic Journey", artist: "Cinematic Sound", bpm: 130, genre: .cinematic, duration: 150),
        BGMTrack(id: UUID(), name: "Sunset Acoustic", artist: "Guitar Moods", bpm: 95, genre: .acoustic, duration: 200),
        BGMTrack(id: UUID(), name: "Neon Pulse", artist: "Synth Wave", bpm: 128, genre: .electronic, duration: 160),
        BGMTrack(id: UUID(), name: "Café Jazz", artist: "Smooth Notes", bpm: 100, genre: .jazz, duration: 240),
    ]
}

extension ReelProject {
    static let sample: ReelProject = {
        ReelProject(
            id: UUID(),
            title: "夏の思い出 2026",
            clips: MediaClip.samples,
            bgmTrack: BGMTrack.samples[0],
            transitionStyle: .beatSync,
            targetDuration: .standard45,
            textOverlays: [
                TextOverlay(id: UUID(), text: "Summer Memories", position: .center, style: .title, appearAt: 0, disappearAt: 3),
                TextOverlay(id: UUID(), text: "Best moments ✨", position: .bottom, style: .caption, appearAt: 20, disappearAt: 25),
            ],
            createdAt: Date(),
            status: .ready
        )
    }()
}
