# Core ML 調査レポート

## 1. Core ML とは

Core ML は Apple が提供するオンデバイス機械学習フレームワークで、iOS / macOS / watchOS / tvOS / visionOS 上で ML モデルの推論を実行する。サーバーにデータを送信する必要がなく、プライバシーを保護しながら高速な推論を実現する。

WWDC25 では、Core ML の上位レイヤーとして **Foundation Models フレームワーク** が発表され、Apple Intelligence を支えるオンデバイス LLM（約 30 億パラメータ）に直接アクセスできるようになった。

**核心コンセプト:** 「デバイス上で完結する高速・プライベートな機械学習推論」

---

## 2. アーキテクチャと実行エンジン

### ハードウェアアクセラレーション

Core ML は Apple Silicon の 3 つのコンピュートユニットを自動的に最適配分する:

| エンジン | 得意な処理 | 特性 |
|---|---|---|
| **Neural Engine (ANE)** | 畳み込み、行列演算などの ML 推論 | 超省電力・高速。FP16 専用 |
| **GPU** | 大規模並列計算、メモリ帯域幅重視のタスク | LLM のデコードなど帯域依存処理に最適 |
| **CPU** | 汎用処理、前後処理 | 柔軟性が高い |

### Neural Engine の性能推移

| チップ | Neural Engine 性能 |
|---|---|
| M1 | 11 TOPS (FP16) |
| M2 / M3 | 15.8 TOPS |
| M4 | 38 TOPS |
| A17 Pro (iPhone 15 Pro) | 35 TOPS |
| A18 Pro (iPhone 16 Pro) | 35 TOPS |

> **TOPS** = Trillion Operations Per Second

### Unified Memory Architecture

Apple Silicon の統合メモリアーキテクチャにより、CPU・GPU・Neural Engine が同一のメモリプールを共有。従来の GPU アーキテクチャ（独立 VRAM）と異なり、大規模モデルのメモリ管理が効率的。M4 Max では最大 546 GB/s の帯域幅を全コンピュートユニットで共有する。

---

## 3. Core ML の主要機能

### 3.1 モデル推論

Core ML がサポートする主なタスク:

| カテゴリ | タスク | 代表的なモデル |
|---|---|---|
| **画像認識** | 物体検出、画像分類、セグメンテーション | YOLO、MobileNet、ResNet |
| **自然言語処理** | 感情分析、テキスト分類、エンティティ抽出 | BERT、GPT-2 |
| **音声** | 音声認識、音声分類 | Whisper |
| **画像生成** | テキストから画像、スタイル変換 | Stable Diffusion |
| **LLM 推論** | テキスト生成、要約、対話 | Llama 3.1, Mistral |
| **姿勢推定** | 人体のポーズ検出 | PoseNet |
| **深度推定** | 単眼深度推定 | DepthAnything |
| **動画解析** | アクション認識 | SlowFast |

### 3.2 モデル変換 (Core ML Tools)

Python の `coremltools` を使い、以下のフレームワークのモデルを `.mlmodel` / `.mlpackage` に変換:

- **PyTorch** (最も一般的)
- **TensorFlow / Keras**
- **ONNX**
- **scikit-learn**
- **XGBoost**

```python
import coremltools as ct

# PyTorch モデルを Core ML に変換
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.ImageType(shape=(1, 3, 224, 224))],
    compute_precision=ct.precision.FLOAT16
)
mlmodel.save("MyModel.mlpackage")
```

### 3.3 モデル圧縮・量子化

大規模モデルをデバイスに載せるための圧縮技術:

| 手法 | 説明 | 最適なエンジン |
|---|---|---|
| **4-bit ブロック単位量子化** | 重みを 4-bit に量子化、精度損失を最小化 | GPU |
| **チャネルグループ単位パレタイゼーション** | 重みをパレット化して圧縮 | Neural Engine |
| **枝刈り (Pruning)** | 不要な接続を除去しスパース化 | Neural Engine |
| **知識蒸留** | 大モデルの知識を小モデルに転移 | 全エンジン |

