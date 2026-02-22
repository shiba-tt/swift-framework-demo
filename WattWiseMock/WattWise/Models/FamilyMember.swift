import Foundation
import SwiftUI

/// 家族メンバーモデル
struct FamilyMember: Identifiable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let role: FamilyRole
    var deviceType: DeviceType
    var cleanEnergyRate: Double
    var quizScore: Int

    var displayCleanRate: String {
        "\(Int(cleanEnergyRate * 100))%"
    }
}

/// 家族の役割
enum FamilyRole: String, CaseIterable, Sendable {
    case parent = "おとな"
    case child = "こども"

    var defaultIcon: String {
        switch self {
        case .parent: "person.fill"
        case .child: "face.smiling.fill"
        }
    }
}

/// 管理するデバイスタイプ
enum DeviceType: String, CaseIterable, Sendable {
    case ev = "EV充電"
    case aircon = "エアコン"
    case learning = "学習中"
    case none = "なし"

    var emoji: String {
        switch self {
        case .ev: "🔋"
        case .aircon: "🌡"
        case .learning: "📱"
        case .none: "—"
        }
    }

    var systemImage: String {
        switch self {
        case .ev: "bolt.car.fill"
        case .aircon: "thermometer.medium"
        case .learning: "book.fill"
        case .none: "minus"
        }
    }
}

/// エネルギークイズの問題
struct EnergyQuiz: Identifiable, Sendable {
    let id: UUID
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let points: Int
}

/// ウィジェット用データ
struct WattWiseWidgetData: Codable, Sendable {
    let familyName: String
    let challengeTitle: String
    let challengeProgress: Double
    let co2Reduction: Double
    let costSaving: Double
    let cleanRate: Double
}
