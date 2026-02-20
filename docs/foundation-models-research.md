# Foundation Models フレームワーク 調査レポート

## 1. Foundation Models とは

Foundation Models は WWDC25 で発表された Apple のフレームワークで、Apple Intelligence を支えるオンデバイス LLM（約 30 億パラメータ）に Swift API を通じて直接アクセスできる。macOS・iPadOS・iOS・visionOS で利用可能。

サーバー通信が一切不要で、`import FoundationModels` だけで利用を開始できる。すべての推論がデバイス上で完結するため、ユーザーのプライバシーが完全に保護される。

**核心コンセプト:** 「プライベート・高速・オフラインで動作するオンデバイス生成 AI」

### Core ML との関係

```
┌─────────────────────────────────────────┐
│           Foundation Models             │  ← 高レベル API（テキスト生成・構造化出力）
├─────────────────────────────────────────┤
│              Core ML                    │  ← ML 推論エンジン（モデルの実行基盤）
├─────────────────────────────────────────┤
│   Neural Engine  /  GPU  /  CPU         │  ← ハードウェア
└─────────────────────────────────────────┘
```

Foundation Models は Core ML の上位レイヤーとして位置づけられ、Apple のオンデバイス LLM に特化したインターフェースを提供する。Core ML が汎用的な ML モデルの推論エンジンであるのに対し、Foundation Models はテキスト生成に最適化された専用フレームワーク。

---

## 2. モデルの仕様と制約

### 2.1 モデルスペック

| 項目 | 仕様 |
|---|---|
| **パラメータ数** | 約 30 億（~3B） |
| **コンテキストウィンドウ** | 4,096 トークン（入力 + 出力の合計） |
| **メモリ使用量** | 約 1.2 GB（ロード時） |
| **得意なタスク** | 要約、エンティティ抽出、テキスト理解、リライト、短い対話、クリエイティブ生成 |
| **不向きなタスク** | 汎用知識の Q&A、長文チャットボット |
| **対応プラットフォーム** | iOS 26+, iPadOS 26+, macOS 26+, visionOS 26+ |
| **対応デバイス** | Apple Intelligence 対応デバイス（A17 Pro 以降 / M1 以降） |
| **ファインチューニング** | 不可（カスタムアダプターで対応） |

### 2.2 コンテキストウィンドウの詳細

**4,096 トークンは入力と出力の合計** であり、この制約が最も重要な設計上の考慮事項となる。

- 入力に 4,000 トークン使えば、出力は残り 96 トークンのみ
- トークン数の目安:
  - **英語:** 3〜4 文字 ≒ 1 トークン
  - **日本語・中国語:** 1 文字 ≒ 1 トークン
- 公開トークナイザー API は存在しない（内部で処理される）
- コンテキスト超過時は `exceededContextWindowSize` エラーがスローされる

### コンテキスト管理の戦略

```
戦略 1: 要約によるコンテキスト圧縮
  コンテキストが 75% に達したら別セッションで要約を生成し、
  新しいセッションに要約を注入してリセット

戦略 2: チャンク分割
  長いテキストをウィンドウサイズに分割し、
  各チャンクに対して再帰的に処理

戦略 3: Tool Calling による動的取得
  全データをコンテキストに載せず、必要に応じて
  Tool で関連セクションだけを取得
```

### 2.3 その他の制約

| 制約 | 詳細 |
|---|---|
| **レート制限** | フォアグラウンドではなし（高負荷時を除く）。バックグラウンドでは予算制あり |
| **バックグラウンド動作** | アプリがバックグラウンドに移行するとモデルは一時停止 or アンロードされる |
| **セッション永続化** | コンテキストはセッションのライフタイムに紐づく。アプリ再起動でリセット |
| **トークン確率** | 各トークンの生成確率は公開されない |
| **言語** | 英語で最高精度。プロンプトは英語で書くことが推奨される |

---

## 3. API の詳細

### 3.1 LanguageModelSession（中心的な API）

`LanguageModelSession` はオンデバイス LLM とやり取りするためのステートフルなオブジェクト。

