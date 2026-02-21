import Foundation

/// 謎解きパズルを表すモデル
struct Puzzle: Identifiable, Codable, Sendable {
    let id: String
    /// パズルのタイトル
    let title: String
    /// 問題文
    let question: String
    /// 選択肢
    let choices: [Choice]
    /// 正解の選択肢インデックス
    let correctIndex: Int
    /// ヒントテキスト
    let hint: String
    /// 解説テキスト（正解後に表示）
    let explanation: String
    /// 制限時間（秒、nil = 無制限）
    let timeLimitSeconds: Int?
    /// 獲得ポイント
    let points: Int

    /// 選択肢
    struct Choice: Identifiable, Codable, Sendable {
        let id: String
        let text: String
    }

    // MARK: - サンプルデータ

    static let samplePuzzles: [Puzzle] = [
        Puzzle(
            id: "puzzle_01",
            title: "時計台の謎",
            question: "時計台の文字盤には通常と異なる点がある。次のうち、この時計台だけの特徴はどれ？",
            choices: [
                Choice(id: "p1_c1", text: "数字がローマ数字"),
                Choice(id: "p1_c2", text: "4がIIIIと表記されている"),
                Choice(id: "p1_c3", text: "12の位置に星マーク"),
                Choice(id: "p1_c4", text: "針が3本ある"),
            ],
            correctIndex: 2,
            hint: "時計の一番上をよく見てみよう",
            explanation: "この時計台は1962年に建てられ、12の位置に商店街のシンボルである星マークが刻まれています。",
            timeLimitSeconds: 120,
            points: 100
        ),
        Puzzle(
            id: "puzzle_02",
            title: "パン屋の暗号",
            question: "壁に描かれたパンの絵。クロワッサン→メロンパン→食パンの順番が示す方角は？",
            choices: [
                Choice(id: "p2_c1", text: "北"),
                Choice(id: "p2_c2", text: "東"),
                Choice(id: "p2_c3", text: "南"),
                Choice(id: "p2_c4", text: "西"),
            ],
            correctIndex: 1,
            hint: "それぞれのパンの形をアルファベットに見立ててみよう",
            explanation: "クロワッサン=C、メロンパン=O、食パン=E。並べるとCOE=東（East の頭文字E）を示しています。",
            timeLimitSeconds: 180,
            points: 150
        ),
        Puzzle(
            id: "puzzle_03",
            title: "池のほとりの数式",
            question: "ベンチに刻まれた数式「蓮の葉 + 鯉 × 石灯籠 = ?」。公園内の実物を数えて計算せよ。",
            choices: [
                Choice(id: "p3_c1", text: "23"),
                Choice(id: "p3_c2", text: "31"),
                Choice(id: "p3_c3", text: "42"),
                Choice(id: "p3_c4", text: "15"),
            ],
            correctIndex: 2,
            hint: "蓮の葉は12枚、鯉は6匹、石灯籠は5基あります",
            explanation: "蓮の葉(12) + 鯉(6) × 石灯籠(5) = 12 + 30 = 42。答えは42です。",
            timeLimitSeconds: 300,
            points: 200
        ),
        Puzzle(
            id: "puzzle_04",
            title: "鳥居の最後の謎",
            question: "これまでの3つの謎の答えを順番に並べると、ある言葉になる。その言葉は？",
            choices: [
                Choice(id: "p4_c1", text: "まちの宝"),
                Choice(id: "p4_c2", text: "星東42（ほしひがし よんに）"),
                Choice(id: "p4_c3", text: "縁結び"),
                Choice(id: "p4_c4", text: "商店街の歴史"),
            ],
            correctIndex: 0,
            hint: "最初の謎=星、2番目=東、3番目=42。42を日本語の語呂合わせで読むと...",
            explanation: "星(ほし) + 東(ひがし) + 42(しに→しの=の) → ほし・の・たから → 「まちの宝」。商店街に隠された宝物の在り処を示しています。",
            timeLimitSeconds: nil,
            points: 300
        ),
    ]

    /// IDで検索
    static func find(by id: String) -> Puzzle? {
        samplePuzzles.first { $0.id == id }
    }
}
