import Foundation

// MARK: - AdventureManager

@MainActor
@Observable
final class AdventureManager {
    static let shared = AdventureManager()

    private(set) var adventures: [Adventure] = []
    private(set) var completedAdventureIDs: Set<UUID> = []

    private init() {
        adventures = Self.generateSampleAdventures()
    }

    // MARK: - Adventure Lifecycle

    func startAdventure(_ adventure: Adventure) -> Adventure {
        guard var target = adventures.first(where: { $0.id == adventure.id }) else {
            return adventure
        }
        target.status = .inProgress
        target.startedAt = .now
        target.results = []
        updateAdventure(target)
        return target
    }

    func submitAnswer(
        for adventure: Adventure,
        spotID: UUID,
        selectedAnswer: String,
        timeSpent: TimeInterval,
        hintUsed: Bool
    ) -> (adventure: Adventure, result: SpotResult) {
        guard var target = adventures.first(where: { $0.id == adventure.id }),
              let spot = target.spots.first(where: { $0.id == spotID }) else {
            let emptyResult = SpotResult(
                spotID: spotID, isSolved: false, timeSpent: timeSpent, hintUsed: hintUsed
            )
            return (adventure, emptyResult)
        }

        let isSolved = selectedAnswer == spot.puzzle.answer
        let result = SpotResult(
            spotID: spotID,
            isSolved: isSolved,
            timeSpent: timeSpent,
            hintUsed: hintUsed
        )

        target.results.append(result)

        if target.results.count >= target.spots.count {
            target.status = .completed
            completedAdventureIDs.insert(target.id)
        }

        updateAdventure(target)
        return (target, result)
    }

    // MARK: - Private

    private func updateAdventure(_ adventure: Adventure) {
        if let index = adventures.firstIndex(where: { $0.id == adventure.id }) {
            adventures[index] = adventure
        }
    }

    // MARK: - Sample Data

    private static func generateSampleAdventures() -> [Adventure] {
        [
            Adventure(
                title: "渋谷ミステリーウォーク",
                description: "渋谷の街に隠された5つの謎を解き明かせ！ハチ公前からスタートし、街中のスポットを巡ろう。",
                areaName: "渋谷エリア",
                spots: generateShibuyaSpots(),
                timeLimitMinutes: 90
            ),
            Adventure(
                title: "浅草下町パズルツアー",
                description: "浅草の歴史ある街並みに潜む暗号を解読せよ。雷門から始まる謎解き散歩。",
                areaName: "浅草エリア",
                spots: generateAsakusaSpots(),
                timeLimitMinutes: 120
            ),
            Adventure(
                title: "秋葉原テクノ・エニグマ",
                description: "電気街に仕掛けられた論理パズルに挑戦。テクノロジーと謎解きの融合体験。",
                areaName: "秋葉原エリア",
                spots: generateAkihabaraSpots(),
                timeLimitMinutes: 60
            ),
        ]
    }

    private static func generateShibuyaSpots() -> [PuzzleSpot] {
        [
            PuzzleSpot(
                name: "ハチ公前広場",
                description: "待ち合わせの定番スポット。忠犬ハチ公の足元に最初の手がかりが…",
                latitude: 35.6590,
                longitude: 139.7006,
                puzzle: Puzzle(
                    type: .wordScramble,
                    difficulty: .easy,
                    question: "次の文字を並べ替えて、渋谷の有名な像の名前にしてください：「うちこはき」",
                    hint: "忠実な犬の名前です",
                    answer: "ハチ公",
                    choices: ["ハチ公", "モヤイ像", "忠犬像", "渋谷犬"]
                ),
                spotNumber: 1,
                nfcTagID: "shibuya-spot-001"
            ),
            PuzzleSpot(
                name: "センター街入口",
                description: "若者文化の中心地。看板の中に隠されたメッセージを見つけよう。",
                latitude: 35.6598,
                longitude: 139.6986,
                puzzle: Puzzle(
                    type: .numberSequence,
                    difficulty: .easy,
                    question: "次の数列の法則を見つけて、?に入る数字を答えてください：2, 6, 12, 20, ?",
                    hint: "各数の差に注目：4, 6, 8, ...",
                    answer: "30",
                    choices: ["28", "30", "32", "24"]
                ),
                spotNumber: 2,
                nfcTagID: "shibuya-spot-002"
            ),
            PuzzleSpot(
                name: "SHIBUYA109前",
                description: "ファッションの聖地。ビルの数字に隠された秘密とは？",
                latitude: 35.6594,
                longitude: 139.6985,
                puzzle: Puzzle(
                    type: .cipher,
                    difficulty: .medium,
                    question: "暗号「VKLEXBD」をシーザー暗号（3文字シフト）で解読してください",
                    hint: "各文字を3つ前にずらしてみましょう",
                    answer: "SHIBUYA",
                    choices: ["SHIBUYA", "HARAJKU", "SHINJKU", "IKEBUKR"]
                ),
                spotNumber: 3,
                nfcTagID: "shibuya-spot-003"
            ),
            PuzzleSpot(
                name: "スペイン坂",
                description: "おしゃれな坂道の途中に仕掛けられた問題。坂の上から見える景色がヒント。",
                latitude: 35.6610,
                longitude: 139.6980,
                puzzle: Puzzle(
                    type: .logicGate,
                    difficulty: .medium,
                    question: "A, B, Cの3人がレストランにいます。Aは嘘つき、Bは正直者。Aが「Cは嘘つきだ」と言いました。Cは？",
                    hint: "嘘つきの発言の逆が真実です",
                    answer: "正直者",
                    choices: ["正直者", "嘘つき", "どちらでもない", "判断できない"]
                ),
                spotNumber: 4,
                nfcTagID: "shibuya-spot-004"
            ),
            PuzzleSpot(
                name: "渋谷ストリーム",
                description: "渋谷川沿いの最終地点。すべての謎を解いてゴールを目指せ！",
                latitude: 35.6575,
                longitude: 139.7020,
                puzzle: Puzzle(
                    type: .imageRiddle,
                    difficulty: .hard,
                    question: "渋谷のスクランブル交差点は世界最大級と言われています。1回の青信号で渡る人数は最大約何人でしょう？",
                    hint: "数千人規模です",
                    answer: "3000人",
                    choices: ["1000人", "2000人", "3000人", "5000人"]
                ),
                spotNumber: 5,
                nfcTagID: "shibuya-spot-005"
            ),
        ]
    }