```swift
import FoundationModels

// 1. 利用可能性チェック
guard SystemLanguageModel.default.availability == .available else {
    return
}

// 2. セッション作成
let session = LanguageModelSession()

// 3. テキスト生成（最もシンプルな形）
let response = try await session.respond(to: "東京の魅力を3文で説明して")
print(response.content) // String
```

#### 主要メソッド

| メソッド | 説明 |
|---|---|
| `respond(to:)` | プロンプトに対するレスポンスを一括で取得 |
| `streamResponse(to:)` | ストリーミングで段階的にレスポンスを取得 |
| `prewarm()` | モデルリソースを事前にメモリにロード |

#### Instructions（システムプロンプト）

```swift
let session = LanguageModelSession(
    instructions: """
    あなたは料理アシスタントです。
    ユーザーの質問に対して、簡潔で実用的なアドバイスを日本語で提供してください。
    レシピは材料と手順を箇条書きで回答してください。
    """
)
```

- Instructions はユーザープロンプトとは区別され、モデルは Instructions をプロンプトよりも優先するよう訓練されている
- **セキュリティ上の注意:** Instructions に未信頼のユーザー入力を含めてはいけない。ユーザー入力は必ず Prompt 側に渡す

#### Transcript（会話履歴）

```swift
// セッションの全プロンプトとレスポンスを取得
for entry in session.transcript.entries {
    switch entry {
    case .prompt(let prompt):
        print("User: \(prompt.content)")
    case .response(let response):
        print("AI: \(response.content)")
    }
}
```

### 3.2 @Generable マクロ（構造化出力）

Foundation Models の最大の特徴は **Guided Generation（構造化出力）** 。`@Generable` マクロを付与した Swift 構造体を定義するだけで、モデルの出力を型安全な Swift オブジェクトとして受け取れる。

```swift
import FoundationModels

@Generable
struct MovieRecommendation {
    @Guide(description: "映画のタイトル")
    var title: String

    @Guide(description: "映画のジャンル", .enum(MovieGenre.self))
    var genre: MovieGenre

    @Guide(description: "1〜5の評価スコア", .range(1...5))
    var rating: Int

    @Guide(description: "映画の短い紹介文（50文字以内）")
    var summary: String  // 他のプロパティに依存するものは最後に配置
}

@Generable
enum MovieGenre: String {
    case action, comedy, drama, horror, scifi, romance
}

// 使い方
let session = LanguageModelSession()
let recommendation: MovieRecommendation = try await session.respond(
    to: "SF映画で初心者におすすめの作品を教えて",
    generating: MovieRecommendation.self
)
print(recommendation.title)   // 型安全にアクセス
print(recommendation.rating)  // Int 型
```

#### @Generable がサポートする型

| カテゴリ | 型 |
|---|---|
| **プリミティブ** | `String`, `Int`, `Double`, `Float`, `Decimal`, `Bool` |
| **コレクション** | `Array`（要素が Generable な場合） |
| **ネスト** | Generable な構造体・列挙型のネスト |
| **列挙型** | `@Generable enum`（選択肢の制限に有用） |

#### @Guide マクロ（出力ガイド）

`@Guide` でプロパティにメタ情報を付与し、生成を制御する:

```swift
@Guide(description: "説明文")           // 自然言語での説明
@Guide(.enum(MyEnum.self))              // 列挙型の選択肢に制限
@Guide(.range(1...10))                  // 数値の範囲を制限
```

#### 重要な設計ルール

1. **プロパティの順序が重要:** モデルは宣言順にプロパティを生成する。他のプロパティに依存するもの（要約など）は最後に配置する
2. **不要なプロパティを含めない:** UI で使わないプロパティは定義しない。生成に時間がかかる
3. **再帰的な型を避ける:** 自分自身を含む再帰的構造は無限ループを引き起こす可能性がある
4. **ネストの深さに注意:** 深くネストした `@Generable` 型はモデルがループに陥る場合がある

### 3.3 ストリーミング

