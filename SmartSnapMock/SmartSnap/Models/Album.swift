import Foundation
import FoundationModels

// MARK: - Album（自動分類されたアルバム）

struct Album: Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let coverPhotoID: UUID?
    let photoIDs: [UUID]
    let category: AlbumCategory
    let dateRange: String
    var story: String?

    init(
        title: String,
        subtitle: String,
        coverPhotoID: UUID? = nil,
        photoIDs: [UUID],
        category: AlbumCategory,
        dateRange: String,
        story: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.coverPhotoID = coverPhotoID
        self.photoIDs = photoIDs
        self.category = category
        self.dateRange = dateRange
        self.story = story
    }

    var photoCount: Int { photoIDs.count }
}

// MARK: - AlbumCategory

enum AlbumCategory: String, Sendable, CaseIterable {
    case travel = "旅行"
    case family = "家族"
    case work = "仕事"
    case nature = "自然"
    case food = "グルメ"
    case pet = "ペット"
    case event = "イベント"

    var emoji: String {
        switch self {
        case .travel:  "✈️"
        case .family:  "👨‍👩‍👧‍👦"
        case .work:    "💼"
        case .nature:  "🌿"
        case .food:    "🍽️"
        case .pet:     "🐾"
        case .event:   "🎉"
        }
    }

    var systemImage: String {
        switch self {
        case .travel:  "airplane"
        case .family:  "person.3.fill"
        case .work:    "briefcase.fill"
        case .nature:  "leaf.fill"
        case .food:    "fork.knife"
        case .pet:     "pawprint.fill"
        case .event:   "party.popper.fill"
        }
    }
}

// MARK: - PhotoCaption（Foundation Models による構造化キャプション）

@Generable
struct PhotoCaption {
    @Guide(description: "A concise and descriptive caption for the photo in Japanese")
    var caption: String

    @Guide(description: "List of relevant tags for the photo in Japanese (3-5 tags)")
    var tags: [String]

    @Guide(description: "The category that best describes this photo")
    var category: GeneratedCategory
}

// MARK: - GeneratedCategory

@Generable
enum GeneratedCategory: String, Sendable, CaseIterable {
    case travel = "travel"
    case family = "family"
    case work = "work"
    case nature = "nature"
    case food = "food"
    case pet = "pet"
    case event = "event"

    var albumCategory: AlbumCategory {
        switch self {
        case .travel:  .travel
        case .family:  .family
        case .work:    .work
        case .nature:  .nature
        case .food:    .food
        case .pet:     .pet
        case .event:   .event
        }
    }
}

// MARK: - AlbumStory（Foundation Models による旅行日記テキスト）

@Generable
struct AlbumStory {
    @Guide(description: "A short, engaging story title in Japanese")
    var title: String

    @Guide(description: "A narrative story about the album in Japanese (3-5 sentences)")
    var narrative: String

    @Guide(description: "Key highlights or memorable moments from the album in Japanese (2-4 items)")
    var highlights: [String]
}

// MARK: - SearchResult（自然言語検索の結果）

struct SearchResult: Identifiable, Sendable {
    let id = UUID()
    let photo: Photo
    let relevanceScore: Double
    let matchReason: String
}
