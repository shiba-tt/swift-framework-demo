import Foundation
import SwiftUI

/// カレンダーから取得した会議イベント
struct MeetingEvent: Identifiable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let attendeeCount: Int
    let isRecurring: Bool
    let calendarColor: Color
    let organizer: String?
    let location: String?

    /// 会議の時間（分）
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    /// 会議の時間テキスト
    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)時間\(minutes)分"
        } else if hours > 0 {
            return "\(hours)時間"
        }
        return "\(minutes)分"
    }

    /// 推定コスト（参加者数 × 時間 × 推定時給）
    func estimatedCost(hourlyRate: Double) -> Double {
        let hours = Double(durationMinutes) / 60.0
        return Double(attendeeCount) * hours * hourlyRate
    }

    /// 時刻テキスト（HH:mm）
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
