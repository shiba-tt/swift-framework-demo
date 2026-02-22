import Foundation
import SwiftUI

/// カレンダーイベントを表すモデル
struct LifeEvent: Identifiable, Sendable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let calendarName: String
    let category: LifeCategory
    let isAllDay: Bool

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    var durationHours: Double {
        endDate.timeIntervalSince(startDate) / 3600
    }
}

/// イベントのカテゴリ分類
enum LifeCategory: String, CaseIterable, Sendable {
    case work = "仕事"
    case personal = "プライベート"
    case health = "健康"
    case social = "交流"
    case learning = "学習"
    case travel = "旅行"
    case hobby = "趣味"

    var emoji: String {
        switch self {
        case .work: "💼"
        case .personal: "🏠"
        case .health: "🏃"
        case .social: "👥"
        case .learning: "📚"
        case .travel: "✈️"
        case .hobby: "🎨"
        }
    }

    var color: Color {
        switch self {
        case .work: .blue
        case .personal: .green
        case .health: .orange
        case .social: .pink
        case .learning: .purple
        case .travel: .cyan
        case .hobby: .yellow
        }
    }

    var systemImage: String {
        switch self {
        case .work: "briefcase.fill"
        case .personal: "house.fill"
        case .health: "heart.fill"
        case .social: "person.2.fill"
        case .learning: "book.fill"
        case .travel: "airplane"
        case .hobby: "paintpalette.fill"
        }
    }
}

/// 「On This Day」通知用モデル
struct OnThisDayEntry: Identifiable, Sendable {
    let id: UUID
    let event: LifeEvent
    let yearsAgo: Int

    var displayLabel: String {
        "\(yearsAgo)年前の今日"
    }
}
