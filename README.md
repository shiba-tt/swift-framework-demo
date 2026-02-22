# swift-framework-demo

Apple フレームワークを活用した iOS アプリのモック集。各フレームワークの調査資料（`docs/`）に記載されたアイデアをもとに、SwiftUI + MVVM で実装しています。

## アイデア一覧

### AlarmKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | RitualAlarm — 朝のルーティンを段階的に導くアラーム | ✅ 作成済み | `RitualAlarmMock` |
| 2 | CookMaster — マルチタイマー料理アシスタント | ✅ 作成済み | `CookMasterMock` |
| 3 | FocusForge — ポモドーロ×アラームの集中力鍛錬 | ✅ 作成済み | `FocusForgeMock` |
| 4 | MedicineGuard — 絶対に飲み忘れない服薬アラーム | ✅ 作成済み | `MedicineGuardMock` |
| 5 | SleepCraft — 睡眠サイクルに合わせたスマートアラーム | ✅ 作成済み | `SleepCraftMock` |

### App Clips

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | まちなか謎解きアドベンチャー — NFCタグでパズルを解く | ✅ 作成済み | `NazoTownMock` |
| 2 | フードアレルギーセーフティスキャナー — メニュー情報表示 | ⬜ 未作成 | — |
| 3 | AR タイムトラベラー — 過去の姿を現在に重ねて表示 | ⬜ 未作成 | — |
| 4 | ライブ投票・インタラクション — コンサート会場NFC投票 | ⬜ 未作成 | — |
| 5 | 緊急医療情報カード — NFCブレスレットで医療情報表示 | ⬜ 未作成 | — |

### App Intents

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | AI 習慣コーチ — Siriが生活パターンを学習して提案 | ⬜ 未作成 | — |
| 2 | 声だけ料理アシスタント — ハンズフリー操作レシピ | ⬜ 未作成 | — |
| 3 | Spotlight で完結するミニ家計簿 — アプリ不要の家計管理 | ✅ 作成済み | `KakeiboMock` |
| 4 | コンテキスト DJ — 状況に応じた自動プレイリスト生成 | ⬜ 未作成 | — |
| 5 | 学習カード・エブリウェア — システムに溶け込むフラッシュカード | ⬜ 未作成 | — |

### ARKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | AR タイムマシン — 過去と未来の街並みを歩く | ⬜ 未作成 | — |
| 2 | AR 生き物図鑑 — 部屋が水族館・動物園になる | ✅ 作成済み | `NazoWalkMock` |
| 3 | AR シャドウ — 光と影の物理パズルゲーム | ⬜ 未作成 | — |
| 4 | AR ミュージアム — 自分だけの美術館を建築 | ⬜ 未作成 | — |
| 5 | AR フィットネスコーチ — モーションキャプチャでフォーム改善 | ⬜ 未作成 | — |

### AVKit / AVFoundation

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | CineMagic — AI リアルタイム映画フィルター撮影 | ⬜ 未作成 | — |
| 2 | VoiceMorph — リアルタイムボイスチェンジャー | ✅ 作成済み | `VoiceMorphMock` |
| 3 | WatchParty — 離れた友人と同期視聴 | ✅ 作成済み | `WatchPartyMock` |
| 4 | SoundScape — 環境音AI分析・可視化 | ⬜ 未作成 | — |
| 5 | ReelForge — AI ショートムービー自動生成 | ⬜ 未作成 | — |

### Core ML

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | AI フォーム改善コーチ — リアルタイム運動フォーム分析 | ⬜ 未作成 | — |
| 2 | マルチモーダル食事記録 — 写真から自動栄養素記録 | ⬜ 未作成 | — |
| 3 | リアルタイム環境音翻訳機 — 周囲の音を認識 | ⬜ 未作成 | — |
| 4 | 手書きノート AI アシスタント — 手書きメモを構造化 | ⬜ 未作成 | — |
| 5 | パーソナル植物ドクター — 植物の健康状態をAI診断 | ✅ 作成済み | `PlantDoctorMock` |

### CoreAudioKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | SoundForge — モジュラーオーディオ・ワークステーション | ✅ 作成済み | `SoundForgeMock` |
| 2 | PedalBoard — ギタリスト向けAUv3エフェクトボード | ✅ 作成済み | `PedalBoardMock` |
| 3 | SynthLab — ビジュアル・シンセサイザー学習アプリ | ✅ 作成済み | `SynthLabMock` |
| 4 | VoiceStudio — ポッドキャスター向けリアルタイム音声加工 | ✅ 作成済み | `VoiceStudioMock` |
| 5 | AUBazaar — AUv3プラグイン試聴・比較プラットフォーム | ⬜ 未作成 | — |

### EnergyKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | GreenCharge — EV充電最適化×ゲーミフィケーション | ✅ 作成済み | `GreenChargeMock` |
| 2 | GridPulse — 電力グリッドの鼓動を可視化するリビングアート | ✅ 作成済み | `GridPulseMock` |
| 3 | WattWise — 家族で楽しむ節電チャレンジ | ✅ 作成済み | `WattWiseMock` |
| 4 | ThermoShift — AIサーモスタット×快適度の予測最適化 | ✅ 作成済み | `ThermoShiftMock` |
| 5 | GridBeat — 電力市場リアルタイムトラッカー | ✅ 作成済み | `GridBeatMock` |

### EventKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | TimeMap — 時空間スケジュールマップ | ✅ 作成済み | `TimeMapMock` |
| 2 | HabitWeave — 習慣をカレンダーに織り込むトラッカー | ✅ 作成済み | `HabitWeaveMock` |
| 3 | MeetingLens — 会議コスト可視化＆最適化ツール | ✅ 作成済み | `MeetingLensMock` |
| 4 | LifeRewind — カレンダーベースのライフログ＆回顧録 | ✅ 作成済み | `LifeRewindMock` |
| 5 | SyncLife — マルチカレンダー調整＆ファミリーコーディネーター | ✅ 作成済み | `SyncLifeMock` |

### Foundation Models

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | SmartSnap — AI写真アルバムオーガナイザー | ✅ 作成済み | `SmartSnapMock` |
| 2 | VoiceMemo AI — 音声メモ構造化エンジン | ⬜ 未作成 | — |
| 3 | ContextCards — 名刺×AIネットワーキング | ⬜ 未作成 | — |
| 4 | CookSnap — 冷蔵庫の中身からレシピ生成 | ✅ 作成済み | `CookSnapMock` |
| 5 | DreamJournal — AI夢日記分析 | ✅ 作成済み | `DreamJournalMock` |

### Nearby Interaction

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | ProximityParty — 空間認識マルチプレイヤーゲーム | ✅ 作成済み | `ProximityPartyMock` |
| 2 | SoundField — 空間オーディオDJ | ⬜ 未作成 | — |
| 3 | InvisibleWall — 見えない境界線セキュリティ | ⬜ 未作成 | — |
| 4 | BumpShare — 近づけて共有 | ✅ 作成済み | `BumpShareMock` |
| 5 | SpaceCanvas — 空間お絵描きAR | ✅ 作成済み | `SpaceCanvasMock` |

### SensorKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | MindMirror — 日常行動からメンタルヘルスを見守る研究アプリ | ✅ 作成済み | `MindMirrorMock` |
| 2 | TypeGuard — タイピングで見つける神経疾患の兆候 | ✅ 作成済み | `TypeGuardMock` |
| 3 | LightLife — 光環境と生活リズムの関係を解明 | ✅ 作成済み | `LightLifeMock` |
| 4 | SocialPulse — デジタル社会的つながりの健康指標 | ⬜ 未作成 | — |
| 5 | ChronoSense — 24時間の生体リズムを可視化 | ⬜ 未作成 | — |

### WeatherKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | SoraNavi — AI写真撮影スポットアドバイザー | ✅ 作成済み | `SoraNaviMock` |
| 2 | KiseKae — 天気連動バーチャルコーディネーター | ✅ 作成済み | `KiseKaeMock` |
| 3 | TenKi Log — 天気と人生のライフログ | ⬜ 未作成 | — |
| 4 | AmeNige — 分単位リアルタイム雨よけナビ | ✅ 作成済み | `AmeNigeMock` |
| 5 | Hoshi-Zora — 天体観測コンディションスコアラー | ⬜ 未作成 | — |

### WidgetKit

| # | アイデア | 状態 | プロジェクト |
|---|---------|------|------------|
| 1 | MoodBoard Widget — ホーム画面が日記になる | ✅ 作成済み | `MoodBoardMock` |
| 2 | WidgetQuest — ウィジェットだけで遊べるRPG | ✅ 作成済み | `WidgetQuestMock` |
| 3 | ControlDeck — iPhoneをスマートホームリモコン化 | ⬜ 未作成 | — |
| 4 | PixelPet — ウィジェットで育てるデジタルペット | ✅ 作成済み | `PixelPetMock` |
| 5 | LiveBoard — リアルタイムコラボホワイトボード | ⬜ 未作成 | — |

---

## 進捗サマリー

- **アイデア総数:** 70
- **作成済み:** 40 / 70
- **未作成:** 30 / 70
