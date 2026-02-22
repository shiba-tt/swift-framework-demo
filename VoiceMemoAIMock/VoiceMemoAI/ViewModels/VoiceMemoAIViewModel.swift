import Foundation
import SwiftData

// MARK: - VoiceMemoAIViewModel

@MainActor
@Observable
final class VoiceMemoAIViewModel {

    // MARK: - Dependencies

    private let modelManager = FoundationModelManager.shared
    private let speechManager = SpeechRecognitionManager.shared
    private var modelContext: ModelContext?

    // MARK: - State

    var memos: [VoiceMemo] = []
    var selectedMemo: VoiceMemo?
    var searchText = ""
    var selectedCategory: MemoCategory?
    var isAnalyzing = false
    var analysisProgress: String?
    var errorMessage: String?

    // MARK: - Speech State (delegate)

    var isRecording: Bool { speechManager.isRecording }
    var currentTranscription: String { speechManager.currentTranscription }
    var recordingDuration: TimeInterval { speechManager.recordingDuration }

    // MARK: - Computed Properties

    var filteredMemos: [VoiceMemo] {
        var result = memos

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter { memo in
                memo.displayTitle.localizedCaseInsensitiveContains(searchText)
                || memo.rawTranscription.localizedCaseInsensitiveContains(searchText)
                || (memo.summary ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.recordedAt > $1.recordedAt }
    }

    var statistics: MemoStatistics {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()

        var categoryCounts: [MemoCategory: Int] = [:]
        for memo in memos {
            if let cat = memo.category {
                categoryCounts[cat, default: 0] += 1
            }
        }

        let allActionItems = memos.flatMap { $0.actionItems }
        let pending = allActionItems.filter { !$0.isCompleted }.count
        let completed = allActionItems.filter { $0.isCompleted }.count

        let avgDuration = memos.isEmpty ? 0 : memos.reduce(0.0) { $0 + $1.duration } / Double(memos.count)
        let thisWeek = memos.filter { $0.recordedAt >= startOfWeek }.count

        return MemoStatistics(
            totalCount: memos.count,
            categoryCounts: categoryCounts,
            pendingActionItems: pending,
            completedActionItems: completed,
            averageDuration: avgDuration,
            thisWeekCount: thisWeek
        )
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchMemos()

        if memos.isEmpty {
            generateSampleData()
        }
    }

    // MARK: - CRUD

    private func fetchMemos() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<VoiceMemo>(
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        do {
            memos = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "メモの読み込みに失敗しました: \(error.localizedDescription)"
        }
    }

    func deleteMemo(_ memo: VoiceMemo) {
        guard let modelContext else { return }
        modelContext.delete(memo)
        try? modelContext.save()
        fetchMemos()
    }

    func toggleActionItem(_ item: ActionItemData, in memo: VoiceMemo) {
        if let index = memo.actionItems.firstIndex(where: { $0.id == item.id }) {
            memo.actionItems[index].isCompleted.toggle()
            try? modelContext?.save()
            fetchMemos()
        }
    }

    // MARK: - Recording

    func startRecording() {
        speechManager.startRecording()
    }

    func stopRecordingAndAnalyze() async {
        let result = speechManager.stopRecording()

        guard !result.transcription.isEmpty else {
            errorMessage = "音声を認識できませんでした。もう一度お試しください。"
            return
        }

        isAnalyzing = true

        do {
            let structure = try await modelManager.analyzeMemo(transcription: result.transcription)
            analysisProgress = modelManager.analysisProgress

            let memo = VoiceMemo(
                rawTranscription: result.transcription,
                duration: result.duration,
                categoryRawValue: structure.category.rawValue,
                title: structure.title,
                summary: structure.summary,
                actionItems: structure.actionItems.map { item in
                    ActionItemData(
                        content: item.content,
                        assignee: item.assignee.isEmpty ? nil : item.assignee,
                        priority: item.priority.rawValue
                    )
                },
                keyPoints: structure.keyPoints,
                isStructured: true
            )

            modelContext?.insert(memo)
            try? modelContext?.save()
            fetchMemos()
        } catch {
            errorMessage = "メモの構造化に失敗しました: \(error.localizedDescription)"
        }

        isAnalyzing = false
        analysisProgress = nil
    }

    // MARK: - Sample Data

    private func generateSampleData() {
        guard let modelContext else { return }

        let samples: [(String, String, String?, MemoCategory, TimeInterval, [ActionItemData], [String])] = [
            (
                "チーム週次定例ミーティング",
                "今日のチーム定例では、新機能の開発進捗と来月のリリース計画について話し合いました。田中さんからフロントエンドの実装が80%完了したとの報告。鈴木さんはAPIのテストが遅れ気味とのこと。",
                "新機能開発は概ね順調。フロントエンド80%完了、API側のテスト遅延を来週中にキャッチアップ予定。リリース日は予定通り来月15日。",
                .meeting,
                185,
                [
                    ActionItemData(content: "API テストの遅延原因を調査して報告", assignee: "鈴木", priority: "high"),
                    ActionItemData(content: "リリースノートのドラフトを作成", assignee: "田中", priority: "medium"),
                    ActionItemData(content: "QA チームにテスト計画を共有", assignee: "佐藤", priority: "medium", isCompleted: true)
                ],
                ["フロントエンド実装80%完了", "APIテストに遅延あり", "リリース日は来月15日で変更なし"]
            ),
            (
                "週末の買い物メモ",
                "週末の買い物リスト。牛乳と卵とパン、それからチーズとワイン。パーティーがあるからね。洗剤も切れそう。",
                "日常の食料品と週末パーティーの食材、日用品の買い物リスト。",
                .shopping,
                42,
                [
                    ActionItemData(content: "牛乳・卵・パンを購入", priority: "high", isCompleted: true),
                    ActionItemData(content: "チーズとワインを選ぶ", priority: "medium"),
                    ActionItemData(content: "洗濯洗剤を補充", priority: "low")
                ],
                ["基本食材の補充が必要", "週末パーティーの準備", "日用品の在庫チェック"]
            ),
            (
                "新アプリのアイデアメモ",
                "散歩中にアイデアを思いついた。位置情報に紐づくメモアプリで、ARで過去の記録が浮かび上がるの。友達ともスポットを共有できる。",
                "位置情報×AR×ソーシャルの新しいメモアプリの構想。場所に紐づいた思い出を可視化する体験設計。",
                .idea,
                68,
                [
                    ActionItemData(content: "類似アプリの市場調査", priority: "high"),
                    ActionItemData(content: "ワイヤーフレーム作成", priority: "medium")
                ],
                ["位置情報連動メモアプリ", "AR表示で思い出を可視化", "ソーシャル共有機能"]
            ),
            (
                "今日のふりかえり",
                "今日は朝からジョギングができて気分が良かった。午後のミーティングが長引いたのは反省点。夕食に新しいパスタのレシピを試したら家族に好評だった。",
                "充実した一日。朝の運動習慣は好調、午後の時間管理は改善の余地あり。新レシピは成功。",
                .diary,
                95,
                [],
                ["朝ジョギングで好スタート", "午後ミーティング長引く", "新レシピが家族に好評"]
            ),
            (
                "確定申告のTODO",
                "確定申告の準備をしないと。まず源泉徴収票を集めて、医療費の領収書を整理。ふるさと納税の証明書も必要。期限は3月15日まで。",
                "確定申告の必要書類の整理と手続きTODO。3月15日の期限に向けて準備を進める。",
                .todo,
                55,
                [
                    ActionItemData(content: "源泉徴収票を集める", priority: "high", isCompleted: true),
                    ActionItemData(content: "医療費の領収書を整理", priority: "high"),
                    ActionItemData(content: "ふるさと納税の証明書を準備", priority: "high"),
                    ActionItemData(content: "e-Taxで確定申告書を作成", priority: "medium")
                ],
                ["源泉徴収票の収集", "医療費控除の準備", "ふるさと納税証明書", "期限: 3月15日"]
            )
        ]

        for (index, sample) in samples.enumerated() {
            let memo = VoiceMemo(
                recordedAt: Date().addingTimeInterval(TimeInterval(-86400 * (samples.count - index))),
                rawTranscription: sample.1,
                duration: sample.4,
                categoryRawValue: sample.3.rawValue,
                title: sample.0,
                summary: sample.2,
                actionItems: sample.5,
                keyPoints: sample.6,
                isStructured: true
            )
            modelContext.insert(memo)
        }

        try? modelContext.save()
        fetchMemos()
    }
}