    private static func generateAsakusaSpots() -> [PuzzleSpot] {
        [
            PuzzleSpot(
                name: "雷門",
                description: "浅草のシンボル。巨大な提灯の下に最初のパズルが待っている。",
                latitude: 35.7108,
                longitude: 139.7964,
                puzzle: Puzzle(
                    type: .wordScramble,
                    difficulty: .easy,
                    question: "雷門の正式名称は「風○○○門」です。○に入る漢字3文字は？",
                    hint: "雷と対になる自然現象です",
                    answer: "雷神",
                    choices: ["雷神", "風神", "天神", "龍神"]
                ),
                spotNumber: 1,
                nfcTagID: "asakusa-spot-001"
            ),
            PuzzleSpot(
                name: "仲見世通り",
                description: "日本最古の商店街の一つ。お土産屋さんの間に謎が隠されている。",
                latitude: 35.7118,
                longitude: 139.7966,
                puzzle: Puzzle(
                    type: .numberSequence,
                    difficulty: .medium,
                    question: "仲見世通りの長さは約250m。全部で約90店舗あります。1店舗あたり平均何mでしょう？（小数点以下切り捨て）",
                    hint: "250 ÷ 90 を計算しましょう",
                    answer: "約2.7m",
                    choices: ["約1.5m", "約2.7m", "約3.5m", "約4.2m"]
                ),
                spotNumber: 2,
                nfcTagID: "asakusa-spot-002"
            ),
            PuzzleSpot(
                name: "浅草寺本堂",
                description: "都内最古の寺院。本堂の屋根に隠された暗号を解読せよ。",
                latitude: 35.7148,
                longitude: 139.7967,
                puzzle: Puzzle(
                    type: .cipher,
                    difficulty: .medium,
                    question: "次の数字は五十音表の座標です。「1-1, 3-1, 2-3, 3-1」→ 答えは？",
                    hint: "あいうえお表で、行と段の番号です（1-1=あ）",
                    answer: "あさくさ",
                    choices: ["あさくさ", "せんそう", "かみなり", "ほうぞう"]
                ),
                spotNumber: 3,
                nfcTagID: "asakusa-spot-003"
            ),
            PuzzleSpot(
                name: "花やしき",
                description: "日本最古の遊園地。レトロな雰囲気の中で論理パズルに挑戦。",
                latitude: 35.7152,
                longitude: 139.7945,
                puzzle: Puzzle(
                    type: .logicGate,
                    difficulty: .hard,
                    question: "花やしきのローラーコースターは日本最古です。開業年は1953年。2024年で何周年？",
                    hint: "2024 - 1953 = ?",
                    answer: "71周年",
                    choices: ["65周年", "68周年", "71周年", "75周年"]
                ),
                spotNumber: 4,
                nfcTagID: "asakusa-spot-004"
            ),
        ]
    }

    private static func generateAkihabaraSpots() -> [PuzzleSpot] {
        [
            PuzzleSpot(
                name: "秋葉原駅電気街口",
                description: "電気街の玄関口。デジタルの世界への入口で最初のパズルが始まる。",
                latitude: 35.6984,
                longitude: 139.7731,
                puzzle: Puzzle(
                    type: .numberSequence,
                    difficulty: .easy,
                    question: "2進数「1010」を10進数に変換してください",
                    hint: "8+0+2+0 = ?",
                    answer: "10",
                    choices: ["8", "10", "12", "16"]
                ),
                spotNumber: 1,
                nfcTagID: "akiba-spot-001"
            ),
            PuzzleSpot(
                name: "ラジオ会館",
                description: "オタク文化の聖地。フロアガイドに隠されたパターンを見つけよう。",
                latitude: 35.6988,
                longitude: 139.7710,
                puzzle: Puzzle(
                    type: .logicGate,
                    difficulty: .medium,
                    question: "AND, OR, NOT ゲート：入力 A=1, B=0 のとき、(A AND B) OR (NOT B) の出力は？",
                    hint: "A AND B = 0, NOT B = 1, 0 OR 1 = ?",
                    answer: "1",
                    choices: ["0", "1", "不定", "エラー"]
                ),
                spotNumber: 2,
                nfcTagID: "akiba-spot-002"
            ),
            PuzzleSpot(
                name: "万世橋",
                description: "歴史ある赤レンガの橋。テクノロジーと歴史の交差点で最後の謎を。",
                latitude: 35.6978,
                longitude: 139.7700,
                puzzle: Puzzle(
                    type: .cipher,
                    difficulty: .hard,
                    question: "ASCII コード：65=A, 66=B... として、「65 75 73 66 65」を文字に変換してください",
                    hint: "各数字をアルファベットに置き換えましょう",
                    answer: "AKIBA",
                    choices: ["AKIBA", "TOKYO", "JAPAN", "OTAKU"]
                ),
                spotNumber: 3,
                nfcTagID: "akiba-spot-003"
            ),
        ]
    }
}
