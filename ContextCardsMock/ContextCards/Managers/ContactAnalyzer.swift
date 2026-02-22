import Foundation
import FoundationModels

// MARK: - ContactAnalyzer（Foundation Models による名刺分析）

@MainActor
@Observable
final class ContactAnalyzer {
    static let shared = ContactAnalyzer()

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

    // MARK: - 名刺分析

    /// OCR テキストから名刺情報を構造化分析する
    func analyzeBusinessCard(ocrText: String) async throws -> BusinessContactAnalysis {
        guard isAvailable else {
            throw ContactAnalyzerError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "名刺を分析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let session = LanguageModelSession(
            instructions: """
            You are a professional networking assistant. \
            Given OCR text from a business card, extract the contact information \
            and generate helpful networking suggestions. \
            Generate conversation starters relevant to the person's industry and role. \
            Write the follow-up email draft in a warm but professional tone. \
            All output text for conversationStarters and followUpDraft must be in Japanese. \
            DO NOT fabricate information not present in the OCR text for name, company, and title.
            """
        )

        let analysis: BusinessContactAnalysis = try await session.respond(
            to: "以下の名刺 OCR テキストを分析してください:\n\n\(ocrText)",
            generating: BusinessContactAnalysis.self
        )

        return analysis
    }

    // MARK: - ストリーミング分析

    /// ストリーミングで名刺情報を段階的に分析する
    func analyzeBusinessCardStreaming(
        ocrText: String,
        onPartialUpdate: @escaping (PartiallyGenerated<BusinessContactAnalysis>) -> Void
    ) async throws -> BusinessContactAnalysis {
        guard isAvailable else {
            throw ContactAnalyzerError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "名刺を分析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let session = LanguageModelSession(
            instructions: """
            You are a professional networking assistant. \
            Given OCR text from a business card, extract the contact information \
            and generate helpful networking suggestions. \
            Generate conversation starters relevant to the person's industry and role. \
            Write the follow-up email draft in a warm but professional tone. \
            All output text for conversationStarters and followUpDraft must be in Japanese. \
            DO NOT fabricate information not present in the OCR text for name, company, and title.
            """
        )

        let stream = session.streamResponse(
            to: "以下の名刺 OCR テキストを分析してください:\n\n\(ocrText)",
            generating: BusinessContactAnalysis.self
        )

        for try await partial in stream {
            onPartialUpdate(partial)

            if let name = partial.name {
                analysisProgress = "分析中: \(name)..."
            }
        }

        // 最終結果を一括取得
        let analysis: BusinessContactAnalysis = try await session.respond(
            to: "以下の名刺 OCR テキストを分析してください:\n\n\(ocrText)",
            generating: BusinessContactAnalysis.self
        )

        return analysis
    }

    // MARK: - フォローアップメール再生成

    /// コンテキストを追加してフォローアップメールを再生成する
    func regenerateFollowUp(
        contact: BusinessContactAnalysis,
        meetingContext: String
    ) async throws -> String {
        guard isAvailable else {
            throw ContactAnalyzerError.modelUnavailable
        }

        isAnalyzing = true
        analysisProgress = "メールを再生成中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        let session = LanguageModelSession(
            instructions: """
            You are a professional networking assistant. \
            Generate a follow-up email draft in Japanese based on the contact information \
            and the context of where you met this person. \
            Keep it warm, professional, and concise (within 200 characters). \
            DO NOT include a subject line.
            """
        )

        let prompt = """
        名前: \(contact.name)
        会社: \(contact.company)
        役職: \(contact.title)
        出会った場面: \(meetingContext)

        この情報をもとにフォローアップメールの本文を作成してください。
        """

        let response = try await session.respond(to: prompt)
        return response.content
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

// MARK: - ContactAnalyzerError

enum ContactAnalyzerError: Error, LocalizedError {
    case modelUnavailable
    case analysisFailed
    case invalidOCRText

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Foundation Models が利用できません。Apple Intelligence 対応デバイスが必要です。"
        case .analysisFailed:
            "名刺の分析に失敗しました。もう一度お試しください。"
        case .invalidOCRText:
            "名刺のテキストを読み取れませんでした。撮影し直してください。"
        }
    }
}
