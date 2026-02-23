import Foundation

// MARK: - OCRManager

@MainActor
@Observable
final class OCRManager {

    static let shared = OCRManager()

    // MARK: - State

    var isProcessing = false
    var progress: Double = 0
    var latestResult: OCRResult?

    // MARK: - OCR Simulation

    func recognizeText(from imageData: Data? = nil) async -> OCRResult {
        isProcessing = true
        progress = 0

        // Step 1: 画像前処理
        for i in 1...5 {
            try? await Task.sleep(for: .milliseconds(100))
            progress = Double(i) / 20.0
        }

        // Step 2: VNRecognizeTextRequest シミュレーション
        for i in 6...12 {
            try? await Task.sleep(for: .milliseconds(80))
            progress = Double(i) / 20.0
        }

        // Step 3: 図形検出
        for i in 13...17 {
            try? await Task.sleep(for: .milliseconds(60))
            progress = Double(i) / 20.0
        }

        // Step 4: レイアウト分類
        for i in 18...20 {
            try? await Task.sleep(for: .milliseconds(50))
            progress = Double(i) / 20.0
        }

        let sampleTexts = [
            mockMeetingNote,
            mockBrainstormNote,
            mockLectureNote,
            mockTodoNote,
        ]

        let selectedText = sampleTexts.randomElement()!
        let layouts: [NoteLayoutType] = [.list, .mindmap, .flowchart, .list]
        let selectedLayout = layouts.randomElement()!

        let shapes: [DetectedShape] = [
            DetectedShape(shapeType: .arrow, associatedText: "因果関係"),
            DetectedShape(shapeType: .box, associatedText: "重要項目"),
            DetectedShape(shapeType: .underline, associatedText: "キーワード"),
        ]

        let result = OCRResult(
            recognizedText: selectedText,
            detectedShapes: shapes,
            layoutType: selectedLayout,
            confidence: Double.random(in: 0.88...0.97),
            processingTime: Double.random(in: 1.2...3.5)
        )

        latestResult = result
        isProcessing = false
        return result
    }

    // MARK: - Mock Texts

    private var mockMeetingNote: String {
        """
        週次定例会議 メモ

        日時: 月曜日 10:00-11:00
        参加者: チーム全員

        報告事項:
        - フロントエンド: ログイン画面完成
        - バックエンド: API レスポンス最適化中
        - デザイン: カラーパレット確定

        課題:
        → パフォーマンス改善が必要
        → テスト自動化の導入検討

        次回アクション:
        □ 負荷テスト実施 (担当: 山田)
        □ CI/CD パイプライン構築 (担当: 鈴木)
        □ ユーザビリティテスト計画 (担当: 佐藤)
        """
    }

    private var mockBrainstormNote: String {
        """
        新サービス ブレインストーミング

        テーマ: 「学びを変える」

            AI チューター
           /     |     \\
        個別最適化  音声対話  進捗可視化
           |        |         |
        苦手分析   発音矯正   目標設定
                    |
               多言語対応

        優先順位:
        ★ AI チューター × 個別最適化
        ○ 音声対話 × 多言語
        △ 進捗可視化（後回し）
        """
    }

    private var mockLectureNote: String {
        """
        データ構造とアルゴリズム 第5回

        1. ハッシュテーブル
           - キーから値を O(1) で取得
           - 衝突解決: チェイン法 / オープンアドレス法
           - 負荷率 = 要素数 / バケット数

        2. 木構造
           - 二分探索木 (BST)
           - 平衡木: AVL木、赤黒木
           - 探索: O(log n)

        3. グラフ
           - 隣接行列 vs 隣接リスト
           - BFS / DFS
           - 最短経路: ダイクストラ

        重要: 来週テストあり！範囲は第1-5回
        """
    }

    private var mockTodoNote: String {
        """
        今週のタスク

        ☑ デザインレビュー提出
        □ ユニットテスト追加（カバレッジ 80% 目標）
        □ ドキュメント更新
        ☑ コードレビュー（PR #234）
        □ パフォーマンス計測
        □ 週報作成

        優先: ユニットテスト > ドキュメント > 週報
        期限: 金曜日 17:00
        """
    }
}
