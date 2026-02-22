import Foundation
import FoundationModels

// MARK: - PhotoAnalyzer（Foundation Models + Vision による写真分析エンジン）

@MainActor
@Observable
final class PhotoAnalyzer {
    static let shared = PhotoAnalyzer()

    private(set) var isAvailable = false
    private(set) var isAnalyzing = false
    private(set) var analysisProgress: String?

    private init() {
        checkAvailability()
    }

    // MARK: - 利用可能性チェック

    func checkAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            isAvailable = true
        case .unavailable(let reason):
            isAvailable = false
            switch reason {
            case .deviceNotEligible:
                analysisProgress = "このデバイスは Apple Intelligence に対応していません"
            case .appleIntelligenceNotEnabled:
                analysisProgress = "Apple Intelligence を有効にしてください"
            case .modelNotReady:
                analysisProgress = "モデルをダウンロード中..."
            @unknown default:
                analysisProgress = "Foundation Models を利用できません"
            }
        }
    }

    // MARK: - キャプション生成

    /// 写真の検出情報からキャプションとタグを生成
    func generateCaption(for photo: Photo) async throws -> PhotoCaption {
        guard isAvailable else {
            throw PhotoAnalyzerError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "写真を分析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let objectsText = photo.detectedObjects.joined(separator: ", ")
        let locationText = photo.location.map { "場所: \($0.name)" } ?? "場所不明"
        let ocrText = photo.detectedText.map { "テキスト: \($0)" } ?? ""

        let session = LanguageModelSession(
            instructions: """
            You are a photo album assistant. \
            Given detected objects, location, and text from a photo, \
            generate a natural Japanese caption and relevant tags. \
            The caption should be descriptive and emotional, like a diary entry. \
            Tags should be concise keywords in Japanese.
            """
        )

        let caption: PhotoCaption = try await session.respond(
            to: """
            以下の情報から写真のキャプションとタグを生成してください:

            検出されたオブジェクト: \(objectsText)
            \(locationText)
            \(ocrText)
            撮影日時: \(photo.formattedDate)
            """,
            generating: PhotoCaption.self
        )

        return caption
    }

    // MARK: - アルバムストーリー生成

    /// アルバムの写真群から旅行日記風のストーリーを生成
    func generateAlbumStory(
        albumTitle: String,
        photos: [Photo]
    ) async throws -> AlbumStory {
        guard isAvailable else {
            throw PhotoAnalyzerError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "ストーリーを生成中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let photoDescriptions = photos.map { photo in
            let objects = photo.detectedObjects.joined(separator: "・")
            let location = photo.location?.name ?? ""
            return "- \(photo.formattedDate): \(objects) \(location)"
        }.joined(separator: "\n")

        let session = LanguageModelSession(
            instructions: """
            You are a travel diary writer. \
            Given a series of photos from an album, create an engaging narrative \
            that captures the experience and emotions. \
            Write in Japanese, in a warm and personal tone. \
            Include specific details from the photo descriptions.
            """
        )

        let story: AlbumStory = try await session.respond(
            to: """
            アルバム「\(albumTitle)」の写真から旅行日記を生成してください:

            \(photoDescriptions)
            """,
            generating: AlbumStory.self
        )

        return story
    }

    // MARK: - 自然言語検索

    /// 自然言語のクエリで写真を検索（モック実装）
    func searchPhotos(
        query: String,
        in photos: [Photo]
    ) async -> [SearchResult] {
        isAnalyzing = true
        analysisProgress = "「\(query)」を検索中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        // 検索をシミュレーション
        try? await Task.sleep(for: .seconds(0.8))

        let queryLower = query.lowercased()

        return photos.compactMap { photo in
            var score: Double = 0
            var reasons: [String] = []

            // タグマッチ
            for tag in photo.tags {
                if queryLower.contains(tag) || tag.contains(queryLower) {
                    score += 0.3
                    reasons.append("タグ「\(tag)」に一致")
                }
            }

            // オブジェクトマッチ
            for obj in photo.detectedObjects {
                if queryLower.contains(obj) || obj.contains(queryLower) {
                    score += 0.25
                    reasons.append("検出オブジェクト「\(obj)」に一致")
                }
            }

            // キャプションマッチ
            if let caption = photo.caption, caption.contains(queryLower) || queryLower.split(separator: " ").contains(where: { caption.contains($0) }) {
                score += 0.2
                reasons.append("キャプションに一致")
            }

            // 場所マッチ
            if let location = photo.location, location.name.contains(queryLower) || queryLower.contains(location.name) {
                score += 0.35
                reasons.append("場所「\(location.name)」に一致")
            }

            // OCR テキストマッチ
            if let text = photo.detectedText, text.lowercased().contains(queryLower) {
                score += 0.2
                reasons.append("テキスト認識に一致")
            }

            guard score > 0 else { return nil }

            return SearchResult(
                photo: photo,
                relevanceScore: min(score, 1.0),
                matchReason: reasons.joined(separator: "、")
            )
        }
        .sorted { $0.relevanceScore > $1.relevanceScore }
    }

    // MARK: - モデルのプリウォーム

    func prewarmModel() async {
        do {
            let session = LanguageModelSession()
            try await session.prewarm()
        } catch {
            // プリウォーム失敗は無視
        }
    }
}

// MARK: - PhotoAnalyzerError

enum PhotoAnalyzerError: Error, LocalizedError {
    case modelUnavailable
    case analysisFailure
    case noPhotos

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Foundation Models が利用できません。Apple Intelligence 対応デバイスが必要です。"
        case .analysisFailure:
            "写真の分析に失敗しました。もう一度お試しください。"
        case .noPhotos:
            "分析する写真がありません。"
        }
    }
}
