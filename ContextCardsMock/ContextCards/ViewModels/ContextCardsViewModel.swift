import Foundation

/// ContextCards のメイン ViewModel
@MainActor
@Observable
final class ContextCardsViewModel {
    private let analyzer = ContactAnalyzer.shared

    // MARK: - UI State

    var selectedTab: AppTab = .scan

    enum AppTab: String, CaseIterable, Sendable {
        case scan = "スキャン"
        case contacts = "名刺"
        case favorites = "お気に入り"

        var systemImageName: String {
            switch self {
            case .scan:      "camera.fill"
            case .contacts:  "person.crop.rectangle.stack.fill"
            case .favorites: "star.fill"
            }
        }
    }

    // MARK: - State

    var contacts: [ContactCard] = []
    var currentScanResult: ScanResult?
    var currentAnalysis: ContactCard?
    var searchText: String = ""
    var errorMessage: String?
    var showScanSheet = false
    var showDetailSheet = false
    var selectedContact: ContactCard?
    var meetingContextInput: String = ""

    var isAnalyzing: Bool { analyzer.isAnalyzing }
    var isModelAvailable: Bool { analyzer.isAvailable }
    var analysisProgress: String? { analyzer.analysisProgress }

    var filteredContacts: [ContactCard] {
        guard !searchText.isEmpty else { return contacts }
        return contacts.filter { card in
            card.displayName.localizedCaseInsensitiveContains(searchText)
            || card.analysis.company.localizedCaseInsensitiveContains(searchText)
            || card.analysis.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var favoriteContacts: [ContactCard] {
        contacts.filter(\.isFavorite)
    }

    // MARK: - Init

    init() {
        setupDemoContacts()
    }

    // MARK: - Actions

    /// 名刺撮影をシミュレーション（Vision OCR のモック）
    func scanBusinessCard() async {
        // モック: Vision フレームワークによる OCR をシミュレーション
        try? await Task.sleep(for: .seconds(1.5))

        let demoCards = [
            ScanResult(
                rawText: """
                株式会社テックイノベーション
                取締役 CTO
                田中 健一
                tanaka.kenichi@techinno.co.jp
                03-1234-5678
                東京都渋谷区神宮前1-2-3
                """,
                detectedName: "田中 健一",
                detectedCompany: "株式会社テックイノベーション",
                detectedPhone: "03-1234-5678",
                detectedEmail: "tanaka.kenichi@techinno.co.jp"
            ),
            ScanResult(
                rawText: """
                グローバルデザイン合同会社
                クリエイティブディレクター
                佐藤 美咲
                misaki.sato@globaldesign.jp
                080-9876-5432
                大阪市北区梅田3-4-5
                """,
                detectedName: "佐藤 美咲",
                detectedCompany: "グローバルデザイン合同会社",
                detectedPhone: "080-9876-5432",
                detectedEmail: "misaki.sato@globaldesign.jp"
            ),
            ScanResult(
                rawText: """
                HealthBridge Inc.
                Head of Product
                Alex Chen
                alex.chen@healthbridge.io
                +81-90-1111-2222
                Tokyo, Minato-ku
                """,
                detectedName: "Alex Chen",
                detectedCompany: "HealthBridge Inc.",
                detectedPhone: "+81-90-1111-2222",
                detectedEmail: "alex.chen@healthbridge.io"
            ),
        ]

        currentScanResult = demoCards.randomElement()
    }

    /// スキャン結果を AI で分析してコンタクトを追加
    func analyzeAndSave() async {
        guard let scan = currentScanResult else {
            errorMessage = "名刺をスキャンしてください"
            return
        }

        errorMessage = nil

        do {
            let analysis = try await analyzer.analyzeBusinessCard(ocrText: scan.rawText)
            let card = ContactCard(
                analysis: analysis,
                phoneNumber: scan.detectedPhone ?? "",
                email: scan.detectedEmail ?? "",
                scannedAt: Date()
            )
            currentAnalysis = card
            contacts.insert(card, at: 0)
            currentScanResult = nil
            showScanSheet = false
            selectedTab = .contacts
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// フォローアップメールを再生成
    func regenerateFollowUp(for contactId: UUID, context: String) async {
        guard let index = contacts.firstIndex(where: { $0.id == contactId }) else { return }

        do {
            let newDraft = try await analyzer.regenerateFollowUp(
                contact: contacts[index].analysis,
                meetingContext: context
            )
            contacts[index].meetingContext = context
            contacts[index] = ContactCard(
                analysis: BusinessContactAnalysis(
                    name: contacts[index].analysis.name,
                    company: contacts[index].analysis.company,
                    title: contacts[index].analysis.title,
                    conversationStarters: contacts[index].analysis.conversationStarters,
                    followUpDraft: newDraft
                ),
                phoneNumber: contacts[index].phoneNumber,
                email: contacts[index].email,
                scannedAt: contacts[index].scannedAt,
                isFavorite: contacts[index].isFavorite,
                notes: contacts[index].notes,
                meetingContext: context
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// お気に入りのトグル
    func toggleFavorite(for contactId: UUID) {
        guard let index = contacts.firstIndex(where: { $0.id == contactId }) else { return }
        contacts[index].isFavorite.toggle()
    }

    /// 連絡先を削除
    func deleteContact(at offsets: IndexSet) {
        let targets = offsets.map { filteredContacts[$0].id }
        contacts.removeAll { targets.contains($0.id) }
    }

    /// モデルのプリウォーム
    func prewarmModel() async {
        await analyzer.prewarmModel()
    }

    // MARK: - Private

    private func setupDemoContacts() {
        let calendar = Calendar.current

        contacts = [
            ContactCard(
                analysis: BusinessContactAnalysis(
                    name: "鈴木 太郎",
                    company: "フューチャーAI株式会社",
                    title: "プロダクトマネージャー",
                    conversationStarters: [
                        "AI プロダクトの市場動向について意見交換できれば嬉しいです",
                        "御社の最新プロダクトについてぜひ詳しくお聞きしたいです",
                        "PM としてのチームビルディングの工夫を伺いたいです",
                    ],
                    followUpDraft: "先日はお話できて光栄でした。AI プロダクト開発について、改めてお話しできる機会をいただければ幸いです。"
                ),
                phoneNumber: "090-1234-5678",
                email: "taro.suzuki@futureai.co.jp",
                scannedAt: calendar.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                isFavorite: true,
                meetingContext: "WWDC25 ランチミーティング"
            ),
            ContactCard(
                analysis: BusinessContactAnalysis(
                    name: "山田 花子",
                    company: "クリエイティブラボ合同会社",
                    title: "UX デザイナー",
                    conversationStarters: [
                        "最近のデザインシステムのトレンドについてお話ししたいです",
                        "御社の UX リサーチ手法に興味があります",
                        "SwiftUI でのプロトタイピングについて情報交換しませんか",
                    ],
                    followUpDraft: "先日は素敵なお話をありがとうございました。UX デザインの知見を共有し合えたら嬉しいです。"
                ),
                phoneNumber: "080-8765-4321",
                email: "hanako@creativelab.jp",
                scannedAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            ContactCard(
                analysis: BusinessContactAnalysis(
                    name: "Michael Johnson",
                    company: "CloudScale Technologies",
                    title: "Senior Software Engineer",
                    conversationStarters: [
                        "クラウドインフラのスケーリング戦略について議論したいです",
                        "御社のマイクロサービスアーキテクチャに興味があります",
                        "Swift on Server の活用事例について伺いたいです",
                    ],
                    followUpDraft: "カンファレンスでお会いできて嬉しかったです。クラウド技術について意見交換できる機会をぜひ作りましょう。"
                ),
                phoneNumber: "+1-555-0123",
                email: "michael.j@cloudscale.io",
                scannedAt: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                isFavorite: true,
                meetingContext: "技術カンファレンス"
            ),
        ]
    }
}
