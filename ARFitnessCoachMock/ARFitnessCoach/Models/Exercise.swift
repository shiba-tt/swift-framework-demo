import Foundation
import SwiftUI

// MARK: - Exercise

struct Exercise: Identifiable, Sendable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var difficulty: ExerciseDifficulty
    var description: String
    var targetReps: Int
    var targetSets: Int
    var trackedJoints: [JointName]
    var caloriesPerRep: Double
    var guideTips: [String]

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        difficulty: ExerciseDifficulty = .intermediate,
        description: String = "",
        targetReps: Int = 12,
        targetSets: Int = 3,
        trackedJoints: [JointName] = [],
        caloriesPerRep: Double = 0.5,
        guideTips: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.difficulty = difficulty
        self.description = description
        self.targetReps = targetReps
        self.targetSets = targetSets
        self.trackedJoints = trackedJoints
        self.caloriesPerRep = caloriesPerRep
        self.guideTips = guideTips
    }
}

// MARK: - ExerciseCategory

enum ExerciseCategory: String, CaseIterable, Sendable {
    case squat = "スクワット"
    case pushup = "腕立て伏せ"
    case lunge = "ランジ"
    case plank = "プランク"
    case deadlift = "デッドリフト"
    case yoga = "ヨガ"
    case stretch = "ストレッチ"

    var systemImage: String {
        switch self {
        case .squat: "figure.strengthtraining.traditional"
        case .pushup: "figure.core.training"
        case .lunge: "figure.walk"
        case .plank: "figure.pilates"
        case .deadlift: "figure.strengthtraining.functional"
        case .yoga: "figure.yoga"
        case .stretch: "figure.flexibility"
        }
    }

    var color: Color {
        switch self {
        case .squat: .blue
        case .pushup: .red
        case .lunge: .green
        case .plank: .orange
        case .deadlift: .purple
        case .yoga: .teal
        case .stretch: .cyan
        }
    }
}

// MARK: - ExerciseDifficulty

enum ExerciseDifficulty: String, CaseIterable, Sendable {
    case beginner = "初級"
    case intermediate = "中級"
    case advanced = "上級"
    case expert = "エキスパート"

    var color: Color {
        switch self {
        case .beginner: .green
        case .intermediate: .blue
        case .advanced: .orange
        case .expert: .red
        }
    }

    var systemImage: String {
        switch self {
        case .beginner: "1.circle.fill"
        case .intermediate: "2.circle.fill"
        case .advanced: "3.circle.fill"
        case .expert: "star.circle.fill"
        }
    }
}

// MARK: - JointName

enum JointName: String, CaseIterable, Sendable {
    case head = "頭"
    case neck = "首"
    case leftShoulder = "左肩"
    case rightShoulder = "右肩"
    case leftElbow = "左肘"
    case rightElbow = "右肘"
    case leftWrist = "左手首"
    case rightWrist = "右手首"
    case leftHip = "左腰"
    case rightHip = "右腰"
    case leftKnee = "左膝"
    case rightKnee = "右膝"
    case leftAnkle = "左足首"
    case rightAnkle = "右足首"
    case spine = "背骨"

    var color: Color {
        switch self {
        case .head, .neck: .purple
        case .leftShoulder, .rightShoulder: .blue
        case .leftElbow, .rightElbow: .cyan
        case .leftWrist, .rightWrist: .teal
        case .leftHip, .rightHip: .orange
        case .leftKnee, .rightKnee: .red
        case .leftAnkle, .rightAnkle: .pink
        case .spine: .yellow
        }
    }
}

// MARK: - JointFeedback

struct JointFeedback: Identifiable, Sendable {
    let id: UUID
    var joint: JointName
    var status: JointStatus
    var angle: Double
    var idealAngle: Double
    var message: String

    init(
        id: UUID = UUID(),
        joint: JointName,
        status: JointStatus,
        angle: Double,
        idealAngle: Double,
        message: String = ""
    ) {
        self.id = id
        self.joint = joint
        self.status = status
        self.angle = angle
        self.idealAngle = idealAngle
        self.message = message
    }

    var deviation: Double {
        abs(angle - idealAngle)
    }
}

// MARK: - JointStatus

enum JointStatus: String, Sendable {
    case correct = "OK"
    case warning = "注意"
    case incorrect = "NG"

    var color: Color {
        switch self {
        case .correct: .green
        case .warning: .orange
        case .incorrect: .red
        }
    }

    var systemImage: String {
        switch self {
        case .correct: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .incorrect: "xmark.circle.fill"
        }
    }
}

// MARK: - WorkoutSession

struct WorkoutSession: Identifiable, Sendable {
    let id: UUID
    var exercise: Exercise
    var startDate: Date
    var endDate: Date?
    var completedReps: Int
    var completedSets: Int
    var averageFormScore: Double
    var caloriesBurned: Double
    var peakHeartRate: Int?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        startDate: Date = Date(),
        endDate: Date? = nil,
        completedReps: Int = 0,
        completedSets: Int = 0,
        averageFormScore: Double = 0,
        caloriesBurned: Double = 0,
        peakHeartRate: Int? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.startDate = startDate
        self.endDate = endDate
        self.completedReps = completedReps
        self.completedSets = completedSets
        self.averageFormScore = averageFormScore
        self.caloriesBurned = caloriesBurned
        self.peakHeartRate = peakHeartRate
    }

    var duration: TimeInterval {
        (endDate ?? Date()).timeIntervalSince(startDate)
    }

    var formGrade: String {
        if averageFormScore >= 90 { return "S" }
        if averageFormScore >= 80 { return "A" }
        if averageFormScore >= 70 { return "B" }
        if averageFormScore >= 60 { return "C" }
        return "D"
    }

    var formGradeColor: Color {
        if averageFormScore >= 90 { return .yellow }
        if averageFormScore >= 80 { return .green }
        if averageFormScore >= 70 { return .blue }
        if averageFormScore >= 60 { return .orange }
        return .red
    }
}

