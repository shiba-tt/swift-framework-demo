import Foundation

// MARK: - NoteSummary

struct NoteSummary: Sendable {
    var summaryText: String
    var actionItems: [ActionItem]
    var relatedTopics: [String]
    var confidence: Double

    var completedActionCount: Int {
        actionItems.filter(\.isCompleted).count
    }

    var pendingActionCount: Int {
        actionItems.filter { !$0.isCompleted }.count
    }
}

// MARK: - ActionItem

struct ActionItem: Identifiable, Sendable {
    let id: UUID
    var text: String
    var assignee: String?
    var dueDate: Date?
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        text: String,
        assignee: String? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.text = text
        self.assignee = assignee
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }

    var formattedDueDate: String? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: dueDate)
    }
}

// MARK: - DetectedShape

struct DetectedShape: Identifiable, Sendable {
    let id: UUID
    var shapeType: ShapeType
    var associatedText: String?

    init(id: UUID = UUID(), shapeType: ShapeType, associatedText: String? = nil) {
        self.id = id
        self.shapeType = shapeType
        self.associatedText = associatedText
    }
}

// MARK: - ShapeType

enum ShapeType: String, CaseIterable, Sendable {
    case arrow = "矢印"
    case box = "囲み枠"
    case underline = "下線"
    case circle = "丸"
    case star = "星"

    var systemImage: String {
        switch self {
        case .arrow: "arrow.right"
        case .box: "rectangle"
        case .underline: "underline"
        case .circle: "circle"
        case .star: "star"
        }
    }
}

// MARK: - OCR Result

struct OCRResult: Sendable {
    var recognizedText: String
    var detectedShapes: [DetectedShape]
    var layoutType: NoteLayoutType
    var confidence: Double
    var processingTime: Double
}
