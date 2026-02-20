# App Clips 調査レポート

## 1. App Clips とは

App Clips は、iOS アプリの軽量バージョンであり、ユーザーがアプリ全体をダウンロードせずに特定の機能を即座に利用できる仕組みである。iOS 14 で導入され、iOS 17 以降ではさらに機能が強化されている。

**核心コンセプト:** 「必要な瞬間に、必要な機能だけを、インストール不要で提供する」

---

## 2. 起動方法 (Invocation)

App Clips は以下の方法でユーザーに提示・起動される:

| 起動方法 | 説明 |
|---|---|
| **App Clip コード** | Apple 独自のビジュアルコード（NFC 内蔵 or スキャンのみ） |
| **NFC タグ** | iPhone をかざすだけで起動 |
| **QR コード** | カメラでスキャン |
| **Safari / Safari View Controller** | スマートバナーからの起動 |
| **iMessage リンク** | メッセージ内の共有リンク |
| **Apple Maps** | 地図上のプレイスカードから起動 |
| **Spotlight 検索** | 検索結果から起動 |
| **他のアプリからの Link** | SwiftUI の `Link` ビューや `UIApplication.open` から直接起動可能 |

起動時には「App Clip カード」が表示され、アプリの概要と「開く」ボタンが提示される。ユーザーが開くことを選択すると、App Clip バイナリがダウンロードされ即座に起動する。

**重要:** フルアプリがすでにインストールされている場合、App Clip の代わりにフルアプリが開かれる。

---

## 3. サイズ制限

App Clips にはサイズ制限があり、iOS バージョンによって異なる:

| iOS バージョン | デジタル起動 | 物理起動 (NFC / QR / App Clip コード) |
|---|---|---|
| iOS 14–15 | 10 MB | 10 MB |
| iOS 16 | 15 MB | 15 MB |
| **iOS 17+** | **50 MB** | **15 MB** |

- デジタル起動 (Safari リンク、iMessage 等) では最大 50 MB
- 物理起動 (NFC タグ、QR コード等) では 15 MB に制限（外出先での高速起動を保証するため）
- ほぼ空の App Clip は約 115 KB で、開発者が自由に使える容量が大きい

### サイズ削減のヒント
- アセットは CDN から遅延読み込みする
- SwiftUI の `AsyncImage` API でプレースホルダー画像を段階的に置き換える
- On-Demand Resources を活用して追加コンテンツを動的にロードする
- コードの共有部分は Swift Package として切り出す

---

## 4. 主な機能と能力

### 利用可能な機能
- **Apple Pay 決済**: ユーザーがカード情報を入力不要で安全に決済
- **Sign in with Apple**: オプションのサインアップ（強制しない設計が推奨）
- **一時的な通知 (Ephemeral Notifications)**: 起動後 最大 8 時間、通知を送信可能
- **位置情報 ("When In Use")**: 使用中のみの位置情報アクセスが可能（翌日 4:00 AM にリセット）
- **カメラ・マイク・Bluetooth**: アクセス許可を取得可能（フルアプリへ権限が引き継がれる）
- **SKOverlay**: App Clip 利用後にフルアプリのダウンロードを促すバナー表示
- **App Group / Shared Container**: フルアプリとのデータ共有
- **SwiftUI / UIKit**: 両方で構築可能（SwiftUI 推奨）

### 制限事項

#### 利用不可のフレームワーク
以下のフレームワークは App Clips では利用できない:
- CallKit
- CareKit
- CloudKit
- HealthKit
- HomeKit
- ResearchKit
- SensorKit
- Speech
- MusicKit（権限リクエスト不可）

> コンパイルエラーにはならないが、ランタイムで利用不可・空データ・エラーコードが返る。

#### プライバシーとトラッキング制限
- **Limit App Tracking が常に有効**: ユーザー追跡は不可
- AppTrackingTransparency による認証リクエスト不可
- IDFA / IDFV はすべてゼロの文字列を返す

#### バックグラウンド処理
- バックグラウンドでのネットワーク通信（URLSession）不可
- バックグラウンドでの Bluetooth 接続維持不可

#### 配布
- フルアプリに埋め込む形でのみ配布可能（単独配布不可）
- 1 つのアプリに対して 1 つの App Clip（ただし異なる URL で複数のエクスペリエンスを表示可能）
- App Store レビュープロセスの一部として提出

---

## 5. 開発アーキテクチャ

### プロジェクト構成
```
MyApp/
├── MyApp/                 # フルアプリのコード
├── MyAppClip/             # App Clip ターゲット
├── Shared/                # 共有コード（Swift Package 推奨）
│   ├── Models/
│   ├── Views/
│   └── Services/
└── MyApp.xcodeproj
```

