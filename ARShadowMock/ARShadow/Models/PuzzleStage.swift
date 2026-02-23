import Foundation
import SwiftUI

// MARK: - PuzzleStage

struct PuzzleStage: Identifiable, Sendable {
    let id: UUID
    var name: String
    var targetShape: ShadowShape
    var difficulty: Difficulty
    var description: String
    var timeLimit: TimeInterval?
    var requiredAccuracy: Double
    var allowedObjects: Int
    var isUnlocked: Bool
    var bestScore: Int?

    init(
        id: UUID = UUID(),
        name: String,
        targetShape: ShadowShape,
        difficulty: Difficulty = .normal,
        description: String = "",
        timeLimit: TimeInterval? = nil,
        requiredAccuracy: Double = 0.7,
        allowedObjects: Int = 3,
        isUnlocked: Bool = false,
        bestScore: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.targetShape = targetShape
        self.difficulty = difficulty
        self.description = description
        self.timeLimit = timeLimit
        self.requiredAccuracy = requiredAccuracy
        self.allowedObjects = allowedObjects
        self.isUnlocked = isUnlocked
        self.bestScore = bestScore
    }

    var starRating: Int {
        guard let score = bestScore else { return 0 }
        if score >= 95 { return 3 }
        if score >= 80 { return 2 }
        if score >= 60 { return 1 }
        return 0
    }
}

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Sendable {
    case easy = "かんたん"
    case normal = "ふつう"
    case hard = "むずかしい"
    case expert = "エキスパート"

    var color: Color {
        switch self {
        case .easy: .green
        case .normal: .blue
        case .hard: .orange
        case .expert: .red
        }
    }

    var systemImage: String {
        switch self {
        case .easy: "star"
        case .normal: "star.leadinghalf.filled"
        case .hard: "star.fill"
        case .expert: "star.circle.fill"
        }
    }
}

// MARK: - ShadowShape

enum ShadowShape: String, CaseIterable, Sendable {
    case dog = "犬"
    case bird = "鳥"
    case rabbit = "うさぎ"
    case cat = "猫"
    case butterfly = "蝶"
    case tree = "木"
    case house = "家"
    case star = "星"
    case heart = "ハート"
    case dragon = "龍"

    var systemImage: String {
        switch self {
        case .dog: "dog.fill"
        case .bird: "bird.fill"
        case .rabbit: "hare.fill"
        case .cat: "cat.fill"
        case .butterfly: "ladybug.fill"
        case .tree: "tree.fill"
        case .house: "house.fill"
        case .star: "star.fill"
        case .heart: "heart.fill"
        case .dragon: "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .dog: .brown
        case .bird: .cyan
        case .rabbit: .pink
        case .cat: .orange
        case .butterfly: .purple
        case .tree: .green
        case .house: .red
        case .star: .yellow
        case .heart: .red
        case .dragon: .orange
        }
    }
}

// MARK: - VirtualObject

struct VirtualObject: Identifiable, Sendable {
    let id: UUID
    var shape: ObjectShape
    var position: CGPoint
    var rotation: Double
    var scale: Double

    init(
        id: UUID = UUID(),
        shape: ObjectShape,
        position: CGPoint = .zero,
        rotation: Double = 0,
        scale: Double = 1.0
    ) {
        self.id = id
        self.shape = shape
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}

// MARK: - ObjectShape

enum ObjectShape: String, CaseIterable, Sendable {
    case cube = "立方体"
    case sphere = "球体"
    case cylinder = "円柱"
    case cone = "円錐"
    case pyramid = "ピラミッド"

    var systemImage: String {
        switch self {
        case .cube: "cube.fill"
        case .sphere: "circle.fill"
        case .cylinder: "cylinder.fill"
        case .cone: "triangle.fill"
        case .pyramid: "pyramid.fill"
        }
    }
}

// MARK: - LightSource

struct LightSource: Identifiable, Sendable {
    let id: UUID
    var position: CGPoint
    var intensity: Double
    var color: Color

