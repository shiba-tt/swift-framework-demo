# App Intents 調査レポート

## 1. App Intents とは

App Intents は iOS 16 で導入された Swift フレームワークで、アプリの機能をシステム全体に公開し、Siri・Shortcuts・Spotlight・ウィジェット・Control Center など多数のシステムコンポーネントから利用可能にする仕組みである。

iOS 18 / Apple Intelligence の登場により、App Intents は単なる「ショートカット用 API」から **アプリと AI を繋ぐ最重要フレームワーク** へと進化した。

**核心コンセプト:** 「アプリの機能を "動詞" と "名詞" で宣言的に記述し、システム全体から呼び出し可能にする」

---

## 2. 基本アーキテクチャ

### 3つの構成要素

| 要素 | 役割 | 例 |
|---|---|---|
| **Intent (動詞)** | アプリが実行できるアクション | 「ノートを開く」「ワークアウトを開始」「商品をカートに追加」 |
| **Entity (名詞 - 動的)** | 動的なデータ型。個別のコンテンツを表す | 特定のノート、特定のワークアウト、特定のレシピ |
| **AppEnum (名詞 - 静的)** | 固定の選択肢を持つ列挙型 | カテゴリ一覧、優先度レベル、テーマカラー |

### コード例: 基本的な App Intent

```swift
import AppIntents

struct OpenRecipeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Recipe"
    static var description = IntentDescription("Opens a specific recipe in the app")

    @Parameter(title: "Recipe")
    var recipe: RecipeEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        // レシピ画面を開く
        NavigationManager.shared.navigate(to: recipe)
        return .result()
    }
}
```

### コード例: App Entity

```swift
struct RecipeEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recipe")
    static var defaultQuery = RecipeQuery()

    var id: UUID
    var name: String
    var category: String
    var cookingTime: Int // 分

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(category) - \(cookingTime)分")
    }
}
```

### コード例: App Shortcuts Provider

```swift
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenRecipeIntent(),
            phrases: [
                "Open \(.applicationName) recipe",
                "\(.applicationName) でレシピを開いて"
            ],
            shortTitle: "Open Recipe",
            systemImageName: "book"
        )
    }
}
```

---

## 3. 統合可能なシステムコンポーネント

App Intents は以下のシステム全体と統合できる:

### 3.1 Siri & Apple Intelligence

- **自然言語でのアクション実行**: 「Hey Siri、〇〇アプリで△△して」
- **Assistant Schemas**: Apple がドメインごとに事前学習したスキーマに準拠することで、Siri が自然言語をより正確に理解
- **コンテキスト学習**: iOS 18 では、ユーザーの使用状況（時間帯、場所、前後のアクション等）を学習し、適切なタイミングで Intent をプロアクティブに提案
- **オンスクリーンコンテンツ連携**: `NSUserActivity` で画面上のエンティティと紐づけ、Siri / ChatGPT が画面内容について質問に回答

### 3.2 Spotlight

- **App Shortcuts の表示**: Spotlight 検索結果にアプリのアクションが直接表示
- **IndexedEntity**: `CSSearchableIndex` にエンティティをインデックス化し、Spotlight のセマンティック検索に対応
- **インタラクティブスニペット**: Spotlight 上で直接操作可能（お気に入り登録、トグル操作など）

### 3.3 ウィジェット (Interactive Widgets)

- **インタラクティブウィジェット**: ウィジェット内の `Button` や `Toggle` に App Intent を紐づけ、アプリを開かずに操作
- **WidgetKit との統合**: `IntentConfiguration` でウィジェットの設定を App Intent で制御

```swift
// ウィジェット内のインタラクティブボタン
Button(intent: ToggleFavoriteIntent(recipe: recipe)) {
    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
}
```

### 3.4 Live Activities & Dynamic Island

- **リアルタイム操作**: Live Activity 内に `Button` / `Toggle` を配置し、App Intent で処理
- **LiveActivityIntent**: アプリを起動せずに Live Activity の状態を更新

### 3.5 Control Center

- **カスタムコントロール**: Control Center にアプリ固有のトグルやボタンを追加
- **ControlWidget** + App Intent で、コントロールセンターから直接アプリ機能を実行

