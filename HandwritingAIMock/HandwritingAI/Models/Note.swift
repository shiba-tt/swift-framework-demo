import Foundation
import SwiftUI

// MARK: - Note

struct Note: Identifiable, Sendable {
    let id: UUID
    var title: String
    var recognizedText: String
    var originalImageName: String?
    var layoutType: NoteLayoutType
    var noteType: NoteType
    var tags: [String]
    var capturedDate: Date
    var isProcessed: Bool
    var summary: NoteSummary?

    init(
        id: UUID = UUID(),
        title: String,
        recognizedText: String = "",
        originalImageName: String? = nil,
        layoutType: NoteLayoutType = .freeform,
        noteType: NoteType = .other,
        tags: [String] = [],
        capturedDate: Date = Date(),
        isProcessed: Bool = false,
        summary: NoteSummary? = nil
    ) {
        self.id = id
        self.title = title
        self.recognizedText = recognizedText
        self.originalImageName = originalImageName
        self.layoutType = layoutType
        self.noteType = noteType
        self.tags = tags
        self.capturedDate = capturedDate
        self.isProcessed = isProcessed
        self.summary = summary
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: capturedDate)
    }

    var wordCount: Int {
        recognizedText.count
    }
}

// MARK: - NoteLayoutType

enum NoteLayoutType: String, CaseIterable, Sendable {
    case list = "リスト"
    case mindmap = "マインドマップ"
    case flowchart = "フローチャート"
    case table = "表"
    case freeform = "自由形式"

    var systemImage: String {
        switch self {
        case .list: "list.bullet"
        case .mindmap: "point.3.connected.trianglepath.dotted"
        case .flowchart: "arrow.triangle.branch"
        case .table: "tablecells"
        case .freeform: "scribble"
        }
    }

    var color: Color {
        switch self {
        case .list: .blue
        case .mindmap: .purple
        case .flowchart: .orange
        case .table: .green
        case .freeform: .gray
        }
    }
}

// MARK: - NoteType

enum NoteType: String, CaseIterable, Sendable {
    case meeting = "会議"
    case brainstorm = "ブレスト"
    case lecture = "講義"
    case todo = "ToDo"
    case other = "その他"

    var systemImage: String {
        switch self {
        case .meeting: "person.3"
        case .brainstorm: "lightbulb"
        case .lecture: "book"
        case .todo: "checklist"
        case .other: "doc.text"
        }
    }

    var color: Color {
        switch self {
        case .meeting: .blue
        case .brainstorm: .yellow
        case .lecture: .green
        case .todo: .red
        case .other: .secondary
        }
    }
}

// MARK: - Sample Data