    init(
        id: UUID = UUID(),
        position: CGPoint = CGPoint(x: 0.5, y: 0.2),
        intensity: Double = 1.0,
        color: Color = .white
    ) {
        self.id = id
        self.position = position
        self.intensity = intensity
        self.color = color
    }
}

// MARK: - GameResult

struct GameResult: Identifiable, Sendable {
    let id: UUID
    var stage: PuzzleStage
    var accuracy: Double
    var completedDate: Date
    var timeElapsed: TimeInterval

    init(
        id: UUID = UUID(),
        stage: PuzzleStage,
        accuracy: Double,
        completedDate: Date = Date(),
        timeElapsed: TimeInterval
    ) {
        self.id = id
        self.stage = stage
        self.accuracy = accuracy
        self.completedDate = completedDate
        self.timeElapsed = timeElapsed
    }

    var score: Int {
        Int(accuracy * 100)
    }
}

// MARK: - Sample Data

extension PuzzleStage {
    static let samples: [PuzzleStage] = [
        PuzzleStage(
            name: "はじめての影絵",
            targetShape: .dog,
            difficulty: .easy,
            description: "光源を動かして犬の影を作ろう！",
            timeLimit: 120,
            requiredAccuracy: 0.5,
            allowedObjects: 1,
            isUnlocked: true,
            bestScore: 92
        ),
        PuzzleStage(
            name: "空飛ぶ鳥",
            targetShape: .bird,
            difficulty: .easy,
            description: "2つの物体を組み合わせて鳥の形を作ろう",
            timeLimit: 150,
            requiredAccuracy: 0.55,
            allowedObjects: 2,
            isUnlocked: true,
            bestScore: 78
        ),
        PuzzleStage(
            name: "月夜のうさぎ",
            targetShape: .rabbit,
            difficulty: .normal,
            description: "うさぎの影絵を完成させよう",
            timeLimit: 120,
            requiredAccuracy: 0.6,
            allowedObjects: 2,
            isUnlocked: true,
            bestScore: 65
        ),
        PuzzleStage(
            name: "気ままな猫",
            targetShape: .cat,
            difficulty: .normal,
            description: "猫のシルエットを影で再現しよう",
            timeLimit: 100,
            requiredAccuracy: 0.65,
            allowedObjects: 3,
            isUnlocked: true
        ),
        PuzzleStage(
            name: "舞う蝶",
            targetShape: .butterfly,
            difficulty: .normal,
            description: "左右対称の蝶の影を作ろう",
            timeLimit: 90,
            requiredAccuracy: 0.7,
            allowedObjects: 3,
            isUnlocked: false
        ),
        PuzzleStage(
            name: "大きな木",
            targetShape: .tree,
            difficulty: .hard,
            description: "枝が広がる木の影を表現しよう",
            timeLimit: 80,
            requiredAccuracy: 0.75,
            allowedObjects: 4,
            isUnlocked: false
        ),
        PuzzleStage(
            name: "温かい家",
            targetShape: .house,
            difficulty: .hard,
            description: "屋根と煙突のある家の影を作ろう",
            timeLimit: 70,
            requiredAccuracy: 0.8,
            allowedObjects: 4,
            isUnlocked: false
        ),
        PuzzleStage(
            name: "輝く星",
            targetShape: .star,
            difficulty: .hard,
            description: "5つの頂点を持つ星の影を作ろう",
            timeLimit: 60,
            requiredAccuracy: 0.8,
            allowedObjects: 5,
            isUnlocked: false
        ),
        PuzzleStage(
            name: "愛のハート",
            targetShape: .heart,
            difficulty: .expert,
            description: "曲線のあるハートの影を表現しよう",
            timeLimit: 50,
            requiredAccuracy: 0.85,
            allowedObjects: 5,
            isUnlocked: false
        ),
        PuzzleStage(
            name: "伝説の龍",
            targetShape: .dragon,
            difficulty: .expert,
            description: "究極の影絵パズル。龍の姿を影で描け！",
            timeLimit: 45,
            requiredAccuracy: 0.9,
            allowedObjects: 6,
            isUnlocked: false
        ),
    ]
}
