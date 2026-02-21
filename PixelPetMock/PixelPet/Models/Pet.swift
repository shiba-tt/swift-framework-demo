import Foundation

/// ペットの情報を表すモデル
struct Pet: Identifiable, Sendable {
    let id: UUID
    var name: String
    var species: PetSpecies
    var birthday: Date
    var hunger: Int
    var happiness: Int
    var cleanliness: Int
    var energy: Int
    var lastFedDate: Date?
    var lastPlayedDate: Date?
    var lastCleanedDate: Date?

    /// ペットの年齢（日数）
    var ageDays: Int {
        Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
    }

    /// 年齢のテキスト表示
    var ageText: String {
        let days = ageDays
        if days < 7 {
            return "\(days)日目"
        } else if days < 30 {
            return "\(days / 7)週目"
        } else {
            return "\(days / 30)ヶ月目"
        }
    }

    /// 総合コンディション（0〜100）
    var overallCondition: Int {
        (hunger + happiness + cleanliness + energy) / 4
    }

    /// ペットの状態
    var mood: PetMood {
        let condition = overallCondition
        if condition >= 80 {
            return .happy
        } else if condition >= 60 {
            return .normal
        } else if condition >= 40 {
            return .sad
        } else if condition >= 20 {
            return .hungry
        } else {
            return .critical
        }
    }

    /// ペットの表情テキスト
    var faceText: String {
        mood.faceText
    }

    /// 最後のごはんからの経過時間テキスト
    var lastFedText: String {
        guard let lastFed = lastFedDate else { return "まだごはんをあげていません" }
        let minutes = Int(Date().timeIntervalSince(lastFed) / 60)
        if minutes < 60 {
            return "\(minutes)分前"
        } else {
            return "\(minutes / 60)時間前"
        }
    }

    /// デフォルトのペット
    static let `default` = Pet(
        id: UUID(),
        name: "ぴくせる",
        species: .cat,
        birthday: Date(),
        hunger: 80,
        happiness: 80,
        cleanliness: 80,
        energy: 80,
        lastFedDate: nil,
        lastPlayedDate: nil,
        lastCleanedDate: nil
    )
}

// MARK: - PetSpecies

/// ペットの種類
enum PetSpecies: String, CaseIterable, Sendable {
    case cat = "ネコ"
    case dog = "イヌ"
    case rabbit = "ウサギ"
    case hamster = "ハムスター"

    var emoji: String {
        switch self {
        case .cat: "🐱"
        case .dog: "🐶"
        case .rabbit: "🐰"
        case .hamster: "🐹"
        }
    }

    var systemImageName: String {
        switch self {
        case .cat: "cat.fill"
        case .dog: "dog.fill"
        case .rabbit: "hare.fill"
        case .hamster: "tortoise.fill"
        }
    }
}

// MARK: - PetMood

/// ペットの機嫌
enum PetMood: String, Sendable {
    case happy = "ごきげん"
    case normal = "ふつう"
    case sad = "さみしい"
    case hungry = "おなかすいた"
    case critical = "ぐったり"

    var faceText: String {
        switch self {
        case .happy: "^ω^"
        case .normal: "・ω・"
        case .sad: ";ω;"
        case .hungry: ">ω<"
        case .critical: "x_x"
        }
    }

    var colorName: String {
        switch self {
        case .happy: "green"
        case .normal: "blue"
        case .sad: "orange"
        case .hungry: "yellow"
        case .critical: "red"
        }
    }

    var systemImageName: String {
        switch self {
        case .happy: "face.smiling.inverse"
        case .normal: "face.smiling"
        case .sad: "cloud.rain"
        case .hungry: "fork.knife"
        case .critical: "exclamationmark.triangle.fill"
        }
    }
}
