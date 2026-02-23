import Foundation

/// レシピの定義
struct Recipe: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: RecipeCategory
    let servings: Int
    let totalTime: Int // 分
    let imageSystemName: String
    let steps: [RecipeStep]

    init(
        id: UUID = UUID(),
        name: String,
        category: RecipeCategory,
        servings: Int = 2,
        totalTime: Int,
        imageSystemName: String,
        steps: [RecipeStep]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.servings = servings
        self.totalTime = totalTime
        self.imageSystemName = imageSystemName
        self.steps = steps
    }

    var totalTimeText: String {
        if totalTime >= 60 {
            let hours = totalTime / 60
            let minutes = totalTime % 60
            return minutes > 0 ? "\(hours)時間\(minutes)分" : "\(hours)時間"
        }
        return "\(totalTime)分"
    }

    // MARK: - Sample Data

    static let samples: [Recipe] = [
        Recipe(
            name: "親子丼",
            category: .japanese,
            servings: 2,
            totalTime: 25,
            imageSystemName: "flame.fill",
            steps: [
                RecipeStep(order: 1, instruction: "鶏もも肉 200g を一口大に切る", timerSeconds: nil),
                RecipeStep(order: 2, instruction: "玉ねぎ 1/2 個を薄切りにする", timerSeconds: nil),
                RecipeStep(order: 3, instruction: "鍋にだし汁 150ml、醤油・みりん各大さじ2、砂糖大さじ1 を煮立てる", timerSeconds: 60),
                RecipeStep(order: 4, instruction: "鶏肉と玉ねぎを加えて中火で煮る", timerSeconds: 300),
                RecipeStep(order: 5, instruction: "溶き卵 3個 の 2/3 を回し入れ、蓋をして 30 秒待つ", timerSeconds: 30),
                RecipeStep(order: 6, instruction: "残りの卵を回し入れ、半熟で火を止める", timerSeconds: 20),
                RecipeStep(order: 7, instruction: "丼にご飯を盛り、具材をのせて完成", timerSeconds: nil),
            ]
        ),
        Recipe(
            name: "ペペロンチーノ",
            category: .western,
            servings: 2,
            totalTime: 20,
            imageSystemName: "fork.knife",
            steps: [
                RecipeStep(order: 1, instruction: "パスタ 200g を茹でる（塩は湯の1%）", timerSeconds: 480),
                RecipeStep(order: 2, instruction: "ニンニク 3片 を薄切りにし、赤唐辛子 2本 の種を取る", timerSeconds: nil),
                RecipeStep(order: 3, instruction: "フライパンにオリーブオイル大さじ3とニンニクを入れ、弱火できつね色にする", timerSeconds: 180),
                RecipeStep(order: 4, instruction: "赤唐辛子を加え、香りが立ったらパスタの茹で汁をお玉 2 杯加える", timerSeconds: 30),
                RecipeStep(order: 5, instruction: "茹で上がったパスタを加え、トングで手早く乳化させる", timerSeconds: 60),
                RecipeStep(order: 6, instruction: "塩で味を整え、器に盛って完成", timerSeconds: nil),
            ]
        ),
        Recipe(
            name: "麻婆豆腐",
            category: .chinese,
            servings: 2,
            totalTime: 20,
            imageSystemName: "frying.pan.fill",
            steps: [
                RecipeStep(order: 1, instruction: "豆腐 1丁 を 2cm 角に切り、塩少々を加えた湯で 2 分茹でる", timerSeconds: 120),
                RecipeStep(order: 2, instruction: "フライパンに油を熱し、豆板醤大さじ1、甜麺醤大さじ1、ニンニク・生姜みじん切りを炒める", timerSeconds: 60),
                RecipeStep(order: 3, instruction: "ひき肉 150g を加え、色が変わるまで炒める", timerSeconds: 120),
                RecipeStep(order: 4, instruction: "鶏がらスープ 200ml、醤油大さじ1 を加えて煮立てる", timerSeconds: 60),
                RecipeStep(order: 5, instruction: "水切りした豆腐を加え、中火で 3 分煮る", timerSeconds: 180),
                RecipeStep(order: 6, instruction: "水溶き片栗粉でとろみをつける", timerSeconds: 30),
                RecipeStep(order: 7, instruction: "花椒をふりかけ、ごま油を回しかけて完成", timerSeconds: nil),
            ]
        ),
        Recipe(
            name: "カプレーゼサラダ",
            category: .western,
            servings: 2,
            totalTime: 10,
            imageSystemName: "leaf.fill",
            steps: [
                RecipeStep(order: 1, instruction: "モッツァレラチーズ 1個 を 1cm 厚にスライスする", timerSeconds: nil),
                RecipeStep(order: 2, instruction: "トマト 2個 を同じ厚さにスライスする", timerSeconds: nil),
                RecipeStep(order: 3, instruction: "皿にトマトとモッツァレラを交互に並べる", timerSeconds: nil),
                RecipeStep(order: 4, instruction: "バジルの葉を散らし、オリーブオイルと塩をかけて完成", timerSeconds: nil),
            ]
        ),
        Recipe(
            name: "豚の生姜焼き",
            category: .japanese,
            servings: 2,
            totalTime: 15,
            imageSystemName: "flame.fill",
            steps: [
                RecipeStep(order: 1, instruction: "豚ロース 300g に塩・胡椒をし、薄力粉を薄くまぶす", timerSeconds: nil),
                RecipeStep(order: 2, instruction: "タレを作る: 醤油・みりん・酒 各大さじ2、生姜すりおろし 1片分を混ぜる", timerSeconds: nil),
                RecipeStep(order: 3, instruction: "フライパンに油を熱し、豚肉を中火で片面 2 分ずつ焼く", timerSeconds: 120),
                RecipeStep(order: 4, instruction: "裏返してさらに 2 分焼く", timerSeconds: 120),
                RecipeStep(order: 5, instruction: "タレを回しかけ、絡めながら 1 分煮詰める", timerSeconds: 60),
                RecipeStep(order: 6, instruction: "千切りキャベツを添えて盛り付けて完成", timerSeconds: nil),
            ]
        ),
    ]
}