extension Note {
    static let samples: [Note] = [
        Note(
            title: "プロジェクト企画会議",
            recognizedText: """
            プロジェクト企画会議 2024/12/15

            参加者: 田中、鈴木、佐藤、山田

            議題1: 新機能の要件定義
            - ユーザー認証の強化
            - ダッシュボード刷新
            - API v2 の設計

            議題2: スケジュール確認
            - 12月末: 要件確定
            - 1月中旬: プロトタイプ
            - 2月末: ベータリリース

            アクションアイテム:
            - 田中: API仕様書のドラフト作成
            - 鈴木: UI モックアップ
            - 佐藤: インフラ調査
            """,
            layoutType: .list,
            noteType: .meeting,
            tags: ["プロジェクト", "企画", "API"],
            capturedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            isProcessed: true,
            summary: NoteSummary(
                summaryText: "新機能の要件定義とスケジュールについて議論。認証強化・ダッシュボード刷新・API v2の3つが主要テーマ。2月末のベータリリースを目標に設定。",
                actionItems: [
                    ActionItem(text: "API仕様書のドラフト作成", assignee: "田中", dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())),
                    ActionItem(text: "UIモックアップ作成", assignee: "鈴木", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())),
                    ActionItem(text: "インフラ調査レポート", assignee: "佐藤", dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())),
                ],
                relatedTopics: ["マイクロサービス", "OAuth 2.0", "SwiftUI"],
                confidence: 0.92
            )
        ),
        Note(
            title: "アプリアイデアブレスト",
            recognizedText: """
            アプリアイデア ブレインストーミング

            テーマ: 「日常を楽しくするアプリ」

            中心: 日常×テクノロジー
            ├── 健康
            │   ├── 睡眠トラッカー
            │   └── 姿勢改善アプリ
            ├── 学習
            │   ├── AR単語帳
            │   └── AI家庭教師
            ├── 趣味
            │   ├── 料理レシピAI
            │   └── 写真加工
            └── 仕事
                ├── 会議要約
                └── タスク自動化

            最優先: AI家庭教師アプリ
            理由: 市場需要が高い、差別化可能
            """,
            layoutType: .mindmap,
            noteType: .brainstorm,
            tags: ["アイデア", "AI", "アプリ"],
            capturedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            isProcessed: true,
            summary: NoteSummary(
                summaryText: "日常を楽しくするアプリのアイデアをブレスト。健康・学習・趣味・仕事の4カテゴリに分類。AI家庭教師アプリを最優先案として選定。",
                actionItems: [
                    ActionItem(text: "AI家庭教師アプリの市場調査", assignee: nil, dueDate: nil),
                    ActionItem(text: "競合分析レポート作成", assignee: nil, dueDate: nil),
                ],
                relatedTopics: ["EdTech", "Foundation Models", "パーソナライゼーション"],
                confidence: 0.88
            )
        ),
        Note(
            title: "Swift Concurrency 講義ノート",
            recognizedText: """
            Swift Concurrency まとめ

            1. async/await
               - 非同期関数の定義と呼び出し
               - Task { } でエントリポイント作成

            2. Actor
               - データ競合の防止
               - @MainActor でUI更新
               - isolated / nonisolated

            3. Structured Concurrency
               - TaskGroup
               - async let
               - withThrowingTaskGroup

            4. Sendable
               - スレッド安全な型
               - @Sendable クロージャ
               - SWIFT_STRICT_CONCURRENCY: complete

            重要: Swift 6 ではデフォルトで strict concurrency
            """,
            layoutType: .list,
            noteType: .lecture,
            tags: ["Swift", "Concurrency", "勉強"],
            capturedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            isProcessed: true,
            summary: NoteSummary(
                summaryText: "Swift Concurrencyの4つの柱を学習。async/await、Actor、Structured Concurrency、Sendableについて体系的に整理。Swift 6でのstrict concurrencyデフォルト化が重要ポイント。",
                actionItems: [
                    ActionItem(text: "TaskGroupを使ったサンプルコード作成", assignee: nil, dueDate: nil),
                    ActionItem(text: "Actorの実装練習", assignee: nil, dueDate: nil),
                ],
                relatedTopics: ["Swift 6", "GCD", "OperationQueue"],
                confidence: 0.95
            )
        ),
        Note(
            title: "買い物リスト",
            recognizedText: """
            買い物リスト

            □ 牛乳
            □ パン
            □ 卵 (6個入り)
            □ 玉ねぎ x3
            ☑ トマト缶 x2
            □ 鶏むね肉 300g
            ☑ ヨーグルト
            □ バナナ
            """,
            layoutType: .list,
            noteType: .todo,
            tags: ["買い物", "生活"],
            capturedDate: Date(),
            isProcessed: true,
            summary: NoteSummary(
                summaryText: "食料品の買い物リスト。8品目のうち2品目が購入済み。",
                actionItems: [
                    ActionItem(text: "牛乳を買う", assignee: nil, dueDate: Date(), isCompleted: false),
                    ActionItem(text: "パンを買う", assignee: nil, dueDate: Date(), isCompleted: false),
                    ActionItem(text: "卵(6個入り)を買う", assignee: nil, dueDate: Date(), isCompleted: false),
                    ActionItem(text: "トマト缶 x2を買う", assignee: nil, dueDate: nil, isCompleted: true),
                    ActionItem(text: "ヨーグルトを買う", assignee: nil, dueDate: nil, isCompleted: true),
                ],
                relatedTopics: [],
                confidence: 0.97
            )
        ),
    ]
}