### 基本的な実装手順
1. Xcode で「App Clip」ターゲットを追加
2. Associated Domains を設定（`appclips:<domain>`）
3. App Clip のエントリーポイントを実装
4. 起動 URL をハンドリング（`onContinueUserActivity` / `NSUserActivity`）
5. Apple App Site Association (AASA) ファイルをサーバーに配置
6. App Store Connect で App Clip エクスペリエンスを設定

### SwiftUI でのエントリーポイント例
```swift
import SwiftUI
import AppClip

@main
struct MyAppClip: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(
                    NSUserActivityTypeBrowsingWeb
                ) { activity in
                    guard let url = activity.webpageURL else { return }
                    // URL に基づいて適切な画面を表示
                    handleIncomingURL(url)
                }
        }
    }
}
```

---

## 6. 実際の活用事例

| カテゴリ | 事例 |
|---|---|
| **飲食** | Panera Bread: テーブルの QR コードからメニュー表示・注文・Apple Pay 決済 |
| **交通** | Lime: スクーターの NFC チップをタップして即座にレンタル解除 |
| **駐車場** | Honk: 駐車場の QR コードをスキャンして Apple Pay でタッチレス決済 |
| **小売** | Primer AR: タイルの QR コードから AR で部屋にタイルをプレビュー |
| **チケット** | Ticketmaster: イベント会場でのチケット購入・表示 |
| **博物館** | City Museum: 展示物の QR コードから詳細情報・画像・説明を表示 |
| **教育** | Elloveo: 科学教育アプリの無料トライアルを App Clip で提供 |
| **デザイン** | Play: モバイルプロトタイプの共有を App Clip で実現 |

---

## 7. App Clips 活用アイデア

以下に、App Clips の特性を活かした革新的なアプリケーション案を提案する。

---

### アイデア 1: 「まちなか謎解きアドベンチャー」

**コンセプト:** 街中に配置された NFC タグや QR コードを巡り、各地点で異なるパズルを解く位置連動型謎解きゲーム。

**仕組み:**
- 商店街や観光地の各店舗・スポットに NFC タグ / QR コードを設置
- ユーザーはスマートフォンをかざすだけで即座にその地点固有の謎解きパズルが起動
- 各地点の App Clip は起動 URL のパラメータで異なる謎を表示
- パズルを解くと「次のヒント」と「次の地点の方向」が提示される
- Apple Pay でイベント参加費を決済

**App Clips が最適な理由:**
- インストール不要なので、通りがかりの人も気軽に参加できる
- 位置情報 ("When In Use") で現在地点を確認し、正しいスポットにいることを検証
- 一時通知で「残り時間」や「ヒント」を配信（最大8時間）
- 全クリア後に SKOverlay でフルアプリのダウンロードを促し、ランキングやアーカイブ機能へ誘導

**収益モデル:**
- 自治体・商店街との連携による地域活性化イベント
- フルアプリでの月額プレミアムコンテンツ

---

### アイデア 2: 「フードアレルギーセーフティスキャナー」

**コンセプト:** レストランのテーブルやメニューに設置された QR コードをスキャンすると、そのレストランのメニュー全品のアレルゲン情報が即座に表示され、安全な料理を選べるアプリ。

**仕組み:**
- レストランのテーブルに App Clip コード（NFC 内蔵）を設置
- スキャンすると、起動 URL からレストラン ID を取得し、メニューデータを表示
- ユーザーは自分のアレルギー情報を選択（卵、乳、小麦、そば、落花生、えび、かに 等）
- 該当アレルゲンを含むメニューにはアラートが表示され、安全なメニューがハイライトされる
- メニュー写真は AsyncImage で遅延読み込み（サイズ制限対策）

**App Clips が最適な理由:**
- 初めて訪れるレストランでもインストール不要で即座に利用可能
- 旅行者や外国人観光客がその場で安全確認できる（多言語対応）
- Apple Pay で注文・決済まで完結
- フルアプリではアレルギー情報の永続保存、お気に入りレストラン管理、口コミ機能を提供

**社会的インパクト:**
- 食物アレルギー事故の予防に直結
- 飲食店のアレルゲン表示義務化への対応ツールとしても活用可能

---

### アイデア 3: 「AR タイムトラベラー」

**コンセプト:** 歴史的建造物や史跡に設置された NFC タグをタップすると、AR でその場所の「過去の姿」を現在の風景に重ね合わせて表示する。

**仕組み:**
- 城跡、寺社仏閣、歴史的街並みなどに NFC タグを配置
- App Clip 起動時にカメラが立ち上がり、AR で建造物の過去の姿（江戸時代の城、戦前の街並み等）をオーバーレイ表示
- スライダーで年代を変更し、時代ごとの変遷をリアルタイムで確認
- 歴史解説テキストと音声ガイドを同時提供