```python
# 4-bit 量子化の例
import coremltools.optimize as cto

config = cto.coreml.OptimizationConfig(
    global_config=cto.coreml.OpLinearQuantizerConfig(
        mode="linear_symmetric",
        dtype="int4",
        granularity="per_block",
        block_size=32
    )
)
compressed_model = cto.coreml.linear_quantize_weights(model, config)
```

### 3.4 Create ML (オンデバイス学習)

Xcode に統合されたノーコード / ローコードの学習ツール。Swift コードからもプログラマティックに利用可能:

- **画像分類**: 写真をフォルダに分類するだけで学習
- **物体検出**: バウンディングボックスのアノテーションから学習
- **テキスト分類**: 感情分析やスパム検出
- **表形式データ**: 回帰・分類タスク
- **音声分類**: 環境音の識別
- **アクティビティ分類**: 加速度センサーデータからの行動認識
- **スタイル変換**: 画像のアーティスティックな変換

```swift
import CreateML

// Swift コードでモデルを学習
let data = try MLDataTable(contentsOf: trainingDataURL)
let classifier = try MLImageClassifier(trainingData: data, featureColumn: "image", labelColumn: "label")
try classifier.write(to: modelURL)
```

### 3.5 アダプター (Adapters)

iOS 18 / WWDC24 で導入。大規模な事前学習モデルの重みを変更せず、小さなアダプターモジュールを追加して特定タスクに適応:

- 1 つのベースモデル + 複数のアダプター構成が可能
- 例: 画像生成モデルに複数のスタイルアダプターを切り替えて適用
- アプリサイズへの影響が最小限

---

## 4. 関連フレームワーク群

Core ML を中心とした Apple の ML フレームワークエコシステム:

```
┌─────────────────────────────────────────────────────┐
│             Foundation Models (WWDC25)               │
│         オンデバイス LLM (Apple Intelligence)          │
├─────────────────────────────────────────────────────┤
│    Vision    │  Natural Language  │  Speech  │ Sound │
│   画像認識    │     テキスト分析     │  音声認識  │ 音声分類│
├─────────────────────────────────────────────────────┤
│                    Core ML                           │
│              モデル推論エンジン                         │
├─────────────────────────────────────────────────────┤
│      Metal Performance Shaders (MPS)                 │
│            GPU 計算プリミティブ                         │
├─────────────────────────────────────────────────────┤
│  Neural Engine  │      GPU       │       CPU         │
│                 Apple Silicon                        │
└─────────────────────────────────────────────────────┘
```

### 高レベルフレームワーク

| フレームワーク | 役割 |
|---|---|
| **Vision** | 画像分析・物体検出・テキスト認識（OCR）・顔検出・ポーズ推定 |
| **Natural Language** | 言語識別・品詞タグ付け・固有表現抽出・感情分析・文埋め込み |
| **Speech** | 音声のテキスト変換 (STT) |
| **SoundAnalysis** | 環境音の分類（拍手、笑い声、犬の鳴き声等） |
| **Translation** | オンデバイス翻訳 |

これらの高レベルフレームワークは内部的に Core ML を使用しており、Apple が最適化した組み込みモデルで動作する。

---

## 5. Foundation Models フレームワーク (WWDC25)

iOS 26 / macOS Tahoe で導入された、Apple Intelligence のオンデバイス LLM（約 30 億パラメータ）に直接アクセスする新フレームワーク。

### 特徴

| 項目 | 内容 |
|---|---|
| **プライバシー** | 完全オンデバイス実行。データは外部に送信されない |
| **コスト** | 無料。API キーやアカウント不要 |
| **アプリサイズ** | OS 組み込みのため、アプリサイズへの影響ゼロ |
| **オフライン** | ネットワーク不要で動作 |
| **コンテキスト** | 入出力合計 4096 トークン |
| **対応プラットフォーム** | iOS, iPadOS, macOS, visionOS |