### 3.6 Action Button & Apple Pencil Pro

- **iPhone 15 Pro 以降**: Action Button に App Intent を割り当て可能
- **Apple Pencil Pro**: スクイーズ操作に App Intent を割り当て可能

### 3.7 Visual Intelligence (iOS 18.2+)

- **カメラでの視覚的検索**: アプリの検索機能を Visual Intelligence に統合
- 画面上の物体やテキストをアプリの機能で処理

---

## 4. Assistant Schemas (iOS 18)

Apple Intelligence と連携するための事前定義されたスキーマ。12のドメインが提供されている:

| ドメイン | 主なアクション例 |
|---|---|
| **Books** | 本を開く、ブックマークする |
| **Browser** | URL を開く、タブを管理 |
| **Camera** | 写真を撮る、ビデオ録画 |
| **Journal** | エントリを作成、日記を開く |
| **Mail** | メールを送信、検索 |
| **Photos** | 写真を検索、アルバム管理 |
| **Presentations** | スライドを開く、プレゼン開始 |
| **Spreadsheets** | データを開く、概要を取得 |
| **Word Processor** | ドキュメントを開く、内容を提案 |
| **その他** | (順次拡大中) |

### Schema の使用例

```swift
@AssistantIntent(schema: .photos.search)
struct SearchPhotosIntent: AppIntent {
    @Parameter(title: "Search Criteria")
    var criteria: StringSearchCriteria

    func perform() async throws -> some IntentResult & ReturnsValue<[PhotoEntity]> {
        let results = PhotoStore.shared.search(criteria)
        return .result(value: results)
    }
}
```

スキーマに準拠することで、Siri は事前学習済みモデルを使い、自然言語からのマッピング精度が大幅に向上する。

---

## 5. iOS 17–18 で追加された主な新機能

| バージョン | 新機能 |
|---|---|
| **iOS 17** | Spotlight のインタラクティブスニペット、`IndexedEntity`、Transferable 対応 |
| **iOS 18** | Assistant Schemas (12ドメイン)、Apple Intelligence 統合、Visual Intelligence、コンテキスト学習 |
| **iOS 18.2** | Image Playground 統合、Visual Intelligence の強化 |
| **WWDC25** | `UndoableIntent`、Entity View Annotations、Deferred Properties、インタラクティブスニペット強化 |

### 注目の新機能

#### Transferable (クロスアプリデータ変換)
```swift
// エンティティを他のアプリで利用可能な形式に変換
extension TrailEntity: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { trail in
            trail.generatePDF()
        }
    }
}
```

#### UndoableIntent (WWDC25)
```swift
struct AddToCartIntent: AppIntent, UndoableIntent {
    func perform() async throws -> some IntentResult {
        Cart.shared.add(item)
        return .result()
    }

    func undo() async throws {
        Cart.shared.remove(item)
    }
}
```

---

## 6. App Intents の設計原則

Apple が推奨するベストプラクティス:

1. **「アプリのすべての機能を Intent にする」**: iOS 18 以降、主要機能だけでなく、アプリのあらゆるアクションを Intent 化することが推奨
2. **パラメータは柔軟に**: 必須パラメータを最小限にし、Siri が補完できるようにする
3. **返り値を活用**: Intent の結果を返すことで、Shortcuts でのチェーン（連鎖）が可能
4. **エラーハンドリング**: ユーザーフレンドリーなエラーメッセージを `LocalizedStringResource` で提供
5. **再利用性**: 同じ Intent をウィジェット・Siri・Shortcuts・Control Center で共有

---

## 7. App Intents 活用アイデア

以下に、App Intents の特性を最大限に活かした革新的なアプリケーション案を提案する。

---

### アイデア 1: 「AI 習慣コーチ」— Siri が生活パターンを学習して提案する習慣管理アプリ

**コンセプト:** 日常の習慣（運動、読書、水分摂取、瞑想等）を App Intent として定義し、iOS のコンテキスト学習機能を通じて Siri が最適なタイミングでアクションを提案してくれる習慣管理アプリ。