**App Clips が最適な理由:**
- 観光客がアプリのインストールなしで即座に AR 体験
- 位置情報でスポットの正確な位置を検証
- カメラアクセスの権限がフルアプリに引き継がれる
- 50 MB のデジタル起動制限で、基本的な 3D モデルとテクスチャを格納可能
- 追加の高精細モデルは On-Demand Resources で動的ロード
- フルアプリでは全スポットの地図、コレクション機能、SNS 共有を提供

---

### アイデア 4: 「ライブ投票・インタラクション」

**コンセプト:** コンサート、カンファレンス、スポーツ観戦中に、会場の座席に貼られた NFC タグをタップするだけで、リアルタイムの投票・応援・リクエストに参加できるシステム。

**仕組み:**
- 各座席や会場入口に NFC タグ / App Clip コードを配置
- タップすると即座にイベント専用の App Clip が起動
- 機能例:
  - コンサート: 次に演奏してほしい曲のリクエスト投票
  - カンファレンス: 講演者へのリアルタイム Q&A 投稿
  - スポーツ: MVP 投票、応援エフェクト（スマホの画面色を一斉変更してスタジアムを彩る）
- WebSocket でリアルタイム同期し、結果は会場の大型スクリーンに即時反映

**App Clips が最適な理由:**
- 数万人の観客が事前インストールなしで瞬時に参加
- 一時通知で「投票開始」「結果発表」をプッシュ
- Apple Pay でグッズ購入やドリンク注文も統合可能
- イベント終了後は自動的にデバイスから削除される（App Clip のライフサイクル特性）

---

### アイデア 5: 「緊急医療情報カード」

**コンセプト:** NFC タグ付きのブレスレットやカードを身につけておき、緊急時に救急隊員がタップするだけで、持病・服薬情報・緊急連絡先・かかりつけ医情報が表示される。

**仕組み:**
- NFC タグ内蔵のブレスレット / カード / キーホルダーを製品として提供
- タップすると App Clip が起動し、暗号化された医療情報を安全に表示
- 表示内容:
  - 血液型、持病、アレルギー
  - 現在の服薬リスト
  - 緊急連絡先（家族、かかりつけ医）
  - 保険証情報
- 情報はサーバーに暗号化保存され、App Clip からの API コールで取得

**App Clips が最適な理由:**
- 救急隊員や周囲の人がアプリのインストールなしで即座に情報を確認
- iPhone ユーザーなら誰でも読み取り可能
- HealthKit は利用不可だが、独自サーバーでの医療情報管理は可能
- フルアプリで情報の登録・更新・管理を行い、App Clip は閲覧専用

**注意点:**
- 個人情報保護の観点から、PINコードやFace ID による段階的な情報開示が必要
- 初期表示は血液型とアレルギーのみ、認証後に詳細情報を開示するなどの設計

---

## 8. まとめ

App Clips は「インストール不要で即座に体験を提供する」という強力な特性を持ち、以下の場面で特に効果的:

1. **一期一会の接点**: 初めて訪れる場所やサービスでのフリクションレスな体験
2. **物理世界とデジタルの接続**: NFC / QR コードによるオフラインからオンラインへのシームレスな遷移
3. **フルアプリへのコンバージョン**: 体験を通じてアプリの価値を実感させ、ダウンロードに繋げる導線
4. **位置・時間連動のサービス**: 特定の場所・特定の時間にのみ意味のある体験

iOS 17 以降でのサイズ制限緩和（50 MB）により、AR 体験やリッチなメディアコンテンツも App Clip で提供可能になっており、活用の幅はさらに広がっている。

---

## 参考資料

- [Apple Human Interface Guidelines - App Clips](https://developer.apple.com/design/human-interface-guidelines/app-clips)
- [Apple Developer Documentation - Choosing the Right Functionality](https://developer.apple.com/documentation/appclip/choosing-the-right-functionality-for-your-app-clip)
- [WWDC23 - What's New in App Clips](https://developer.apple.com/videos/play/wwdc2023/10178/)
- [WWDC21 - Build Light and Fast App Clips](https://developer.apple.com/videos/play/wwdc2021/10013/)
- [Adapptor - Developer Guide with Example](https://www.adapptor.com.au/blog/mastering-apple-app-clips-a-developer-s-guide-with-a-completed-example)
- [Bugfender - Creating iOS App Clips](https://bugfender.com/blog/creating-ios-app-clips/)
- [Heady - The App Clips Playbook](https://www.heady.io/blog/the-app-clips-playbook-5-inspiring-examples-teardowns)
- [tanaschita.com - Developer Guide on App Clips](https://tanaschita.com/20230424-app-clips/)
- [Medium - App Clips Lab Day: The Size Limit](https://medium.com/touchwonders/app-clips-lab-day-the-size-limit-1ffe28d69ce6)
