import Foundation

struct VideoContent: Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let durationSeconds: TimeInterval
    let thumbnailSystemImage: String
    let genre: Genre

    var durationText: String {
        let hours = Int(durationSeconds) / 3600
        let minutes = (Int(durationSeconds) % 3600) / 60
        let seconds = Int(durationSeconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    enum Genre: String, CaseIterable, Sendable {
        case movie = "映画"
        case anime = "アニメ"
        case documentary = "ドキュメンタリー"
        case music = "音楽"

        var systemImage: String {
            switch self {
            case .movie: return "film"
            case .anime: return "sparkles.tv"
            case .documentary: return "globe.asia.australia"
            case .music: return "music.note.tv"
            }
        }
    }

    static let samples: [VideoContent] = [
        VideoContent(
            id: UUID(), title: "星を継ぐもの", subtitle: "SF アドベンチャー",
            durationSeconds: 7320, thumbnailSystemImage: "star.fill",
            genre: .movie
        ),
        VideoContent(
            id: UUID(), title: "東京サンセット", subtitle: "都市ドキュメンタリー",
            durationSeconds: 5400, thumbnailSystemImage: "building.2.fill",
            genre: .documentary
        ),
        VideoContent(
            id: UUID(), title: "ネオンナイト", subtitle: "サイバーパンクアニメ",
            durationSeconds: 1440, thumbnailSystemImage: "bolt.fill",
            genre: .anime
        ),
        VideoContent(
            id: UUID(), title: "海辺のメロディ", subtitle: "ライブコンサート",
            durationSeconds: 4800, thumbnailSystemImage: "music.mic",
            genre: .music
        ),
        VideoContent(
            id: UUID(), title: "深海の冒険", subtitle: "自然ドキュメンタリー",
            durationSeconds: 3600, thumbnailSystemImage: "water.waves",
            genre: .documentary
        ),
        VideoContent(
            id: UUID(), title: "桜の約束", subtitle: "ロマンス映画",
            durationSeconds: 6600, thumbnailSystemImage: "heart.fill",
            genre: .movie
        ),
    ]
}