// MARK: - Sample Data

extension Exercise {
    static let samples: [Exercise] = [
        Exercise(
            name: "ベーシックスクワット",
            category: .squat,
            difficulty: .beginner,
            description: "基本のスクワット。膝がつま先より前に出ないように注意。",
            targetReps: 15,
            targetSets: 3,
            trackedJoints: [.leftKnee, .rightKnee, .leftHip, .rightHip, .spine],
            caloriesPerRep: 0.4,
            guideTips: ["足を肩幅に開く", "膝がつま先より前に出ないように", "背筋を伸ばす", "太ももが床と平行になるまで下げる"]
        ),
        Exercise(
            name: "ワイドスクワット",
            category: .squat,
            difficulty: .intermediate,
            description: "足幅を広げたスクワット。内ももの筋肉を重点的に鍛える。",
            targetReps: 12,
            targetSets: 3,
            trackedJoints: [.leftKnee, .rightKnee, .leftHip, .rightHip, .leftAnkle, .rightAnkle, .spine],
            caloriesPerRep: 0.5,
            guideTips: ["足を肩幅の1.5倍に開く", "つま先を45度外に向ける", "膝はつま先と同じ方向に"]
        ),
        Exercise(
            name: "スタンダードプッシュアップ",
            category: .pushup,
            difficulty: .intermediate,
            description: "標準的な腕立て伏せ。胸・肩・三頭筋を鍛える。",
            targetReps: 10,
            targetSets: 3,
            trackedJoints: [.leftShoulder, .rightShoulder, .leftElbow, .rightElbow, .leftWrist, .rightWrist, .spine],
            caloriesPerRep: 0.6,
            guideTips: ["手は肩幅より少し広めに", "体を一直線に保つ", "胸が床に近づくまで下げる", "肘を45度に開く"]
        ),
        Exercise(
            name: "フォワードランジ",
            category: .lunge,
            difficulty: .beginner,
            description: "前に踏み出すランジ。下半身全体をバランスよく鍛える。",
            targetReps: 10,
            targetSets: 3,
            trackedJoints: [.leftKnee, .rightKnee, .leftHip, .rightHip, .leftAnkle, .rightAnkle, .spine],
            caloriesPerRep: 0.5,
            guideTips: ["大きく一歩前に踏み出す", "後ろ膝が床に近づくまで下げる", "前膝は90度を保つ", "上体はまっすぐ"]
        ),
        Exercise(
            name: "プランクホールド",
            category: .plank,
            difficulty: .beginner,
            description: "体幹トレーニングの基本。腹筋・背筋を同時に鍛える。",
            targetReps: 1,
            targetSets: 3,
            trackedJoints: [.leftShoulder, .rightShoulder, .leftHip, .rightHip, .leftAnkle, .rightAnkle, .spine],
            caloriesPerRep: 5.0,
            guideTips: ["肩の真下に肘を置く", "体を一直線に保つ", "腰が下がらないように", "お腹に力を入れる"]
        ),
        Exercise(
            name: "ルーマニアンデッドリフト",
            category: .deadlift,
            difficulty: .advanced,
            description: "ハムストリングスと臀部を重点的に鍛えるデッドリフト。",
            targetReps: 10,
            targetSets: 3,
            trackedJoints: [.leftKnee, .rightKnee, .leftHip, .rightHip, .spine, .leftShoulder, .rightShoulder],
            caloriesPerRep: 0.7,
            guideTips: ["膝を軽く曲げる", "背中をまっすぐに保つ", "腰から折り曲げるように", "ハムストリングの伸びを感じる"]
        ),
        Exercise(
            name: "ウォーリア2ポーズ",
            category: .yoga,
            difficulty: .intermediate,
            description: "戦士のポーズ2。下半身の強化とバランス感覚の向上。",
            targetReps: 1,
            targetSets: 2,
            trackedJoints: [.leftShoulder, .rightShoulder, .leftKnee, .rightKnee, .leftHip, .rightHip, .leftAnkle, .rightAnkle],
            caloriesPerRep: 3.0,
            guideTips: ["足を大きく開く", "前膝を90度に曲げる", "両腕を肩の高さで広げる", "視線は前方の指先へ"]
        ),
        Exercise(
            name: "全身ストレッチ",
            category: .stretch,
            difficulty: .beginner,
            description: "ウォームアップ・クールダウン用の全身ストレッチ。",
            targetReps: 1,
            targetSets: 1,
            trackedJoints: [.leftShoulder, .rightShoulder, .leftHip, .rightHip, .spine, .neck],
            caloriesPerRep: 2.0,
            guideTips: ["ゆっくり呼吸しながら行う", "痛みを感じたら無理をしない", "各ポーズ15秒キープ"]
        ),
    ]
}

extension WorkoutSession {
    static let samples: [WorkoutSession] = [
        WorkoutSession(
            exercise: Exercise.samples[0],
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(1200),
            completedReps: 45,
            completedSets: 3,
            averageFormScore: 87,
            caloriesBurned: 18,
            peakHeartRate: 135
        ),
        WorkoutSession(
            exercise: Exercise.samples[2],
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!.addingTimeInterval(900),
            completedReps: 30,
            completedSets: 3,
            averageFormScore: 72,
            caloriesBurned: 18,
            peakHeartRate: 142
        ),
        WorkoutSession(
            exercise: Exercise.samples[3],
            startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!.addingTimeInterval(1500),
            completedReps: 30,
            completedSets: 3,
            averageFormScore: 91,
            caloriesBurned: 15,
            peakHeartRate: 128
        ),
    ]
}