**仕組み:**
- 各習慣を `AppIntent` として定義（例: `LogWaterIntakeIntent`, `StartMeditationIntent`, `LogReadingIntent`）
- ユーザーが習慣を完了するたびに Intent を実行 → iOS が使用パターン（時間帯、場所、前後のアクション）を自動学習
- 数日間の使用後、Siri が「そろそろ水を飲みませんか？」「今日はまだ読書をしていませんよ」とプロアクティブに提案
- **Lock Screen ウィジェット**: 今日の習慣達成状況をリング表示、タップで即完了記録
- **Live Activity**: 現在進行中の習慣（瞑想タイマー等）をリアルタイム表示
- **Control Center**: よく使う習慣のトグルボタンを配置

**App Intents が最適な理由:**
- iOS のコンテキスト学習が自動的にユーザーの行動パターンを把握
- アプリを開かずに Siri・ウィジェット・Control Center から習慣を記録
- Shortcuts で「おはようルーティン」（天気確認 → 水分記録 → ストレッチ開始）を組み立て可能
- Action Button に「最もよく使う習慣」を割り当て、物理ボタン一押しで記録

**差別化ポイント:**
- 他の習慣アプリと異なり、アプリ側でリマインダーロジックを構築する必要がない。iOS 自体がユーザーの行動を学習し最適なタイミングで提案する

---

### アイデア 2: 「声だけ料理アシスタント」— ハンズフリーで使えるレシピアプリ

**コンセプト:** 料理中に手が汚れていてもスマホに触れず、Siri への音声コマンドだけでレシピの操作を完結できる料理アプリ。

**仕組み:**
- レシピの各工程を `AppEntity` として定義し、ステップごとの操作を Intent 化
  - `NextStepIntent`: 「次のステップ」
  - `RepeatStepIntent`: 「もう一回」
  - `StartTimerIntent`: 「タイマー3分」
  - `SearchRecipeIntent`: 「鶏肉のレシピを探して」(Assistant Schema `.books.openBook` に類似のパターン)
  - `AdjustServingsIntent`: 「4人分に変更して」→ 分量を自動再計算
- **Live Activity**: 現在のステップと次のステップをロック画面に常時表示、タイマーのカウントダウンも表示
- **Dynamic Island**: タイマー残り時間とステップ番号を常時表示
- **Interactive Widget**: 次のステップへの進行ボタンと現在の工程写真を表示

**App Intents が最適な理由:**
- 「Hey Siri、次のステップ」「Hey Siri、タイマー何分？」だけで操作完結
- Live Activity + Dynamic Island でレシピの進行状況を常時確認
- Shortcuts で「夕食の準備」（レシピ検索 → 買い物リスト生成 → 調理開始）を一気通貫
- UndoableIntent で「前のステップに戻って」も対応可能

**技術的ポイント:**
```swift
@AssistantIntent(schema: .system.search)
struct SearchRecipeIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Recipe"

    @Parameter(title: "Ingredient")
    var ingredient: String

    func perform() async throws -> some IntentResult & ReturnsValue<[RecipeEntity]> {
        let recipes = RecipeStore.shared.search(by: ingredient)
        return .result(value: recipes)
    }
}

struct NextStepIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Next Step"

    func perform() async throws -> some IntentResult {
        CookingSession.shared.advanceToNextStep()
        return .result()
    }
}
```

---

### アイデア 3: 「Spotlight で完結するミニ家計簿」— アプリを開かない家計管理

**コンセプト:** 支出の記録から確認まで、Spotlight と Siri だけで完結する超軽量な家計簿アプリ。アプリを開く必要がほとんどない。

**仕組み:**
- **Spotlight から記録**: 検索バーに「ランチ 850円」と入力するだけで支出が記録される
  - `IndexedEntity` でカテゴリ・金額・日付をインデックス化
  - Spotlight のインタラクティブスニペットで「食費」「交通費」などカテゴリを即選択
- **Siri で記録**: 「コンビニで 350 円使った」→ 自動的にカテゴリ推定して記録
- **Siri で確認**: 「今月いくら使った？」「今週の食費は？」→ 即座に回答
- **ウィジェット**: 今月の支出サマリー（カテゴリ別の円グラフ）をホーム画面に表示
- **Control Center**: 「支出を記録」ボタンを配置、ワンタップで入力モードへ
- **Apple Pencil Pro**: スクイーズで支出入力画面を即起動