```swift
let session = LanguageModelSession()

// 構造化出力のストリーミング
let stream = session.streamResponse(
    to: "おすすめの映画を教えて",
    generating: MovieRecommendation.self
)

for try await partial in stream {
    // partial は PartiallyGenerated<MovieRecommendation> 型
    // 各プロパティは Optional になる（まだ生成されていない場合は nil）
    if let title = partial.title {
        print("タイトル: \(title)")
    }
    if let summary = partial.summary {
        print("要約: \(summary)")
    }
}
```

ストリーミングでは `@Generable` マクロが自動的に `PartiallyGenerated` 型を生成する。これは元の構造体と同じプロパティを持つが、すべてが `Optional` になっている。

### 3.4 Tool Calling

Foundation Models はモデルに外部機能を呼び出させる Tool Calling をサポートする。

```swift
@Generable
struct WeatherResult {
    var temperature: Double
    var condition: String
}

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "指定された都市の現在の天気を取得する"

    @Generable
    struct Arguments: Generable {
        @Guide(description: "天気を取得したい都市名")
        var city: String
    }

    func call(arguments: Arguments) async throws -> WeatherResult {
        // 実際の天気 API を呼び出す
        return WeatherResult(temperature: 25.0, condition: "晴れ")
    }
}

let session = LanguageModelSession(tools: [GetWeatherTool()])
let response = try await session.respond(to: "東京の天気は？")
```

Tool Calling により、モデルの知識範囲外の情報（リアルタイムデータ、ユーザー固有データ）にアクセスできる。

### 3.5 利用可能性チェック

```swift
let model = SystemLanguageModel.default

switch model.availability {
case .available:
    let session = LanguageModelSession()
case .unavailable(let reason):
    switch reason {
    case .deviceNotEligible:
        // デバイスが Apple Intelligence に非対応
        break
    case .appleIntelligenceNotEnabled:
        // Apple Intelligence が有効化されていない
        break
    case .modelNotReady:
        // モデルがまだダウンロードされていない
        break
    @unknown default:
        break
    }
}
```

---

## 4. 安全性とガードレール

### 4.1 多層防御モデル

Foundation Models には Apple が訓練したガードレールが組み込まれており、有害な入力と出力をブロックする。

```
Layer 1: Apple 組み込みガードレール     ← 常に適用。無効化不可
Layer 2: Instructions（システムプロンプト） ← 開発者が定義するルール
Layer 3: アプリ側の入力フィルタリング     ← ユーザー入力の前処理
Layer 4: アプリ固有の追加チェック        ← ユースケースに応じた後処理
```

### 4.2 エラーハンドリング

```swift
do {
    let response = try await session.respond(to: userInput)
} catch let error as LanguageModelSession.GenerationError {
    switch error {
    case .guardrailViolation:
        // ガードレール違反（有害コンテンツの検出）
        showAlert("この内容には対応できません。別の表現をお試しください。")
    case .exceededContextWindowSize:
        // コンテキストウィンドウ超過 → 新しいセッションで再開
        session = LanguageModelSession()
    case .unsupportedLanguage:
        // 未対応言語
        showAlert("この言語は現在サポートされていません。")
    }
}
```

### 4.3 ガードレールの偽陽性

ガードレールは保守的に設計されており、無害なプロンプトでも誤検知が発生することがある。

**報告されている例:**
- キャンプアプリで釣り・サバイバル関連のプロンプトがブロックされる
- 「鹿ダニを衣類処理で駆除する方法」→ 生成エラー
- 医療・法律関連のコンテンツで偽陽性が発生する場合がある

**対策:** 入念なテストと、ガードレール違反時のフォールバック UI を設計することが重要。

---

## 5. プロンプト設計のベストプラクティス

| 原則 | 説明 | 例 |
|---|---|---|
| **会話的かつ直接的に** | 命令文または明確な質問にする | "次の文章を3行で要約して" |
| **出力の長さを指定** | "3文で" "箇条書き5点で" など | "主なポイントを箇条書き3点でまとめて" |
| **役割を割り当てる** | Instructions でペルソナを設定 | "あなたはプロの料理人です" |
| **例を提示する** | Few-shot（5 つ未満推奨） | 入出力のペアを示す |
| **禁止事項は大文字で** | "DO NOT" で明示的に禁止 | "DO NOT include personal opinions" |
| **短く保つ** | 4096 トークン制約を意識 | プロンプトは簡潔に |

