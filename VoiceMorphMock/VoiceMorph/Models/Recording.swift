import Foundation

/// 録音データモデル
struct Recording: Identifiable, Sendable {
    let id: UUID
    let name: String
    let date: Date
    let duration: TimeInterval
    let presetName: String
    let fileURL: URL

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
        return formatter.string(from: date)
    }

    var relativeTimeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static let samples: [Recording] = [
        Recording(
            id: UUID(), name: "ロボットボイス テスト",
            date: Date().addingTimeInterval(-3600), duration: 15.5,
            presetName: "ロボット",
            fileURL: URL(fileURLWithPath: "/tmp/sample1.m4a")
        ),
        Recording(
            id: UUID(), name: "ヘリウム 自己紹介",
            date: Date().addingTimeInterval(-7200), duration: 8.2,
            presetName: "ヘリウム",
            fileURL: URL(fileURLWithPath: "/tmp/sample2.m4a")
        ),
        Recording(
            id: UUID(), name: "デーモンボイス",
            date: Date().addingTimeInterval(-86400), duration: 22.0,
            presetName: "デーモン",
            fileURL: URL(fileURLWithPath: "/tmp/sample3.m4a")
        ),
    ]
}
