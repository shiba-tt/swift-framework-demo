import Foundation
import SwiftUI

/// エクササイズの種類
enum Exercise: String, CaseIterable, Identifiable, Sendable {
    case squat = "スクワット"
    case pushup = "腕立て伏せ"
    case deadlift = "デッドリフト"
    case lunge = "ランジ"
    case plank = "プランク"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .squat: "figure.strengthtraining.traditional"
        case .pushup: "figure.core.training"
        case .deadlift: "figure.strengthtraining.functional"
        case .lunge: "figure.walk"
        case .plank: "figure.yoga"
        }
    }

    var color: Color {
        switch self {
        case .squat: .blue
        case .pushup: .green
        case .deadlift: .purple
        case .lunge: .orange
        case .plank: .teal
        }
    }

    var targetJoints: [JointPair] {
        switch self {
        case .squat:
            [
                JointPair(name: "膝", idealAngle: 120, tolerance: 15),
                JointPair(name: "腰", idealAngle: 90, tolerance: 20),
                JointPair(name: "足首", idealAngle: 75, tolerance: 10),
            ]
        case .pushup:
            [
                JointPair(name: "肘", idealAngle: 90, tolerance: 15),
                JointPair(name: "肩", idealAngle: 45, tolerance: 10),
                JointPair(name: "腰", idealAngle: 180, tolerance: 10),
            ]
        case .deadlift:
            [
                JointPair(name: "膝", idealAngle: 150, tolerance: 15),
                JointPair(name: "腰", idealAngle: 100, tolerance: 20),
                JointPair(name: "肩", idealAngle: 30, tolerance: 10),
            ]
        case .lunge:
            [
                JointPair(name: "前膝", idealAngle: 90, tolerance: 15),
                JointPair(name: "後膝", idealAngle: 90, tolerance: 15),
                JointPair(name: "腰", idealAngle: 170, tolerance: 10),
            ]
        case .plank:
            [
                JointPair(name: "肩", idealAngle: 90, tolerance: 10),
                JointPair(name: "腰", idealAngle: 180, tolerance: 5),
                JointPair(name: "膝", idealAngle: 180, tolerance: 5),
            ]
        }
    }

    var tips: [String] {
        switch self {
        case .squat:
            [
                "膝がつま先より前に出ないようにする",
                "背中をまっすぐに保つ",
                "太ももが床と平行になるまで下げる",
                "かかとに体重を乗せる",
            ]
        case .pushup:
            [
                "肘を 45 度に開く",
                "腰が反らないようにする",
                "胸が床に近づくまで下げる",
                "頭からかかとまで一直線を保つ",
            ]
        case .deadlift:
            [
                "背中を丸めない",
                "バーを体に近づけて持ち上げる",
                "膝を軽く曲げた状態をキープ",
                "お尻を後ろに引くイメージ",
            ]
        case .lunge:
            [
                "前膝が 90 度になるまで踏み込む",
                "後ろ膝が床に触れる手前で止める",
                "上半身はまっすぐ保つ",
                "左右均等にトレーニングする",
            ]
        case .plank:
            [
                "お腹に力を入れて腰が落ちないようにする",
                "お尻を上げすぎない",
                "肩の真下に肘を置く",
                "首は自然な位置に保つ",
            ]
        }
    }
}

/// 関節ペアの定義
struct JointPair: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let idealAngle: Int
    let tolerance: Int

    var minAngle: Int { idealAngle - tolerance }
    var maxAngle: Int { idealAngle + tolerance }
}