**App Intents が最適な理由:**
- IndexedEntity + Spotlight で「検索 = 入力」の新しい UX を実現
- インタラクティブスニペットでアプリを開かず Spotlight 上で操作が完結
- Siri の自然言語解析で「コンビニ」→「食費」のカテゴリ自動推定
- Shortcuts で月末レポートを PDF 化し、Transferable で家計簿データを他のアプリ（Numbers 等）へ渡す

**差別化ポイント:**
- 従来の家計簿アプリは「アプリを開いて入力」が習慣化のハードル。App Intents により入力の手間をゼロに近づける

---

### アイデア 4: 「コンテキスト DJ」— 状況に応じて自動プレイリストを生成する音楽アプリ

**コンセプト:** ユーザーの現在のコンテキスト（時間帯、場所、天気、移動状態、直前のアクティビティ）を学習し、最適なプレイリストを自動生成・提案する音楽アプリ。

**仕組み:**
- 各プレイリスト・曲を `AppEntity` として定義し、`IndexedEntity` でインデックス化
- App Intents:
  - `PlayContextualMusicIntent`: 現在の状況に最適な音楽を自動再生
  - `SetMoodIntent(mood: MoodEnum)`: 「集中モード」「リラックス」「ワークアウト」など気分を指定
  - `DiscoverSimilarIntent(song: SongEntity)`: 「この曲に似た曲を探して」
- iOS のコンテキスト学習を活用:
  - 月曜朝の通勤時 → アップテンポな曲
  - 夜 22 時以降 → チルアウト系
  - ジムの近く → ワークアウトプレイリスト
  - 雨の日 → ジャズやローファイ
- **Dynamic Island**: 現在の曲とコンテキストタグ（"通勤モード"等）を表示
- **Action Button**: 「コンテキスト再生」をワンプッシュで起動
- **Visual Intelligence**: 目の前のポスターやジャケット写真をカメラで撮ると関連音楽を検索

**App Intents が最適な理由:**
- コンテキスト学習によりユーザーの好みとシチュエーションの関係性を自動把握
- 「Hey Siri、集中できる音楽かけて」「Hey Siri、ドライブ用の音楽」で即再生
- Shortcuts で「朝のルーティン」に組み込み（アラーム停止 → 天気確認 → 朝用音楽再生）
- Live Activity で再生中の情報をロック画面に常時表示

---

### アイデア 5: 「学習カード・エブリウェア」— あらゆるシステム面に溶け込むフラッシュカードアプリ

**コンセプト:** フラッシュカード（暗記カード）をシステムのあらゆる面に展開し、スキマ時間を最大限に活用する学習アプリ。

**仕組み:**
- 各カードを `AppEntity`、カードデッキを `AppEntity` として定義
- **Spotlight**: 検索結果に学習カードが直接表示。インタラクティブスニペットで「知ってる / 知らない」をその場で回答
- **ウィジェット**: ロック画面に「今日の1問」を表示。ウィジェットのボタンで回答して次のカードへ
- **Live Activity**: 学習セッション中に進捗バーと現在の正答率を表示
- **Siri**:
  - 「英単語のテストをして」→ Siri が音声で出題、ユーザーが回答
  - 「今日覚えた単語は何個？」→ 学習統計を回答
- **Control Center**: 「クイック学習」ボタン。タップで即 5 問出題
- **Action Button**: 長押しで「ランダム出題」モード起動
- **Apple Watch**: watchOS の App Intent 対応で、手首から学習

**App Intents が最適な理由:**
- 1 つの Intent（`AnswerCardIntent`）をウィジェット・Siri・Spotlight・Control Center 全てで再利用
- UndoableIntent で「さっきの回答、間違えた。取り消して」に対応
- Transferable で他の学習アプリからカードデータをインポート
- コンテキスト学習で、通勤中・昼休みなど学習しやすい時間帯に Siri がプロアクティブに出題

