import SwiftUI

// MARK: - PluginReview

struct PluginReview: Identifiable, Sendable {
    let id: UUID
    let pluginID: UUID
    let author: String
    let rating: Double
    let comment: String
    let date: Date
    let helpfulCount: Int

    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    var ratingStars: String {
        String(repeating: "★", count: Int(rating)) + String(repeating: "☆", count: 5 - Int(rating))
    }
}

// MARK: - PluginComparison

struct PluginComparison: Identifiable, Sendable {
    let id: UUID
    let pluginA: AUPlugin
    let pluginB: AUPlugin
    let audioSource: AudioSource
    let activeSlot: ABCompareSlot

    var title: String {
        "\(pluginA.name) vs \(pluginB.name)"
    }
}

// MARK: - Sample Data

extension PluginReview {
    static func samples(for pluginID: UUID) -> [PluginReview] {
        let calendar = Calendar.current
        let now = Date()
        return [
            PluginReview(
                id: UUID(), pluginID: pluginID,
                author: "StudioPro_Tokyo",
                rating: 5.0,
                comment: "音質・操作性ともに最高クラス。ミキシング作業で毎日使っています。CPU 負荷も軽く iPad でも快適に動作します。",
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                helpfulCount: 42
            ),
            PluginReview(
                id: UUID(), pluginID: pluginID,
                author: "BeatMaker_JP",
                rating: 4.0,
                comment: "機能は素晴らしいが UI がやや複雑。初心者には少しハードルが高いかも。プリセットが充実しているのは良い。",
                date: calendar.date(byAdding: .day, value: -10, to: now)!,
                helpfulCount: 18
            ),
            PluginReview(
                id: UUID(), pluginID: pluginID,
                author: "Podcaster_Yuki",
                rating: 5.0,
                comment: "ポッドキャスト収録に革命が起きました。ノイズ除去が秀逸で、後処理がほぼ不要になりました。",
                date: calendar.date(byAdding: .day, value: -21, to: now)!,
                helpfulCount: 31
            ),
            PluginReview(
                id: UUID(), pluginID: pluginID,
                author: "GuitarHero_88",
                rating: 4.0,
                comment: "AUv3 対応でモバイルでも使えるのが最高。ただし旧デバイスではたまに音切れが発生。iPad Pro 推奨。",
                date: calendar.date(byAdding: .day, value: -45, to: now)!,
                helpfulCount: 12
            ),
        ]
    }
}
