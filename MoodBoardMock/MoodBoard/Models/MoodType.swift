import Foundation
import SwiftUI

/// 気分の種類
enum MoodType: String, CaseIterable, Codable, Sendable {
    case happy = "happy"
    case good = "good"
    case neutral = "neutral"
    case sad = "sad"
    case fire = "fire"

    /// 表示用の絵文字
    var emoji: String {
        switch self {
        case .happy: "😊"
        case .good: "😌"
        case .neutral: "😐"
        case .sad: "😔"
        case .fire: "🔥"
        }
    }

    /// 表示名
    var displayName: String {
        switch self {
        case .happy: "ハッピー"
        case .good: "いい感じ"
        case .neutral: "ふつう"
        case .sad: "しょんぼり"
        case .fire: "やる気満々"
        }
    }

    /// テーマカラー
    var color: Color {
        switch self {
        case .happy: .yellow
        case .good: .green
        case .neutral: .gray
        case .sad: .blue
        case .fire: .orange
        }
    }

    /// 数値スコア（グラフ用、1〜5）
    var score: Int {
        switch self {
        case .sad: 1
        case .neutral: 2
        case .good: 3
        case .happy: 4
        case .fire: 5
        }
    }

    /// スコアから MoodType を取得
    static func from(score: Int) -> MoodType {
        switch score {
        case 1: .sad
        case 2: .neutral
        case 3: .good
        case 4: .happy
        case 5: .fire
        default: .neutral
        }
    }
}