**差別化ポイント:**
- 従来の暗記アプリは「アプリを開いて学習」。本アプリはシステムの隙間に溶け込み、意識せずに学習機会が生まれる
- 間隔反復（Spaced Repetition）アルゴリズムと iOS のコンテキスト学習の組み合わせで最適なタイミングに出題

```swift
struct AnswerCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Answer Card"

    @Parameter(title: "Card")
    var card: FlashCardEntity

    @Parameter(title: "Known")
    var isKnown: Bool

    func perform() async throws -> some IntentResult & ReturnsValue<FlashCardEntity> {
        let next = StudyEngine.shared.recordAnswer(card: card, known: isKnown)
        return .result(value: next) // 次のカードを返す
    }
}
```

---

## 8. まとめ

### App Intents の本質的価値

App Intents は「アプリを開かなくてもアプリの機能が使える世界」を実現するフレームワークである。

| 観点 | 従来のアプリ | App Intents 活用アプリ |
|---|---|---|
| **操作起点** | アプリアイコンをタップ | Siri、Spotlight、ウィジェット、Control Center、Action Button… |
| **UI の所在** | アプリ内に閉じる | システム全体に分散 |
| **発見性** | App Store / ホーム画面 | Spotlight 検索、Siri 提案、コンテキスト提案 |
| **AI 連携** | 独自実装が必要 | Apple Intelligence が自動で学習・提案 |
| **クロスアプリ連携** | URL Scheme / Deep Link | Shortcuts チェーン、Transferable |

### App Clips との比較

| 項目 | App Clips | App Intents |
|---|---|---|
| **目的** | インストール不要の即時体験 | アプリ機能のシステム統合 |
| **前提条件** | フルアプリ + 物理インフラ（NFC等） | アプリ単体で完結 |
| **ユーザー接点** | 物理世界（NFC, QR）が中心 | OS のあらゆる面 |
| **AI 連携** | なし | Apple Intelligence と深く統合 |
| **実装コスト** | 別ターゲット + サーバー設定 | 既存コードに `AppIntent` を追加 |
| **即効性** | 高い（開発者としての実装コストが高め） | 高い（少ないコードで多面的に露出） |

**結論:** App Intents は、実装コストが低く、アプリ単体で完結し、iOS のあらゆるシステムコンポーネントに露出できる。Apple Intelligence との統合により、今後のiOS アプリ開発において最も重要なフレームワークの一つと言える。

---

## 参考資料

- [Apple Developer Documentation - App Intents](https://developer.apple.com/documentation/appintents)
- [Apple Developer Documentation - App Intent Domains](https://developer.apple.com/documentation/appintents/app-intent-domains)
- [WWDC24 - Bring your app to Siri](https://developer.apple.com/videos/play/wwdc2024/10133/)
- [WWDC24 - What's new in App Intents](https://developer.apple.com/videos/play/wwdc2024/10134/)
- [WWDC24 - Bring your app's core features to users with App Intents](https://developer.apple.com/videos/play/wwdc2024/10210/)
- [WWDC24 - Design App Intents for system experiences](https://developer.apple.com/videos/play/wwdc2024/10176/)
- [WWDC25 - Get to know App Intents](https://developer.apple.com/videos/play/wwdc2025/244/)
- [WWDC25 - Explore new advances in App Intents](https://developer.apple.com/videos/play/wwdc2025/275/)
- [SwiftLee - App Intents Spotlight integration](https://www.avanderlee.com/swiftui/app-intents-spotlight-integration-using-shortcuts/)
- [Superwall - App Intents Field Guide](https://superwall.com/blog/an-app-intents-field-guide-for-ios-developers/)
- [Create with Swift - App Intents with Control Action](https://www.createwithswift.com/integrating-app-intents-with-control-action/)
- [Create with Swift - Assistant Schemas](https://www.createwithswift.com/creating-app-intents-using-assistant-schemas/)
- [Simform - App Intents & Apple Intelligence](https://medium.com/simform-engineering/app-intents-apple-intelligence-unlocking-the-basics-2208bf896e03)
- [Matthew Cassinelli - What's New in App Intents 2024](https://matthewcassinelli.com/?p=34069)
