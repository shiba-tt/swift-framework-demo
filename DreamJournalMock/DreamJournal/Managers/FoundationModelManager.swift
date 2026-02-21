import Foundation
import FoundationModels

// MARK: - FoundationModelManager（Foundation Models によるオンデバイス AI 分析）

@MainActor
@Observable
final class FoundationModelManager {
    static let shared = FoundationModelManager()

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

    // MARK: - 夢の分析

    /// 音声文字起こしテキストから夢を構造化分析する
    func analyzeDream(transcription: String) async throws -> DreamAnalysis {
        guard isAvailable else {
            throw FoundationModelError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "夢を分析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let session = LanguageModelSession(
            instructions: """
            You are a dream analysis assistant. \
            Analyze the user's dream description and extract structured information. \
            Identify themes, emotional tone, and symbolic elements. \
            Rewrite the dream as a coherent short narrative. \
            All output text must be in Japanese. \
            Keep the title short and symbolic (under 10 characters). \
            Keep the narrative concise (under 100 characters). \
            DO NOT include personal opinions or psychological diagnoses.
            """
        )

        let analysis: DreamAnalysis = try await session.respond(
            to: "以下の夢の内容を分析してください:\n\n\(transcription)",
            generating: DreamAnalysis.self
        )

        return analysis
    }

    // MARK: - ストリーミング分析

    /// ストリーミングで段階的に分析結果を取得する
    func analyzeDreamStreaming(
        transcription: String,
        onPartialUpdate: @escaping (PartiallyGenerated<DreamAnalysis>) -> Void
    ) async throws -> DreamAnalysis {
        guard isAvailable else {
            throw FoundationModelError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "夢を分析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let session = LanguageModelSession(
            instructions: """
            You are a dream analysis assistant. \
            Analyze the user's dream description and extract structured information. \
            All output text must be in Japanese. \
            Keep the title short and symbolic (under 10 characters). \
            Keep the narrative concise (under 100 characters). \
            DO NOT include personal opinions or psychological diagnoses.
            """
        )

        let stream = session.streamResponse(
            to: "以下の夢の内容を分析してください:\n\n\(transcription)",
            generating: DreamAnalysis.self
        )

        var finalResult: DreamAnalysis?

        for try await partial in stream {
            onPartialUpdate(partial)

            if let title = partial.title {
                analysisProgress = "分析中: \(title)..."
            }
        }

        // ストリーム完了後、最終結果を一括取得で再生成
        finalResult = try await session.respond(
            to: "以下の夢の内容を分析してください:\n\n\(transcription)",
            generating: DreamAnalysis.self
        )

        guard let result = finalResult else {
            throw FoundationModelError.analysisFailure
        }

        return result
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

// MARK: - FoundationModelError

enum FoundationModelError: Error, LocalizedError {
    case modelUnavailable
    case analysisFailure
    case contextOverflow

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Foundation Models が利用できません。Apple Intelligence 対応デバイスが必要です。"
        case .analysisFailure:
            "夢の分析に失敗しました。もう一度お試しください。"
        case .contextOverflow:
            "入力テキストが長すぎます。短くしてお試しください。"
        }
    }
}
