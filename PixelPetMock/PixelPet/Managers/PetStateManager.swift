import Foundation

/// ペットの状態管理を行うマネージャー
/// App Group 経由で Widget と状態を共有する
@MainActor
@Observable
final class PetStateManager {

    // MARK: - Singleton

    static let shared = PetStateManager()
    private init() {}

    // MARK: - Constants

    private let appGroupID = "group.com.example.pixelpet"
    private let petDataKey = "petData"
    private let actionHistoryKey = "actionHistory"

    /// ステータスの自然減少量（1時間あたり）
    private let decayPerHour = 5

    // MARK: - State

    private(set) var statusHistory: [PetStatusRecord] = []

    // MARK: - Data Access

    /// App Group の UserDefaults
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Pet Data

    /// ペットデータを保存する
    func savePet(_ pet: Pet) {
        let defaults = sharedDefaults
        defaults?.set(pet.name, forKey: "\(petDataKey)_name")
        defaults?.set(pet.species.rawValue, forKey: "\(petDataKey)_species")
        defaults?.set(pet.birthday.timeIntervalSince1970, forKey: "\(petDataKey)_birthday")
        defaults?.set(pet.hunger, forKey: "\(petDataKey)_hunger")
        defaults?.set(pet.happiness, forKey: "\(petDataKey)_happiness")
        defaults?.set(pet.cleanliness, forKey: "\(petDataKey)_cleanliness")
        defaults?.set(pet.energy, forKey: "\(petDataKey)_energy")

        if let lastFed = pet.lastFedDate {
            defaults?.set(lastFed.timeIntervalSince1970, forKey: "\(petDataKey)_lastFed")
        }
        if let lastPlayed = pet.lastPlayedDate {
            defaults?.set(lastPlayed.timeIntervalSince1970, forKey: "\(petDataKey)_lastPlayed")
        }
        if let lastCleaned = pet.lastCleanedDate {
            defaults?.set(lastCleaned.timeIntervalSince1970, forKey: "\(petDataKey)_lastCleaned")
        }
    }

    /// ペットデータを読み込む
    func loadPet() -> Pet? {
        guard let defaults = sharedDefaults,
              let name = defaults.string(forKey: "\(petDataKey)_name"),
              let speciesRaw = defaults.string(forKey: "\(petDataKey)_species"),
              let species = PetSpecies(rawValue: speciesRaw) else {
            return nil
        }

        let birthdayInterval = defaults.double(forKey: "\(petDataKey)_birthday")
        let birthday = Date(timeIntervalSince1970: birthdayInterval)

        let lastFedInterval = defaults.double(forKey: "\(petDataKey)_lastFed")
        let lastFed = lastFedInterval > 0 ? Date(timeIntervalSince1970: lastFedInterval) : nil

        let lastPlayedInterval = defaults.double(forKey: "\(petDataKey)_lastPlayed")
        let lastPlayed = lastPlayedInterval > 0 ? Date(timeIntervalSince1970: lastPlayedInterval) : nil

        let lastCleanedInterval = defaults.double(forKey: "\(petDataKey)_lastCleaned")
        let lastCleaned = lastCleanedInterval > 0 ? Date(timeIntervalSince1970: lastCleanedInterval) : nil

        return Pet(
            id: UUID(),
            name: name,
            species: species,
            birthday: birthday,
            hunger: defaults.integer(forKey: "\(petDataKey)_hunger"),
            happiness: defaults.integer(forKey: "\(petDataKey)_happiness"),
            cleanliness: defaults.integer(forKey: "\(petDataKey)_cleanliness"),
            energy: defaults.integer(forKey: "\(petDataKey)_energy"),
            lastFedDate: lastFed,
            lastPlayedDate: lastPlayed,
            lastCleanedDate: lastCleaned
        )
    }

    // MARK: - Status Decay

    /// 時間経過によるステータス減少を計算する
    func calculateDecay(for pet: Pet, since lastUpdate: Date) -> Pet {
        let hoursElapsed = Date().timeIntervalSince(lastUpdate) / 3600
        let decay = Int(hoursElapsed * Double(decayPerHour))

        var updated = pet
        updated.hunger = max(0, pet.hunger - decay)
        updated.happiness = max(0, pet.happiness - Int(Double(decay) * 0.8))
        updated.cleanliness = max(0, pet.cleanliness - Int(Double(decay) * 0.6))
        updated.energy = max(0, pet.energy - Int(Double(decay) * 0.4))

        return updated
    }

    // MARK: - Action Application

    /// アクションをペットに適用する
    func applyAction(_ actionType: PetActionType, to pet: Pet) -> Pet {
        var updated = pet
        updated.hunger = min(100, max(0, pet.hunger + actionType.hungerEffect))
        updated.happiness = min(100, max(0, pet.happiness + actionType.happinessEffect))
        updated.cleanliness = min(100, max(0, pet.cleanliness + actionType.cleanlinessEffect))
        updated.energy = min(100, max(0, pet.energy + actionType.energyEffect))

        let now = Date()
        switch actionType {
        case .feed:
            updated.lastFedDate = now
        case .play:
            updated.lastPlayedDate = now
        case .clean:
            updated.lastCleanedDate = now
        case .sleep:
            break
        }

        return updated
    }

    // MARK: - Status History

    /// ステータス履歴を記録する
    func recordStatus(for pet: Pet) {
        let record = PetStatusRecord(
            date: Date(),
            hunger: pet.hunger,
            happiness: pet.happiness,
            cleanliness: pet.cleanliness,
            energy: pet.energy
        )
        statusHistory.append(record)

        // 直近24時間分のみ保持
        let cutoff = Date().addingTimeInterval(-86400)
        statusHistory = statusHistory.filter { $0.date > cutoff }
    }

    // MARK: - Mock Data

    /// デモ用のステータス履歴を生成する
    func generateMockHistory() {
        let now = Date()
        statusHistory = (0..<24).map { hoursAgo in
            let date = now.addingTimeInterval(-Double(23 - hoursAgo) * 3600)
            let base = 50 + Int.random(in: 0...40)
            return PetStatusRecord(
                date: date,
                hunger: min(100, max(10, base + Int.random(in: -15...15))),
                happiness: min(100, max(10, base + Int.random(in: -10...20))),
                cleanliness: min(100, max(10, base + Int.random(in: -20...10))),
                energy: min(100, max(10, base + Int.random(in: -10...10)))
            )
        }
    }
}