Xcode 上で `#Playground` マクロを使えば、アプリ全体をリビルドせずにプロンプトを素早くイテレーションできる。

---

## 6. カスタムアダプター

Foundation Models のベースモデルはファインチューニング不可だが、**カスタムアダプター** を訓練して特化スキルを追加できる。

| 項目 | 詳細 |
|---|---|
| **サイズ** | 約 150〜160 MB |
| **訓練ツール** | Apple 提供の Python ツールキット |
| **ランク** | Rank 32 の LoRA アダプター |
| **再訓練** | OS アップデートでベースモデルが更新された場合、再訓練が必要 |
| **組み込み** | Content Tagging アダプター（タグ生成、エンティティ抽出、トピック検出） |

---

## 7. iOS アプリ活用アイデア

### アイデア 1: 「SmartSnap — AI 写真アルバムオーガナイザー」

**コンセプト:** 撮影した写真を Vision フレームワークで物体・テキスト認識し、Foundation Models で自然言語のキャプション・タグ・ストーリーを自動生成するアルバムアプリ。

```
カメラ/写真 → Vision (OCR, 物体検出) → Foundation Models (キャプション生成)
                                              ↓
                                        自動アルバム分類
                                        "2024年夏の旅行"
                                        "家族の誕生日会"
```

**面白い点:**
- 「この日何があった？」と自然言語で写真を検索できる
- 写真群から自動で「旅の日記」風テキストを生成
- 完全オンデバイスなのでプライベート写真も安心

**技術構成:** Vision + Foundation Models + Core Data/SwiftData

---

### アイデア 2: 「VoiceMemo AI — 音声メモ構造化エンジン」

**コンセプト:** 音声メモを録音 → Speech フレームワークで文字起こし → Foundation Models で構造化データに変換。会議メモ、買い物リスト、TODO を音声から自動構造化する。

```swift
@Generable
struct MeetingNote {
    @Guide(description: "会議のタイトル")
    var title: String

    @Guide(description: "議論された主要トピック")
    var topics: [Topic]

    @Guide(description: "決定事項と次のアクション")
    var actionItems: [ActionItem]

    @Guide(description: "会議の要約（100文字以内）")
    var summary: String
}
```

**面白い点:**
- 「明日の買い物、牛乳と卵とパン」→ 構造化された買い物リストに自動変換
- 会議メモから自動で TODO リスト・担当者を抽出
- `@Generable` の構造化出力が最も活きるユースケース

**技術構成:** Speech Framework + Foundation Models + @Generable + WidgetKit

---

### アイデア 3: 「ContextCards — 名刺 x AI ネットワーキング」

**コンセプト:** 名刺を撮影すると OCR で情報を抽出し、Foundation Models が「この人との会話のきっかけ」「フォローアップメールの下書き」を自動生成する人脈管理アプリ。

```swift
@Generable
struct BusinessContact {
    @Guide(description: "名前")
    var name: String
    @Guide(description: "会社名")
    var company: String
    @Guide(description: "役職")
    var title: String
    @Guide(description: "この人の業界に関連する会話のきっかけ3つ")
    var conversationStarters: [String]
    @Guide(description: "フォローアップメールの下書き（カジュアルなトーン、100文字以内）")
    var followUpDraft: String
}
```

**面白い点:**
- 名刺交換の直後にフォローアップの下書きが完成
- 業界・役職に応じた会話のきっかけを AI が提案
- 完全オフライン動作なので海外カンファレンスでも使える

**技術構成:** Vision OCR + Foundation Models + Contacts Framework + App Intents

---

### アイデア 4: 「CookSnap — 冷蔵庫の中身からレシピ生成」

**コンセプト:** 冷蔵庫の中身を撮影 → Vision で食材を認識 → Foundation Models が手持ち食材だけで作れるレシピを生成。Tool Calling で栄養データベースと連携。

