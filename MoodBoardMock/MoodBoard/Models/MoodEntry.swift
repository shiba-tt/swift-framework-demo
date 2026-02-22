import Foundation

/// 気分の記録エントリ
struct MoodEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let note: String?

    init(id: UUID = UUID(), date: Date = Date(), mood: MoodType, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
    }

    /// 日付の表示テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 時刻テキスト
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// 短い日付テキスト
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    /// 曜日テキスト
    var weekdayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
