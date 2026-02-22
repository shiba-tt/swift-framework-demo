import Foundation
import FoundationModels

// MARK: - BusinessContact（Foundation Models による構造化出力）

@Generable
struct BusinessContactAnalysis {
    @Guide(description: "Full name of the person on the business card")
    var name: String

    @Guide(description: "Company or organization name")
    var company: String

    @Guide(description: "Job title or position")
    var title: String

    @Guide(description: "Three conversation starters relevant to this person's industry, in Japanese")
    var conversationStarters: [String]

    @Guide(description: "A casual follow-up email draft in Japanese, within 100 characters")
    var followUpDraft: String
}

// MARK: - ContactCard（保存用の名刺データ）

struct ContactCard: Identifiable, Sendable {
    let id = UUID()
    let analysis: BusinessContactAnalysis
    let phoneNumber: String
    let email: String
    let scannedAt: Date
    var isFavorite: Bool = false
    var notes: String = ""
    var meetingContext: String = ""

    var displayName: String { analysis.name }
    var companyAndTitle: String { "\(analysis.company) / \(analysis.title)" }

    var scannedAtText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: scannedAt, relativeTo: Date())
    }
}

// MARK: - ContactIndustry（業界カテゴリ）

@Generable
enum ContactIndustry: String, Sendable, CaseIterable {
    case technology = "technology"
    case finance = "finance"
    case healthcare = "healthcare"
    case education = "education"
    case creative = "creative"
    case manufacturing = "manufacturing"
    case consulting = "consulting"
    case other = "other"

    var displayName: String {
        switch self {
        case .technology:     "IT・テクノロジー"
        case .finance:        "金融"
        case .healthcare:     "医療・ヘルスケア"
        case .education:      "教育"
        case .creative:       "クリエイティブ"
        case .manufacturing:  "製造"
        case .consulting:     "コンサルティング"
        case .other:          "その他"
        }
    }

    var icon: String {
        switch self {
        case .technology:     "laptopcomputer"
        case .finance:        "banknote"
        case .healthcare:     "heart.text.square"
        case .education:      "graduationcap"
        case .creative:       "paintbrush"
        case .manufacturing:  "hammer"
        case .consulting:     "chart.bar"
        case .other:          "briefcase"
        }
    }
}

// MARK: - ScanResult（OCR スキャン結果）

struct ScanResult: Sendable {
    let rawText: String
    let detectedName: String?
    let detectedCompany: String?
    let detectedPhone: String?
    let detectedEmail: String?
}
