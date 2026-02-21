import Foundation

/// クエストゲームの状態管理を行うマネージャー
/// App Group 経由で Widget と状態を共有する
@MainActor
@Observable
final class QuestGameManager {

    // MARK: - Singleton

    static let shared = QuestGameManager()
    private init() {}

    // MARK: - Constants

    private let appGroupID = "group.com.example.widgetquest"
    private let heroDataKey = "heroData"

    /// 利用可能なロケーション
    static let locations: [QuestLocation] = [
        QuestLocation(id: UUID(), name: "はじまりの草原", emoji: "🌿", description: "穏やかな草原。初心者向けの場所。", difficulty: 1),
        QuestLocation(id: UUID(), name: "暗い森", emoji: "🌲", description: "薄暗い森の中。何かが潜んでいる…", difficulty: 2),
        QuestLocation(id: UUID(), name: "古代遺跡", emoji: "🏛️", description: "かつて栄えた文明の遺跡。宝が眠る。", difficulty: 3),
        QuestLocation(id: UUID(), name: "ドラゴンの洞窟", emoji: "🏔️", description: "恐ろしいドラゴンが住む洞窟。", difficulty: 4),
        QuestLocation(id: UUID(), name: "魔王城", emoji: "🏰", description: "魔王が支配する暗黒の城。", difficulty: 5),
    ]

    // MARK: - Data Access

    /// App Group の UserDefaults
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Hero Data

    /// 勇者データを保存する
    func saveHero(_ hero: Hero) {
        let defaults = sharedDefaults
        defaults?.set(hero.name, forKey: "\(heroDataKey)_name")
        defaults?.set(hero.heroClass.rawValue, forKey: "\(heroDataKey)_class")
        defaults?.set(hero.level, forKey: "\(heroDataKey)_level")
        defaults?.set(hero.experience, forKey: "\(heroDataKey)_experience")
        defaults?.set(hero.hp, forKey: "\(heroDataKey)_hp")
        defaults?.set(hero.maxHP, forKey: "\(heroDataKey)_maxHP")
        defaults?.set(hero.mp, forKey: "\(heroDataKey)_mp")
        defaults?.set(hero.maxMP, forKey: "\(heroDataKey)_maxMP")
        defaults?.set(hero.gold, forKey: "\(heroDataKey)_gold")
        defaults?.set(hero.attack, forKey: "\(heroDataKey)_attack")
        defaults?.set(hero.defense, forKey: "\(heroDataKey)_defense")
        defaults?.set(hero.dayCount, forKey: "\(heroDataKey)_dayCount")
    }

    /// 勇者データを読み込む
    func loadHero() -> Hero? {
        guard let defaults = sharedDefaults,
              let name = defaults.string(forKey: "\(heroDataKey)_name"),
              let classRaw = defaults.string(forKey: "\(heroDataKey)_class"),
              let heroClass = HeroClass(rawValue: classRaw) else {
            return nil
        }

        return Hero(
            id: UUID(),
            name: name,
            heroClass: heroClass,
            level: defaults.integer(forKey: "\(heroDataKey)_level"),
            experience: defaults.integer(forKey: "\(heroDataKey)_experience"),
            hp: defaults.integer(forKey: "\(heroDataKey)_hp"),
            maxHP: defaults.integer(forKey: "\(heroDataKey)_maxHP"),
            mp: defaults.integer(forKey: "\(heroDataKey)_mp"),
            maxMP: defaults.integer(forKey: "\(heroDataKey)_maxMP"),
            gold: defaults.integer(forKey: "\(heroDataKey)_gold"),
            attack: defaults.integer(forKey: "\(heroDataKey)_attack"),
            defense: defaults.integer(forKey: "\(heroDataKey)_defense"),
            dayCount: defaults.integer(forKey: "\(heroDataKey)_dayCount")
        )
    }

    // MARK: - Event Generation

    /// ランダムなクエストイベントを生成する
    func generateEvent(for location: QuestLocation, hero: Hero) -> QuestEvent {
        let eventTypes: [QuestEventType] = weightedEventTypes(for: location)
        let eventType = eventTypes.randomElement() ?? .battle

        switch eventType {
        case .battle:
            return generateBattleEvent(location: location, hero: hero)
        case .treasure:
            return generateTreasureEvent(location: location)
        case .encounter:
            return generateEncounterEvent(location: location)
        case .trap:
            return generateTrapEvent(location: location, hero: hero)
        case .rest:
            return generateRestEvent()
        case .boss:
            return generateBossEvent(location: location, hero: hero)
        case .shop:
            return generateShopEvent(hero: hero)
        }
    }