### 得意なタスク

- 要約
- エンティティ抽出
- テキスト理解・分類
- テキスト修正・改善
- 短い対話
- クリエイティブなコンテンツ生成

### 不向きなタスク

- 世界知識を要するタスク（百科事典的な質問回答）
- 高度な推論（数学的証明、複雑なロジック）
- 長文生成

### Guided Generation (`@Generable`)

Foundation Models の中核機能。Swift の型システムと統合され、モデル出力を型安全な Swift 構造体に変換:

```swift
import FoundationModels

@Generable
struct MovieReview {
    @Guide(description: "映画のタイトル")
    var title: String

    @Guide(description: "1から5のスコア", .range(1...5))
    var score: Int

    @Guide(description: "レビューの感情", .anyOf(["positive", "negative", "neutral"]))
    var sentiment: String

    @Guide(description: "主な良い点を3つ", .count(3))
    var highlights: [String]
}

let session = LanguageModelSession()
let review: MovieReview = try await session.respond(
    to: "この映画レビューを分析して: '素晴らしい映画体験でした...'",
    generating: MovieReview.self
)
// review.title, review.score, review.sentiment, review.highlights が型安全に取得可能
```

- **制約付きデコーディング**: モデル出力がスキーマに必ず適合する保証
- **ストリーミング**: `PartiallyGenerated` 型で部分的な生成結果をリアルタイムに SwiftUI に反映
- **動的スキーマ**: ランタイムでスキーマを動的に構築可能

### Tool Calling

モデルがアプリ内のコードを自律的に呼び出す仕組み:

```swift
struct FindRestaurantTool: Tool {
    let name = "findRestaurants"
    let description = "指定された料理ジャンルと場所のレストランを検索"

    @Generable
    struct Arguments {
        @Guide(description: "料理のジャンル")
        var cuisine: String
        @Guide(description: "検索する場所")
        var location: String
    }

    func call(arguments: Arguments) async throws -> some ToolOutput {
        let results = RestaurantService.search(
            cuisine: arguments.cuisine,
            location: arguments.location
        )
        return results
    }
}

// セッション初期化時にツールを登録
let session = LanguageModelSession(tools: [FindRestaurantTool()])
```

- Guided Generation 上に構築されており、ツール名や引数の型安全性が保証
- 並列・直列のツール呼び出しを自動的に最適化

---

## 6. パフォーマンスと制約

### オンデバイス推論のベンチマーク

| モデル / タスク | デバイス | 性能 |
|---|---|---|
| **画像分類 (MobileNet)** | iPhone | ~20ms / 推論 |
| **物体検出 (YOLOv8)** | iPhone | 30+ FPS リアルタイム |
| **Llama-3.1-8B (4-bit量子化)** | M1 Max | ~33 tokens/sec |
| **Stable Diffusion (画像生成)** | M1 | ~30秒 / 画像 |

### 制約・注意点

| 制約 | 詳細 |
|---|---|
| **Neural Engine の非公開性** | ANE の内部仕様は非公開。最適化は試行錯誤が必要 |
| **FP16 のみ (ANE)** | ANE は FP16 専用。学習（FP32 必要）には使えない |
| **Foundation Models のコンテキスト** | 入出力合計 4096 トークン |
| **Foundation Models の知識制限** | 世界知識や高度推論は不向き |
| **モデルサイズ** | デバイスのストレージ・メモリに制約あり |
| **旧デバイスの制限** | Neural Engine 非搭載の旧デバイスでは CPU / GPU のみ |
| **Apple Intelligence 対象外デバイス** | Foundation Models は Apple Intelligence 対応デバイスのみ (A17 Pro 以降) |

---

## 7. 実世界の活用事例

