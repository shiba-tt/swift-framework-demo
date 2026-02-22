import Foundation
import SwiftUI

// MARK: - MoodType

enum MoodType: String, Sendable, CaseIterable, Identifiable {
    case focus
    case relax
    case workout
    case commute
    case party
    case sleep

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .focus: "集中モード"
        case .relax: "リラックス"
        case .workout: "ワークアウト"
        case .commute: "通勤・通学"
        case .party: "パーティー"
        case .sleep: "おやすみ"
        }
    }

    var icon: String {
        switch self {
        case .focus: "brain.head.profile"
        case .relax: "cup.and.saucer.fill"
        case .workout: "figure.run"
        case .commute: "tram.fill"
        case .party: "party.popper.fill"
        case .sleep: "moon.fill"
        }
    }

    var color: Color {
        switch self {
        case .focus: .blue
        case .relax: .green
        case .workout: .red
        case .commute: .orange
        case .party: .purple
        case .sleep: .indigo
        }
    }

    var preferredGenres: [Genre] {
        switch self {
        case .focus: [.lofi, .ambient, .classical]
        case .relax: [.jazz, .ambient, .lofi]
        case .workout: [.electronic, .hiphop, .rock]
        case .commute: [.pop, .rock, .hiphop]
        case .party: [.electronic, .pop, .hiphop]
        case .sleep: [.ambient, .classical, .jazz]
        }
    }
}

// MARK: - ContextCondition

struct ContextCondition: Sendable {
    let timeOfDay: TimeOfDay
    let weather: WeatherCondition?
    let location: LocationType?
    let activity: ActivityType?

    var contextTag: String {
        var tags: [String] = [timeOfDay.displayName]
        if let weather { tags.append(weather.displayName) }
        if let location { tags.append(location.displayName) }
        if let activity { tags.append(activity.displayName) }
        return tags.joined(separator: " / ")
    }
}

// MARK: - TimeOfDay

enum TimeOfDay: String, Sendable {
    case earlyMorning
    case morning
    case afternoon
    case evening
    case night
    case lateNight

    var displayName: String {
        switch self {
        case .earlyMorning: "早朝"
        case .morning: "朝"
        case .afternoon: "昼"
        case .evening: "夕方"
        case .night: "夜"
        case .lateNight: "深夜"
        }
    }

    var icon: String {
        switch self {
        case .earlyMorning: "sunrise"
        case .morning: "sun.max"
        case .afternoon: "sun.min"
        case .evening: "sunset"
        case .night: "moon.stars"
        case .lateNight: "moon.zzz"
        }
    }

    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 4..<7: return .earlyMorning
        case 7..<11: return .morning
        case 11..<16: return .afternoon
        case 16..<19: return .evening
        case 19..<23: return .night
        default: return .lateNight
        }
    }
}

// MARK: - WeatherCondition

enum WeatherCondition: String, Sendable, CaseIterable {
    case sunny
    case cloudy
    case rainy
    case snowy

    var displayName: String {
        switch self {
        case .sunny: "晴れ"
        case .cloudy: "曇り"
        case .rainy: "雨"
        case .snowy: "雪"
        }
    }

    var icon: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rainy: "cloud.rain.fill"
        case .snowy: "cloud.snow.fill"
        }
    }
}

// MARK: - LocationType

enum LocationType: String, Sendable, CaseIterable {
    case home
    case office
    case gym
    case cafe
    case transit

    var displayName: String {
        switch self {
        case .home: "自宅"
        case .office: "オフィス"
        case .gym: "ジム"
        case .cafe: "カフェ"
        case .transit: "移動中"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .office: "building.2.fill"
        case .gym: "dumbbell.fill"
        case .cafe: "cup.and.saucer.fill"
        case .transit: "car.fill"
        }
    }
}

// MARK: - ActivityType

enum ActivityType: String, Sendable, CaseIterable {
    case working
    case exercising
    case relaxing
    case studying
    case driving

    var displayName: String {
        switch self {
        case .working: "仕事中"
        case .exercising: "運動中"
        case .relaxing: "休憩中"
        case .studying: "勉強中"
        case .driving: "ドライブ中"
        }
    }

    var icon: String {
        switch self {
        case .working: "laptopcomputer"
        case .exercising: "figure.run"
        case .relaxing: "sofa.fill"
        case .studying: "book.fill"
        case .driving: "car.fill"
        }
    }
}

// MARK: - Playlist

struct Playlist: Identifiable, Sendable {
    let id: UUID
    let name: String
    let mood: MoodType
    let context: ContextCondition
    let songs: [Song]
    let generatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        mood: MoodType,
        context: ContextCondition,
        songs: [Song],
        generatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.mood = mood
        self.context = context
        self.songs = songs
        self.generatedAt = generatedAt
    }

    var totalDuration: Int {
        songs.reduce(0) { $0 + $1.durationSeconds }
    }

    var totalDurationText: String {
        let minutes = totalDuration / 60
        return "\(minutes)分"
    }
}
