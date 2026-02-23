import Foundation

// MARK: - NoteAnalysisManager

@MainActor
@Observable
final class NoteAnalysisManager {

    static let shared = NoteAnalysisManager()

    // MARK: - State

    var isAnalyzing = false
    var analysisProgress: Double = 0

    // MARK: - Foundation Models Simulation

    func analyzeNote(text: String, layoutType: NoteLayoutType) async -> NoteSummary {
        isAnalyzing = true
        analysisProgress = 0

        // Foundation Models の処理をシミュレーション
        for i in 1...10 {
            try? await Task.sleep(for: .milliseconds(150))
            analysisProgress = Double(i) / 10.0
        }

        let summary = generateMockSummary(for: text, layout: layoutType)
        isAnalyzing = false
        return summary
    }

    func suggestNoteType(from text: String) -> NoteType {
        let lowercased = text.lowercased()
        if lowercased.contains("会議") || lowercased.contains("参加者") || lowercased.contains("議題") {
            return .meeting
        } else if lowercased.contains("ブレスト") || lowercased.contains("アイデア") || lowercased.contains("ブレインストーミング") {
            return .brainstorm
        } else if lowercased.contains("講義") || lowercased.contains("第") || lowercased.contains("まとめ") {
            return .lecture
        } else if lowercased.contains("タスク") || lowercased.contains("□") || lowercased.contains("☑") {
            return .todo
        }
        return .other
    }

    func suggestTags(from text: String) -> [String] {
        var tags: [String] = []
        let keywords: [String: String] = [
            "API": "API",
            "デザイン": "デザイン",
            "テスト": "テスト",
            "AI": "AI",
            "Swift": "Swift",
            "会議": "会議",
            "プロジェクト": "プロジェクト",
            "アルゴリズム": "アルゴリズム",
            "パフォーマンス": "パフォーマンス",
        ]

        for (keyword, tag) in keywords {
            if text.contains(keyword) {
                tags.append(tag)
            }
        }

        return Array(tags.prefix(5))
    }

    // MARK: - Markdown Export

    func exportAsMarkdown(note: Note) -> String {
        var md = "# \(note.title)\n\n"
        md += "> \(note.formattedDate)\n\n"

        if let summary = note.summary {
            md += "## 要約\n\n\(summary.summaryText)\n\n"

            if !summary.actionItems.isEmpty {
                md += "## アクションアイテム\n\n"
                for item in summary.actionItems {
                    let check = item.isCompleted ? "x" : " "
                    md += "- [\(check)] \(item.text)"
                    if let assignee = item.assignee {
                        md += " (担当: \(assignee))"
                    }
                    if let due = item.formattedDueDate {
                        md += " [期限: \(due)]"
                    }
                    md += "\n"
                }
                md += "\n"
            }

            if !summary.relatedTopics.isEmpty {
                md += "## 関連トピック\n\n"
                md += summary.relatedTopics.map { "- \($0)" }.joined(separator: "\n")
                md += "\n\n"
            }
        }

        md += "## 原文\n\n\(note.recognizedText)\n"
        return md
    }

    // MARK: - Private

    private func generateMockSummary(for text: String, layout: NoteLayoutType) -> NoteSummary {
        let noteType = suggestNoteType(from: text)

        let summaryText: String
        let actionItems: [ActionItem]
        let relatedTopics: [String]

        switch noteType {
        case .meeting:
            summaryText = "チーム定例会議の記録。各パートの進捗報告と課題の共有が行われた。次回までのアクションアイテムが3件設定された。"
            actionItems = [
                ActionItem(text: "負荷テスト実施", assignee: "山田", dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())),
                ActionItem(text: "CI/CD パイプライン構築", assignee: "鈴木", dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())),
                ActionItem(text: "ユーザビリティテスト計画策定", assignee: "佐藤", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())),
            ]
            relatedTopics = ["DevOps", "QA", "フロントエンド"]

        case .brainstorm:
            summaryText = "新サービスのアイデア出し。AI チューターを軸に、個別最適化・音声対話・進捗可視化の3方向を検討。AI×個別最適化を最優先と判定。"
            actionItems = [
                ActionItem(text: "市場調査レポート作成"),
                ActionItem(text: "プロトタイプ設計開始"),
            ]
            relatedTopics = ["EdTech", "LLM", "パーソナライゼーション"]

        case .lecture:
            summaryText = "データ構造とアルゴリズムの第5回講義。ハッシュテーブル・木構造・グラフの3つのデータ構造をカバー。来週テストあり。"
            actionItems = [
                ActionItem(text: "第1-5回の復習", dueDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())),
                ActionItem(text: "練習問題を解く"),
            ]
            relatedTopics = ["計算量", "データベース", "ソートアルゴリズム"]

        case .todo:
            summaryText = "今週のタスク一覧。6件中2件完了。ユニットテスト追加が最優先。金曜17時が全体の期限。"
            actionItems = [
                ActionItem(text: "ユニットテスト追加", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())),
                ActionItem(text: "ドキュメント更新", dueDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())),
                ActionItem(text: "週報作成", dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())),
            ]
            relatedTopics = ["カバレッジ", "CI/CD"]

        case .other:
            summaryText = "手書きメモの内容を分析しました。"
            actionItems = []
            relatedTopics = suggestTags(from: text)
        }

        return NoteSummary(
            summaryText: summaryText,
            actionItems: actionItems,
            relatedTopics: relatedTopics,
            confidence: Double.random(in: 0.85...0.97)
        )
    }
}