| カテゴリ | 活用例 |
|---|---|
| **写真アプリ** | シーン認識、人物分類、検索（「ビーチの写真」「犬」等） |
| **ヘルスケア** | 皮膚疾患の画像分類、心拍データの異常検知 |
| **小売** | 商品の視覚的類似検索、バーチャル試着 |
| **自動車** | 車体損傷の部位特定・見積もり自動化 |
| **料理** | 食材の画像認識、カロリー推定 |
| **スポーツ** | スケートボードのトリック認識、フォーム分析 |
| **ファッション** | 衣服スタイルの自動分類・コーディネート提案 |
| **アクセシビリティ** | 画像の音声説明生成（視覚障害者支援） |
| **ワイン** | ラベル認識 → OCR → ヴィンテージ情報 → ペアリング提案 |

---

## 8. Core ML 活用アイデア

以下に、Core ML / Foundation Models の特性を最大限に活かした革新的なアプリケーション案を提案する。

---

### アイデア 1: 「AIフォーム改善コーチ」— リアルタイムで運動フォームを分析・改善する

**コンセプト:** カメラで自分のスポーツフォーム（ゴルフスイング、ランニング、筋トレ等）を撮影すると、Core ML の姿勢推定モデルがリアルタイムで骨格を検出し、理想のフォームとの差分を解析。Foundation Models がコーチのように自然言語で改善アドバイスを生成する。

**仕組み:**
- **Vision + Core ML**: カメラフィードから `VNDetectHumanBodyPoseRequest` でリアルタイムに 19 の関節点を検出
- **カスタム Core ML モデル**: 関節角度の時系列データからフォームの質を 0-100 でスコアリング
  - Create ML のアクティビティ分類で「良いフォーム / 悪いフォーム」のパターンを学習
- **Foundation Models**: スコアと関節データから自然言語のアドバイスを生成
  ```
  「膝の角度が浅すぎます（現在 145°、理想は 120°）。
   もう少し深く曲げることで、ハムストリングスへの負荷が適切になります。」
  ```
- **スロー再生 + AR オーバーレイ**: 理想の骨格ラインを半透明で重ね、自分のフォームとの差を視覚化
- **App Intents 連携**: 「Hey Siri、スクワットのフォームチェックして」で即起動

**技術的ポイント:**
```swift
// 姿勢推定 + フォーム分析パイプライン
let poseRequest = VNDetectHumanBodyPoseRequest()
let handler = VNImageRequestHandler(cvPixelBuffer: frame)
try handler.perform([poseRequest])

if let observation = poseRequest.results?.first {
    let kneeAngle = calculateAngle(
        hip: observation.recognizedPoint(.rightHip),
        knee: observation.recognizedPoint(.rightKnee),
        ankle: observation.recognizedPoint(.rightAnkle)
    )
    // Core ML モデルでフォーム品質を予測
    let score = try formModel.prediction(jointAngles: jointData)

    // Foundation Models でアドバイス生成
    @Generable struct FormAdvice {
        @Guide(description: "改善ポイント", .count(3))
        var improvements: [String]
        @Guide(description: "総合スコア", .range(0...100))
        var overallScore: Int
    }
}
```

**差別化ポイント:**
- パーソナルトレーナーの料金は 1 時間 5,000〜10,000 円。このアプリならオンデバイスで無料・無制限に利用可能
- オフラインで動作するため、ジムや屋外でも通信環境を気にせず使える
- 動画データがサーバーに送信されないため、プライバシーが完全に保護される

---

### アイデア 2: 「マルチモーダル食事記録」— 写真を撮るだけでカロリー・栄養素を自動記録

**コンセプト:** 食事の写真を撮るだけで、料理名・カロリー・栄養素（PFC）を自動推定し、食事記録を完全自動化するアプリ。手入力のストレスをゼロにする。

**仕組み:**
- **カスタム Core ML モデル（画像分類）**: 料理の種類を分類（和食 200 種、洋食 150 種、中華 100 種、etc.）
  - Create ML で食事画像データセットを学習
  - 物体検出モデルで 1 枚の写真から複数の皿を個別認識