```swift
@Generable
struct Recipe {
    @Guide(description: "料理名")
    var name: String

    @Guide(description: "難易度", .enum(Difficulty.self))
    var difficulty: Difficulty

    @Guide(description: "調理時間（分）", .range(5...120))
    var cookingTimeMinutes: Int

    @Guide(description: "手順のリスト")
    var steps: [String]

    @Guide(description: "カロリー目安", .range(50...2000))
    var estimatedCalories: Int
}
```

**面白い点:**
- 写真を撮るだけで「今ある食材で作れるもの」が分かる
- Tool Calling によりカロリー・栄養情報も自動付与
- `@Generable` の `.range()` で調理時間・カロリーの値域を制約

**技術構成:** Vision + Foundation Models + Tool Calling + HealthKit + WidgetKit

---

### アイデア 5: 「DreamJournal — AI 夢日記分析」

**コンセプト:** 起床直後に音声で夢の内容を録音 → 文字起こし → Foundation Models が夢を構造化分析し、テーマ・感情・シンボルを抽出。長期間のデータから夢のパターンを可視化する。

```swift
@Generable
struct DreamAnalysis {
    @Guide(description: "夢のタイトル（短く象徴的に）")
    var title: String

    @Guide(description: "夢の主要なテーマ")
    var themes: [String]

    @Guide(description: "夢の全体的な感情トーン", .enum(EmotionalTone.self))
    var emotionalTone: EmotionalTone

    @Guide(description: "夢に登場したシンボルとその一般的な解釈")
    var symbols: [DreamSymbol]

    @Guide(description: "夢の内容を整理した短い物語形式の記録")
    var narrative: String
}

@Generable
enum EmotionalTone: String {
    case joyful, anxious, peaceful, confused
    case adventurous, melancholic, fearful, nostalgic
}
```

**面白い点:**
- 起床直後の曖昧な記憶を音声でサッと記録できる
- AI が断片的な夢の内容を物語として再構成
- 夢のプライバシーは最重要 → 完全オンデバイスが必須の最適ユースケース
- `@Generable enum` で感情を有限の選択肢に制約し、統計的分析が可能
- Charts フレームワークで感情トーンの推移・頻出シンボルを可視化

**技術構成:** Speech Framework + Foundation Models + SwiftData + Swift Charts + WidgetKit

---

## 8. まとめ

| 観点 | 評価 |
|---|---|
| **プライバシー** | ★★★★★ — 完全オンデバイス。データがデバイスを離れない |
| **レイテンシ** | ★★★★☆ — ネットワーク不要で高速。ただし初回ロードに時間がかかる |
| **精度** | ★★★☆☆ — 3B モデルの限界。複雑な推論や長文は苦手 |
| **コンテキスト長** | ★★☆☆☆ — 4096 トークンは厳しい制約。長い会話には不向き |
| **開発体験** | ★★★★★ — Swift ネイティブ。@Generable による型安全な構造化出力が秀逸 |
| **可用性** | ★★★☆☆ — Apple Intelligence 対応デバイスのみ。フォールバック設計が必須 |

### Foundation Models が最も輝くパターン

1. **短いテキストの変換・構造化** — 入出力が小さく、4096 トークン制約に収まる
2. **@Generable を活かした型安全な構造化出力** — 他のプラットフォームにない独自の強み
3. **プライバシーが最重要** — 健康、日記、個人写真など
4. **オフライン動作が必要** — 旅行中、機内、通信環境が悪い場所
5. **他の Apple フレームワークとの連携** — Vision + Speech + Foundation Models の組み合わせ

### 参考リンク

- [Apple Developer Documentation — Foundation Models](https://developer.apple.com/documentation/FoundationModels)
- [WWDC25: Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/)
- [WWDC25: Deep dive into the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/301/)
- [WWDC25: Explore prompt design & safety](https://developer.apple.com/videos/play/wwdc2025/248/)
- [WWDC25: Code-along — Bring on-device AI to your app](https://developer.apple.com/videos/play/wwdc2025/259/)
- [TN3193: Managing the context window](https://developer.apple.com/documentation/technotes/tn3193-managing-the-on-device-foundation-model-s-context-window)
- [Apple ML Research: Updates to Foundation Language Models](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates)
