import Foundation

// MARK: - FoundationModelManager

/// Foundation Models フレームワークによるオンデバイス LLM を利用して
/// 音声メモのテキストを構造化データに変換するマネージャー。
/// 実デバイスでは FoundationModels の LanguageModelSession を使い、
/// モック環境ではサンプルデータを返す。

@MainActor
@Observable
final class FoundationModelManager {
    static let shared = FoundationModelManager()

    // MARK: - State

    private(set) var isAvailable = false
    private(set) var isAnalyzing = false
    private(set) var analysisProgress: String?

    private init() {
        checkAvailability()
    }

    // MARK: - Availability

    private func checkAvailability() {
        // 実環境では SystemLanguageModel.default.availability をチェック
        // モック環境では常に利用可能とする
        isAvailable = true
    }

    // MARK: - Analyze Memo

    /// 文字起こしテキストを構造化データに変換する
    func analyzeMemo(transcription: String) async throws -> MemoStructure {
        isAnalyzing = true
        analysisProgress = "テキストを解析中..."
        defer {
            isAnalyzing = false
            analysisProgress = nil
        }

        // 実環境では以下のように FoundationModels を呼び出す:
        //
        // let session = LanguageModelSession(instructions: """
        //     あなたは音声メモの構造化アシスタントです。
        //     ユーザーの音声メモのテキストを分析し、構造化データに変換してください。
        //     タイトルは簡潔に、要約は100文字以内にしてください。
        //     アクションアイテムがある場合は担当者と優先度を推定してください。
        //     """)
        // let result: MemoStructure = try await session.respond(
        //     to: transcription,
        //     generating: MemoStructure.self
        // )

        // モック: テキスト内容に基づいてカテゴリを推定
        analysisProgress = "カテゴリを判定中..."
        try await Task.sleep(for: .milliseconds(600))

        analysisProgress = "キーポイントを抽出中..."
        try await Task.sleep(for: .milliseconds(500))

        analysisProgress = "アクションアイテムを生成中..."
        try await Task.sleep(for: .milliseconds(400))

        analysisProgress = "要約を生成中..."
        try await Task.sleep(for: .milliseconds(300))

        return generateMockStructure(from: transcription)
    }

    // MARK: - Mock Generation

    private func generateMockStructure(from transcription: String) -> MemoStructure {
        let category = inferCategory(from: transcription)

        switch category {
        case .meeting:
            return MemoStructure(
                title: "チーム定例ミーティング",
                category: category,
                keyPoints: [
                    "Q3の売上目標を達成するための施策を議論",
                    "新機能のリリーススケジュールを確認",
                    "カスタマーサポートの人員増強を検討"
                ],
                actionItems: [
                    ActionItem(content: "マーケティング施策の企画書を作成", assignee: "田中", priority: .high),
                    ActionItem(content: "リリーススケジュールのガントチャートを更新", assignee: "鈴木", priority: .medium),
                    ActionItem(content: "サポートチームの採用計画をまとめる", assignee: "佐藤", priority: .medium)
                ],
                summary: "Q3目標達成に向けた施策と新機能リリース、サポート体制について議論。各担当者にアクションアイテムを割り振り。"
            )

        case .shopping:
            return MemoStructure(
                title: "今週の買い物リスト",
                category: category,
                keyPoints: [
                    "牛乳と卵が切れている",
                    "週末のパーティー用の食材が必要",
                    "洗剤のストックも確認"
                ],
                actionItems: [
                    ActionItem(content: "牛乳・卵・パンを購入", assignee: "", priority: .high),
                    ActionItem(content: "パーティー用のチーズとワインを購入", assignee: "", priority: .medium),
                    ActionItem(content: "洗濯洗剤を補充", assignee: "", priority: .low)
                ],
                summary: "日常の食料品と週末パーティーの準備品、日用品の買い物リスト。"
            )

        case .todo:
            return MemoStructure(
                title: "今週のやることリスト",
                category: category,
                keyPoints: [
                    "プレゼン資料の完成が最優先",
                    "歯医者の予約を忘れずに",
                    "確定申告の書類準備"
                ],
                actionItems: [
                    ActionItem(content: "金曜日のプレゼン資料を完成させる", assignee: "", priority: .high),
                    ActionItem(content: "歯医者の予約を取る", assignee: "", priority: .medium),
                    ActionItem(content: "確定申告の必要書類を整理", assignee: "", priority: .medium),
                    ActionItem(content: "部屋の掃除をする", assignee: "", priority: .low)
                ],
                summary: "今週中に対応すべきタスク一覧。プレゼン準備を最優先に、各種予約・手続きも並行して進める。"
            )

        case .idea:
            return MemoStructure(
                title: "新しいアプリのアイデア",
                category: category,
                keyPoints: [
                    "散歩中に思いついた位置情報連動メモアプリ",
                    "場所に紐づいた思い出を AR で表示",
                    "友人とスポットを共有できるソーシャル機能"
                ],
                actionItems: [
                    ActionItem(content: "類似アプリの市場調査を実施", assignee: "", priority: .high),
                    ActionItem(content: "プロトタイプのワイヤーフレームを作成", assignee: "", priority: .medium)
                ],
                summary: "位置情報×AR×ソーシャルの新しいメモアプリの構想。散歩中のひらめきを起点に、体験設計を検討。"
            )

        case .diary:
            return MemoStructure(
                title: "今日のふりかえり",
                category: category,
                keyPoints: [
                    "朝のジョギングで気分がリフレッシュ",
                    "午後のミーティングが予想以上に長引いた",
                    "夕食に新しいレシピを試してうまくいった"
                ],
                actionItems: [],
                summary: "充実した一日。朝の運動習慣を継続しつつ、午後の時間管理を改善したい。新レシピは家族にも好評。"
            )

        case .other:
            return MemoStructure(
                title: extractFirstLine(from: transcription),
                category: category,
                keyPoints: [
                    "音声メモの内容を整理",
                    "後で詳しく確認する必要あり"
                ],
                actionItems: [
                    ActionItem(content: "メモの内容を詳しく確認する", assignee: "", priority: .low)
                ],
                summary: "音声メモの内容を自動構造化。カテゴリ未分類のため、内容の確認を推奨。"
            )
        }
    }

    private func inferCategory(from transcription: String) -> MemoType {
        let text = transcription.lowercased()

        if text.contains("会議") || text.contains("ミーティング") || text.contains("議題")
            || text.contains("田中") || text.contains("鈴木") {
            return .meeting
        }
        if text.contains("買い物") || text.contains("購入") || text.contains("牛乳")
            || text.contains("スーパー") {
            return .shopping
        }
        if text.contains("やること") || text.contains("タスク") || text.contains("TODO")
            || text.contains("期限") {
            return .todo
        }
        if text.contains("アイデア") || text.contains("思いつ") || text.contains("ひらめ")
            || text.contains("新しい") {
            return .idea
        }
        if text.contains("日記") || text.contains("今日") || text.contains("ふりかえ")
            || text.contains("感じ") {
            return .diary
        }
        return .other
    }

    private func extractFirstLine(from text: String) -> String {
        let firstLine = text.prefix(20)
        return String(firstLine) + (text.count > 20 ? "..." : "")
    }
}