- **Vision (OCR)**: メニュー写真やパッケージの栄養表示を自動テキスト抽出
- **Foundation Models**: 料理名と量から栄養素を推定し、構造化データとして出力
  ```swift
  @Generable struct MealAnalysis {
      @Guide(description: "検出された料理リスト")
      var dishes: [DishInfo]
      @Guide(description: "合計カロリー(kcal)", .range(0...5000))
      var totalCalories: Int
      @Guide(description: "食事へのコメント")
      var healthAdvice: String
  }

  @Generable struct DishInfo {
      var name: String
      @Guide(description: "推定カロリー(kcal)", .range(0...3000))
      var calories: Int
      @Guide(description: "タンパク質(g)", .range(0...200))
      var protein: Double
      @Guide(description: "脂質(g)", .range(0...200))
      var fat: Double
      @Guide(description: "炭水化物(g)", .range(0...500))
      var carbs: Double
  }
  ```
- **ウィジェット**: 今日の摂取カロリーと PFC バランスをリング表示
- **App Intents**: 「今日何カロリー食べた？」→ Siri が即回答

**差別化ポイント:**
- 既存の食事記録アプリは手入力が面倒で続かない。写真 1 枚で完結するため継続率が飛躍的に向上
- Foundation Models の Guided Generation で栄養素データが型安全に出力される（ハルシネーション防止）
- 全てオンデバイスのため、食事データという極めてプライベートな情報がサーバーに送られない

---

### アイデア 3: 「リアルタイム環境音翻訳機」— 周囲の音を認識してコンテキストを提供

**コンセプト:** デバイスのマイクで周囲の環境音をリアルタイム分析し、聴覚障害者や異文化環境にいる人に「今何が起きているか」をテキストと視覚で伝えるアクセシビリティアプリ。

**仕組み:**
- **SoundAnalysis + カスタム Core ML モデル**: 環境音を分類
  - 内蔵の `SNClassifySoundRequest` で 300 種以上の音を認識（ドアベル、犬の鳴き声、サイレン、拍手等）
  - カスタムモデルで業務特化の音（工場の機械音、医療機器のアラーム等）も追加
- **Speech Framework**: 周囲の会話をリアルタイム文字起こし + 翻訳
- **Foundation Models**: 複数の音声情報を統合し、状況を自然言語で要約
  ```
  「右方向から救急車が接近中。周囲の人が道を空けています。」
  「カフェの BGM（ジャズ）が流れています。隣のテーブルで笑い声が聞こえます。」
  ```
- **Live Activity**: 検出された音のアイコンとコンテキスト要約を常時表示
- **触覚フィードバック**: 重要な音（サイレン、クラクション等）を振動パターンで通知
- **Apple Watch 連携**: 手首の振動で危険音を即座に通知

**技術的ポイント:**
```swift
// 環境音分類パイプライン
let analyzer = SNAudioStreamAnalyzer(format: audioFormat)
let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
try analyzer.add(request, withObserver: self)

// 結果を Foundation Models で状況要約
func request(_ request: SNRequest, didProduce result: SNResult) {
    guard let classification = result as? SNClassificationResult else { return }
    let topResults = classification.classifications.prefix(3)

    @Generable struct SoundContext {
        @Guide(description: "現在の状況の説明")
        var situationDescription: String
        @Guide(description: "注意レベル", .anyOf(["safe", "caution", "danger"]))
        var alertLevel: String
    }
}
```

**社会的インパクト:**
- 日本の聴覚障害者は約 34 万人。環境音の認識は日常安全に直結
- オンデバイスで動作するため、通信環境のない場所でも利用可能
- Live Activity で常時コンテキストを提供し、アプリを開く手間を省く

---

### アイデア 4: 「手書きノート AI アシスタント」— 手書きメモをスキャンして構造化・拡張する

**コンセプト:** 手書きのノートやホワイトボードを撮影すると、Vision の手書き文字認識でテキスト化し、Foundation Models が内容を構造化・要約・拡張する。手書きの自由さとデジタルの検索性・AI 拡張性を両立。