    /// レベルアップ処理
    func levelUp(_ hero: Hero) -> Hero {
        var updated = hero
        updated.level += 1
        updated.experience -= hero.expToNextLevel
        updated.maxHP += 10 + Int.random(in: 0...5)
        updated.maxMP += 5 + Int.random(in: 0...3)
        updated.hp = updated.maxHP
        updated.mp = updated.maxMP
        updated.attack += 2 + Int.random(in: 0...2)
        updated.defense += 1 + Int.random(in: 0...2)
        return updated
    }

    /// 選択肢の結果を勇者に適用する
    func applyChoice(_ choice: EventChoice, to hero: Hero) -> Hero {
        var updated = hero
        updated.hp = min(hero.maxHP, max(0, hero.hp + choice.hpEffect))
        updated.mp = min(hero.maxMP, max(0, hero.mp + choice.mpEffect))
        updated.gold = max(0, hero.gold + choice.goldEffect)
        updated.experience += max(0, choice.expEffect)
        return updated
    }

    // MARK: - Private Event Generators

    private func weightedEventTypes(for location: QuestLocation) -> [QuestEventType] {
        var types: [QuestEventType] = [
            .battle, .battle, .battle,
            .treasure, .treasure,
            .encounter,
            .rest,
            .shop,
        ]
        if location.difficulty >= 3 { types.append(.trap) }
        if location.difficulty >= 4 { types.append(.boss) }
        return types
    }

