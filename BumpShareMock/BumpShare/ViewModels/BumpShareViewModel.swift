import Foundation
import SwiftUI

/// BumpShare のメインビューモデル
@MainActor
@Observable
final class BumpShareViewModel {
    // MARK: - State

    /// 共有するコンテンツ一覧
    private(set) var shareableContents: [ShareableContent] = []

    /// 選択中の共有コンテンツ
    var selectedContent: ShareableContent?

    /// 共有履歴
    private(set) var shareHistory: [ShareHistory] = []

    /// 共有結果メッセージ
    var shareResultMessage: String?

    /// 共有結果アラート表示フラグ
    var showShareResult = false

    /// コンテンツ選択シート表示フラグ
    var showContentPicker = false

    /// 設定画面表示フラグ
    var showSettings = false

    /// 自動共有モード（近づけるだけで自動共有）
    var autoShareEnabled = false

    /// ハプティクスフィードバック有効
    var hapticsEnabled = true

    /// デバイス名
    var deviceName = "自分の iPhone"

    // MARK: - Dependencies

    let nearbyManager = NearbyInteractionManager.shared

    // MARK: - Init

    init() {
        setupDemoContents()
        setupDemoHistory()
    }

    // MARK: - Actions

    /// セッション開始
    func startDiscovery() {
        nearbyManager.startSession()
    }

    /// セッション停止
    func stopDiscovery() {
        nearbyManager.stopSession()
    }

    /// 共有を実行
    func shareContent(_ content: ShareableContent, to peer: PeerDevice) async {
        let success = await nearbyManager.performShare(content: content, to: peer)

        let history = ShareHistory(
            content: content,
            peerName: peer.name,
            direction: .sent,
            date: Date(),
            success: success
        )
        shareHistory.insert(history, at: 0)

        shareResultMessage = success
            ? "\(peer.name) に「\(content.title)」を送信しました"
            : "共有に失敗しました。もう一度お試しください。"
        showShareResult = true
    }

    /// 自動共有チェック
    func checkAutoShare() async {
        guard autoShareEnabled,
              let content = selectedContent,
              let peer = nearbyManager.readyPeer
        else { return }

        await shareContent(content, to: peer)
    }

    /// デモ受信をシミュレート
    func simulateReceive() {
        let demoContent = ShareableContent(
            type: .contact,
            title: "山田太郎",
            subtitle: "090-XXXX-XXXX",
            data: .contact(name: "山田太郎", phone: "090-1234-5678", email: "taro@example.com")
        )

        let history = ShareHistory(
            content: demoContent,
            peerName: "iPhone (Taro)",
            direction: .received,
            date: Date(),
            success: true
        )
        shareHistory.insert(history, at: 0)
    }

    // MARK: - Private

    private func setupDemoContents() {
        shareableContents = [
            ShareableContent(
                type: .contact,
                title: "マイ連絡先",
                subtitle: "名前・電話番号・メール",
                data: .contact(name: "鈴木花子", phone: "080-1234-5678", email: "hanako@example.com")
            ),
            ShareableContent(
                type: .wifiPassword,
                title: "自宅 Wi-Fi",
                subtitle: "MyHomeNetwork",
                data: .wifi(ssid: "MyHomeNetwork", password: "password123", security: "WPA2")
            ),
            ShareableContent(
                type: .wifiPassword,
                title: "オフィス Wi-Fi",
                subtitle: "Office-5G",
                data: .wifi(ssid: "Office-5G", password: "office2025!", security: "WPA3")
            ),
            ShareableContent(
                type: .appData,
                title: "フレンド申請",
                subtitle: "ゲーム内フレンド追加",
                data: .appData(appName: "MyGame", payload: "{\"type\":\"friend_request\",\"uid\":\"USR_12345\"}")
            ),
            ShareableContent(
                type: .appData,
                title: "ポイントカード",
                subtitle: "会員ID: 9876543",
                data: .appData(appName: "PointCard", payload: "{\"member_id\":\"9876543\"}")
            ),
            ShareableContent(
                type: .arContent,
                title: "3D フィギュア",
                subtitle: "自作キャラクター USDZ",
                data: .arContent(modelName: "character_01.usdz", fileSize: "2.4 MB")
            ),
        ]

        selectedContent = shareableContents.first
    }

    private func setupDemoHistory() {
        let calendar = Calendar.current

        shareHistory = [
            ShareHistory(
                content: ShareableContent(
                    type: .contact,
                    title: "マイ連絡先",
                    subtitle: "名前・電話番号",
                    data: .contact(name: "鈴木花子", phone: "080-1234-5678", email: "hanako@example.com")
                ),
                peerName: "iPhone (Ken)",
                direction: .sent,
                date: calendar.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                success: true
            ),
            ShareHistory(
                content: ShareableContent(
                    type: .wifiPassword,
                    title: "カフェ Wi-Fi",
                    subtitle: "CafeWiFi-Guest",
                    data: .wifi(ssid: "CafeWiFi-Guest", password: "cafe2025", security: "WPA2")
                ),
                peerName: "iPhone (Yuki)",
                direction: .received,
                date: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                success: true
            ),
            ShareHistory(
                content: ShareableContent(
                    type: .arContent,
                    title: "建築モデル",
                    subtitle: "building.usdz",
                    data: .arContent(modelName: "building.usdz", fileSize: "5.1 MB")
                ),
                peerName: "iPhone (Taro)",
                direction: .received,
                date: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                success: true
            ),
        ]
    }
}