**仕組み:**
- **Vision (手書き OCR)**: `VNRecognizeTextRequest` で手書き文字をテキスト変換（日本語対応）
- **Vision (図形検出)**: 手書きの矢印、囲み、下線を検出し、構造（階層、関係性）を推定
- **カスタム Core ML モデル**: ノートのレイアウト分類（リスト、マインドマップ、フローチャート、表等）
- **Foundation Models**: テキスト + 構造情報から以下を生成
  ```swift
  @Generable struct NoteSummary {
      @Guide(description: "ノートのタイトル")
      var title: String
      @Guide(description: "要約（3文以内）")
      var summary: String
      @Guide(description: "抽出されたアクションアイテム")
      var actionItems: [String]
      @Guide(description: "関連するトピックの提案")
      var relatedTopics: [String]
      @Guide(description: "ノートの種類", .anyOf(["meeting", "brainstorm", "lecture", "todo", "other"]))
      var noteType: String
  }
  ```
- **Tool Calling**: 「このメモの内容でカレンダーにイベントを追加して」→ Foundation Models が Tool を呼び出しカレンダー API を実行
- **Spotlight 検索**: IndexedEntity でノート内容をインデックス化し、手書きノートが全文検索可能に

**差別化ポイント:**
- 手書き派のユーザーが「デジタルに転記する手間」をゼロにする
- Foundation Models の Tool Calling で「メモからアクション」まで一気通貫
- 全てオンデバイスで完結するため、会議の機密メモも安心して処理可能

---

### アイデア 5: 「パーソナル植物ドクター」— 植物の健康状態を AI で診断するガーデニングアプリ

**コンセプト:** 観葉植物や家庭菜園の植物をカメラで撮影するだけで、種類の特定・健康状態の診断・病害虫の検出・最適なケア方法のアドバイスを全てオンデバイスで提供するアプリ。

**仕組み:**
- **画像分類モデル (Core ML)**: 数千種の植物を識別
  - Create ML でファインチューニング、またはオープンソースの植物分類モデルを変換
- **物体検出モデル (Core ML)**: 葉の変色、斑点、虫食い、萎れ等の症状を検出
  - 症状ごとにバウンディングボックスで位置を特定
- **Foundation Models**: 植物名 + 検出された症状から診断・ケアアドバイスを生成
  ```swift
  @Generable struct PlantDiagnosis {
      @Guide(description: "植物の名前")
      var plantName: String
      @Guide(description: "健康状態", .anyOf(["healthy", "mild_issue", "serious_issue"]))
      var healthStatus: String
      @Guide(description: "検出された症状")
      var symptoms: [String]
      @Guide(description: "推定される原因")
      var possibleCauses: [String]
      @Guide(description: "推奨されるケア方法")
      var careRecommendations: [String]
      @Guide(description: "次回の水やり推奨日数", .range(1...14))
      var nextWateringDays: Int
  }
  ```
- **ウィジェット**: 登録した植物の水やりスケジュールとヘルススコアを表示
- **App Intents**: 「モンステラの調子はどう？」→ 最新の診断結果を Siri が回答
- **Live Activity**: 水やりタイマー（土壌の乾燥予測に基づく）

**技術的ポイント:**
```swift
// 植物分類 + 症状検出パイプライン
let classifyRequest = VNCoreMLRequest(model: plantClassifier) { request, _ in
    guard let results = request.results as? [VNClassificationObservation] else { return }
    let plantName = results.first?.identifier // "Monstera deliciosa"
}

let symptomRequest = VNCoreMLRequest(model: symptomDetector) { request, _ in
    guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
    // "leaf_spot", "yellowing", "pest_damage" etc.
}

let handler = VNImageRequestHandler(cgImage: photo)
try handler.perform([classifyRequest, symptomRequest])
```