    private func generateBattleEvent(location: QuestLocation, hero: Hero) -> QuestEvent {
        let monsters = ["スライム", "ゴブリン", "オーク", "スケルトン", "ワーウルフ", "ダークナイト"]
        let monsterIndex = min(monsters.count - 1, location.difficulty - 1 + Int.random(in: 0...1))
        let monster = monsters[monsterIndex]
        let damage = location.difficulty * 5 + Int.random(in: 0...10)
        let goldReward = location.difficulty * 20 + Int.random(in: 0...30)
        let expReward = location.difficulty * 15 + Int.random(in: 0...20)

        return QuestEvent(
            id: UUID(),
            type: .battle,
            title: "\(monster)が現れた！",
            description: "\(location.name)で\(monster)に遭遇した。どうする？",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "戦う",
                    emoji: "⚔️",
                    resultDescription: "\(monster)を倒した！",
                    hpEffect: -damage,
                    mpEffect: 0,
                    goldEffect: goldReward,
                    expEffect: expReward
                ),
                EventChoice(
                    id: UUID(),
                    label: "逃げる",
                    emoji: "🏃",
                    resultDescription: "うまく逃げ切った。",
                    hpEffect: -(damage / 3),
                    mpEffect: 0,
                    goldEffect: 0,
                    expEffect: 0
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateTreasureEvent(location: QuestLocation) -> QuestEvent {
        let goldAmount = location.difficulty * 30 + Int.random(in: 10...50)

        return QuestEvent(
            id: UUID(),
            type: .treasure,
            title: "宝箱を発見！",
            description: "\(location.name)の奥に古い宝箱がある。開ける？",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "開ける",
                    emoji: "🎁",
                    resultDescription: "\(goldAmount)ゴールドを手に入れた！",
                    hpEffect: 0,
                    mpEffect: 0,
                    goldEffect: goldAmount,
                    expEffect: 10
                ),
                EventChoice(
                    id: UUID(),
                    label: "慎重に調べる",
                    emoji: "🔍",
                    resultDescription: "罠を回避しつつ中身を回収した。",
                    hpEffect: 0,
                    mpEffect: -5,
                    goldEffect: goldAmount + 20,
                    expEffect: 20
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateEncounterEvent(location: QuestLocation) -> QuestEvent {
        return QuestEvent(
            id: UUID(),
            type: .encounter,
            title: "旅の商人との出会い",
            description: "道端で疲れた商人に出会った。助けを求めている。",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "助ける",
                    emoji: "🤝",
                    resultDescription: "商人はお礼に薬草をくれた。",
                    hpEffect: 30,
                    mpEffect: 10,
                    goldEffect: 0,
                    expEffect: 15
                ),
                EventChoice(
                    id: UUID(),
                    label: "通り過ぎる",
                    emoji: "🚶",
                    resultDescription: "先を急いだ。",
                    hpEffect: 0,
                    mpEffect: 0,
                    goldEffect: 0,
                    expEffect: 0
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateTrapEvent(location: QuestLocation, hero: Hero) -> QuestEvent {
        let trapDamage = location.difficulty * 8 + Int.random(in: 5...15)

        return QuestEvent(
            id: UUID(),
            type: .trap,
            title: "罠だ！",
            description: "足元に罠が仕掛けられていた！",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "回避する",
                    emoji: "💨",
                    resultDescription: "すばやく回避した！",
                    hpEffect: -(trapDamage / 2),
                    mpEffect: 0,
                    goldEffect: 0,
                    expEffect: 10
                ),
                EventChoice(
                    id: UUID(),
                    label: "魔法で解除",
                    emoji: "✨",
                    resultDescription: "魔法で罠を無効化した。",
                    hpEffect: 0,
                    mpEffect: -20,
                    goldEffect: 0,
                    expEffect: 25
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateRestEvent() -> QuestEvent {
        return QuestEvent(
            id: UUID(),
            type: .rest,
            title: "休憩所を発見",
            description: "安全な休憩場所を見つけた。ゆっくり休めそうだ。",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "休む",
                    emoji: "😴",
                    resultDescription: "ゆっくり休息をとった。体力が回復した！",
                    hpEffect: 40,
                    mpEffect: 20,
                    goldEffect: 0,
                    expEffect: 0
                ),
                EventChoice(
                    id: UUID(),
                    label: "周囲を探索",
                    emoji: "🔎",
                    resultDescription: "周囲を探索して宝を見つけた。",
                    hpEffect: 10,
                    mpEffect: 5,
                    goldEffect: 30,
                    expEffect: 10
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateBossEvent(location: QuestLocation, hero: Hero) -> QuestEvent {
        let bosses = ["ダークドラゴン", "リッチキング", "魔王デスロード"]
        let boss = bosses.randomElement() ?? "ダークドラゴン"
        let damage = location.difficulty * 12 + Int.random(in: 10...25)
        let goldReward = location.difficulty * 50 + Int.random(in: 30...80)
        let expReward = location.difficulty * 40 + Int.random(in: 20...50)

        return QuestEvent(
            id: UUID(),
            type: .boss,
            title: "🐉 \(boss)が立ちはだかる！",
            description: "強大な敵が行く手を阻む。全力で挑め！",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "全力で戦う",
                    emoji: "🔥",
                    resultDescription: "\(boss)を討伐した！大勝利！",
                    hpEffect: -damage,
                    mpEffect: -15,
                    goldEffect: goldReward,
                    expEffect: expReward
                ),
                EventChoice(
                    id: UUID(),
                    label: "撤退する",
                    emoji: "🛡️",
                    resultDescription: "危険を察知して撤退した。",
                    hpEffect: -(damage / 4),
                    mpEffect: 0,
                    goldEffect: 0,
                    expEffect: 5
                ),
            ],
            occurredAt: Date()
        )
    }

    private func generateShopEvent(hero: Hero) -> QuestEvent {
        let healCost = 30
        let potionCost = 50

        return QuestEvent(
            id: UUID(),
            type: .shop,
            title: "旅のお店",
            description: "道沿いに小さなお店を見つけた。何か買う？",
            choices: [
                EventChoice(
                    id: UUID(),
                    label: "回復する (\(healCost)G)",
                    emoji: "💊",
                    resultDescription: "体力を回復した！",
                    hpEffect: 50,
                    mpEffect: 25,
                    goldEffect: -healCost,
                    expEffect: 0
                ),
                EventChoice(
                    id: UUID(),
                    label: "何もしない",
                    emoji: "👋",
                    resultDescription: "お店を後にした。",
                    hpEffect: 0,
                    mpEffect: 0,
                    goldEffect: 0,
                    expEffect: 0
                ),
            ],
            occurredAt: Date()
        )
    }

    // MARK: - Mock Data

    /// デモ用のクエストログを生成する
    func generateMockLog(for hero: Hero) -> [QuestLogEntry] {
        let now = Date()
        return (0..<10).map { index in
            let eventType = QuestEventType.allCases.randomElement() ?? .battle
            let hoursAgo = Double(10 - index) * 2.5
            return QuestLogEntry(
                id: UUID(),
                date: now.addingTimeInterval(-hoursAgo * 3600),
                eventType: eventType,
                message: "\(eventType.emoji) \(eventType.rawValue)イベントが発生",
                choiceLabel: "選択済み",
                hpChange: Int.random(in: -20...30),
                mpChange: Int.random(in: -10...15),
                goldChange: Int.random(in: -30...50),
                expChange: Int.random(in: 0...30)
            )
        }
    }
}
