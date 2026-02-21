import Foundation

// MARK: - PedalBoardPreset（ペダルボードプリセット）

struct PedalBoardPreset: Identifiable, Sendable, Codable {
    let id: UUID
    var name: String
    var category: PresetCategory
    var pedalConfigs: [PedalConfig]
    var isFavorite: Bool
    var createdAt: Date

    init(
        name: String,
        category: PresetCategory,
        pedalConfigs: [PedalConfig],
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.pedalConfigs = pedalConfigs
        self.isFavorite = isFavorite
        self.createdAt = .now
    }
}

// MARK: - PedalConfig（プリセット内のペダル設定）

struct PedalConfig: Identifiable, Sendable, Codable {
    let id: UUID
    let effectTypeRawValue: String
    let isEnabled: Bool
    let parameterValues: [String: Float]
    let order: Int

    init(effectType: EffectType, isEnabled: Bool, parameterValues: [String: Float], order: Int) {
        self.id = UUID()
        self.effectTypeRawValue = effectType.rawValue
        self.isEnabled = isEnabled
        self.parameterValues = parameterValues
        self.order = order
    }

    var effectType: EffectType? {
        EffectType(rawValue: effectTypeRawValue)
    }
}

// MARK: - PresetCategory（プリセットカテゴリ）

enum PresetCategory: String, Sendable, Codable, CaseIterable, Identifiable {
    case clean = "Clean"
    case crunch = "Crunch"
    case highGain = "High Gain"
    case ambient = "Ambient"
    case blues = "Blues"
    case rock = "Rock"
    case metal = "Metal"
    case acoustic = "Acoustic"
    case custom = "Custom"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .clean: "✨"
        case .crunch: "🔥"
        case .highGain: "⚡"
        case .ambient: "🌌"
        case .blues: "🎷"
        case .rock: "🤘"
        case .metal: "🤟"
        case .acoustic: "🪕"
        case .custom: "⚙️"
        }
    }

    var displayName: String { rawValue }
}

// MARK: - Setlist（セットリスト）

struct Setlist: Identifiable, Sendable, Codable {
    let id: UUID
    var name: String
    var songs: [SetlistSong]
    var createdAt: Date

    init(name: String, songs: [SetlistSong] = []) {
        self.id = UUID()
        self.name = name
        self.songs = songs
        self.createdAt = .now
    }
}

// MARK: - SetlistSong（セットリスト内の曲）

struct SetlistSong: Identifiable, Sendable, Codable {
    let id: UUID
    var title: String
    var presetID: UUID
    var bpm: Int?
    var notes: String?
    var order: Int

    init(title: String, presetID: UUID, bpm: Int? = nil, notes: String? = nil, order: Int) {
        self.id = UUID()
        self.title = title
        self.presetID = presetID
        self.bpm = bpm
        self.notes = notes
        self.order = order
    }
}

// MARK: - FactoryPresets（ファクトリープリセット）

enum FactoryPresets {
    static let all: [PedalBoardPreset] = [
        PedalBoardPreset(
            name: "Clean Shimmer",
            category: .clean,
            pedalConfigs: [
                PedalConfig(effectType: .compressor, isEnabled: true,
                           parameterValues: ["Threshold": -15, "Ratio": 3, "Attack": 15, "Release": 150], order: 0),
                PedalConfig(effectType: .chorus, isEnabled: true,
                           parameterValues: ["Rate": 1.2, "Depth": 0.4, "Mix": 0.3], order: 1),
                PedalConfig(effectType: .reverb, isEnabled: true,
                           parameterValues: ["Decay": 2.5, "Damping": 0.4, "Mix": 0.25], order: 2),
            ]
        ),
        PedalBoardPreset(
            name: "Blues Driver",
            category: .blues,
            pedalConfigs: [
                PedalConfig(effectType: .compressor, isEnabled: true,
                           parameterValues: ["Threshold": -20, "Ratio": 4, "Attack": 10, "Release": 100], order: 0),
                PedalConfig(effectType: .overdrive, isEnabled: true,
                           parameterValues: ["Drive": 0.4, "Tone": 0.6, "Level": 0.7], order: 1),
                PedalConfig(effectType: .delay, isEnabled: true,
                           parameterValues: ["Time": 0.35, "Feedback": 0.2, "Mix": 0.2], order: 2),
                PedalConfig(effectType: .reverb, isEnabled: true,
                           parameterValues: ["Decay": 1.5, "Damping": 0.5, "Mix": 0.2], order: 3),
            ]
        ),
        PedalBoardPreset(
            name: "Classic Rock",
            category: .rock,
            pedalConfigs: [
                PedalConfig(effectType: .noiseGate, isEnabled: true,
                           parameterValues: ["Threshold": -45, "Release": 30], order: 0),
                PedalConfig(effectType: .overdrive, isEnabled: true,
                           parameterValues: ["Drive": 0.7, "Tone": 0.5, "Level": 0.65], order: 1),
                PedalConfig(effectType: .eq, isEnabled: true,
                           parameterValues: ["Low": 2, "Mid": 3, "High": 1], order: 2),
                PedalConfig(effectType: .delay, isEnabled: true,
                           parameterValues: ["Time": 0.4, "Feedback": 0.25, "Mix": 0.25], order: 3),
            ]
        ),
        PedalBoardPreset(
            name: "Heavy Metal",
            category: .metal,
            pedalConfigs: [
                PedalConfig(effectType: .noiseGate, isEnabled: true,
                           parameterValues: ["Threshold": -35, "Release": 20], order: 0),
                PedalConfig(effectType: .compressor, isEnabled: true,
                           parameterValues: ["Threshold": -10, "Ratio": 8, "Attack": 5, "Release": 80], order: 1),
                PedalConfig(effectType: .distortion, isEnabled: true,
                           parameterValues: ["Gain": 0.8, "Tone": 0.5, "Level": 0.6], order: 2),
                PedalConfig(effectType: .eq, isEnabled: true,
                           parameterValues: ["Low": 4, "Mid": -2, "High": 3], order: 3),
                PedalConfig(effectType: .reverb, isEnabled: false,
                           parameterValues: ["Decay": 0.8, "Damping": 0.7, "Mix": 0.1], order: 4),
            ]
        ),
        PedalBoardPreset(
            name: "Ambient Dreams",
            category: .ambient,
            pedalConfigs: [
                PedalConfig(effectType: .chorus, isEnabled: true,
                           parameterValues: ["Rate": 0.5, "Depth": 0.6, "Mix": 0.4], order: 0),
                PedalConfig(effectType: .delay, isEnabled: true,
                           parameterValues: ["Time": 0.8, "Feedback": 0.6, "Mix": 0.5], order: 1),
                PedalConfig(effectType: .reverb, isEnabled: true,
                           parameterValues: ["Decay": 6.0, "Damping": 0.3, "Mix": 0.6], order: 2),
                PedalConfig(effectType: .tremolo, isEnabled: true,
                           parameterValues: ["Rate": 2, "Depth": 0.3], order: 3),
            ]
        ),
    ]
}