**差別化ポイント:**
- 植物の診断は「見た目」が命。画像分類 + 物体検出の組み合わせで高精度に症状を特定
- オフライン対応により、庭やベランダなど通信環境が不安定な場所でも使える
- Foundation Models の Guided Generation で診断結果が型安全に構造化され、UI に確実にマッピング
- 時系列で撮影データを蓄積し、「3日前と比べて葉の黄変が進行中」のようなトレンド分析も可能

---

## 9. まとめ

### Core ML エコシステムの全体像

Core ML は単体のフレームワークではなく、Apple の ML エコシステム全体の基盤である:

| レイヤー | 役割 | 代表的なAPI |
|---|---|---|
| **Foundation Models** | オンデバイス LLM (テキスト生成・理解) | `LanguageModelSession`, `@Generable` |
| **高レベル API** | ドメイン特化の ML タスク | Vision, NaturalLanguage, Speech, SoundAnalysis |
| **Core ML** | 汎用モデル推論エンジン | `MLModel`, `VNCoreMLRequest` |
| **Create ML** | オンデバイス・ノーコード学習 | `MLImageClassifier`, `MLTextClassifier` |
| **Core ML Tools** | モデル変換・圧縮 (Python) | `coremltools` |

### Core ML の本質的な強み

1. **プライバシー**: データがデバイスから出ない — GDPR / 個人情報保護法への対応が容易
2. **レイテンシ**: ネットワーク往復なし — リアルタイム処理が可能（画像分類 ~20ms）
3. **オフライン**: 通信不要 — いつでもどこでも動作
4. **コスト**: サーバー不要 — API 呼び出し料金ゼロ
5. **Foundation Models**: OS 組み込み LLM — アプリサイズ増加ゼロ、利用料金ゼロ

### Foundation Models が変えるもの

WWDC25 で発表された Foundation Models フレームワークにより、これまで「サーバー側 LLM が必要」だった多くのタスクがオンデバイスで完結可能になった。特に Guided Generation（`@Generable`）による **型安全な構造化出力** は、従来の LLM API にはない Swift ならではの強力な機能である。

**結論:** Core ML + Foundation Models の組み合わせは、「画像認識・音声分析などの知覚 AI」と「テキスト理解・生成の言語 AI」を統合し、サーバーレス・プライバシー保護・ゼロコストで高度な AI 機能を iOS アプリに組み込む最も実用的な手段である。

---

## 参考資料

- [Apple Developer - Core ML Overview](https://developer.apple.com/machine-learning/core-ml/)
- [Apple Developer Documentation - Core ML](https://developer.apple.com/documentation/coreml)
- [Apple Developer Documentation - Foundation Models](https://developer.apple.com/documentation/FoundationModels)
- [WWDC24 - Deploy machine learning and AI models on-device with Core ML](https://developer.apple.com/videos/play/wwdc2024/10161/)
- [WWDC24 - Bring your machine learning and AI models to Apple silicon](https://developer.apple.com/videos/play/wwdc2024/10159/)
- [WWDC25 - Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/)
- [WWDC25 - Deep dive into the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/301/)
- [Apple ML Research - On Device Llama 3.1 with Core ML](https://machinelearning.apple.com/research/core-ml-on-device-llama)
- [Apple ML Research - Deploying Transformers on the Neural Engine](https://machinelearning.apple.com/research/neural-engine-transformers)
- [Apple ML Research - Foundation Models 2025 Updates](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates)
- [hollance/neural-engine - Everything about the Apple Neural Engine](https://github.com/hollance/neural-engine)
- [SwiftLee - App Intents Spotlight integration](https://www.avanderlee.com/swiftui/app-intents-spotlight-integration-using-shortcuts/)
- [Superwall - App Intents Field Guide](https://superwall.com/blog/an-app-intents-field-guide-for-ios-developers/)
- [Zignuts - Future of On-Device AI in iOS](https://www.zignuts.com/blog/future-on-device-ai-ios-coreml-create-ml)
- [AzamSharp - Ultimate Guide to Foundation Models](https://azamsharp.com/2025/06/18/the-ultimate-guide-to-the-foundation-models-framework.html)
