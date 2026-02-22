import Foundation

// MARK: - MedicalProfileManager

@MainActor
@Observable
final class MedicalProfileManager {

    static let shared = MedicalProfileManager()

    private(set) var profiles: [MedicalProfile] = []

    private init() {
        loadSampleData()
    }

    func profile(for id: String) -> MedicalProfile? {
        profiles.first { $0.id.uuidString == id }
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        let calendar = Calendar.current

        let profile1 = MedicalProfile(
            ownerName: "田中 太郎",
            dateOfBirth: calendar.date(from: DateComponents(year: 1985, month: 3, day: 15))!,
            bloodType: .aPositive,
            conditions: [
                MedicalCondition(
                    name: "2型糖尿病",
                    severity: .moderate,
                    diagnosedDate: calendar.date(from: DateComponents(year: 2018, month: 6))!,
                    notes: "食事療法とインスリン注射で管理中"
                ),
                MedicalCondition(
                    name: "高血圧",
                    severity: .mild,
                    diagnosedDate: calendar.date(from: DateComponents(year: 2020, month: 1))!,
                    notes: "降圧薬で安定"
                ),
                MedicalCondition(
                    name: "喘息",
                    severity: .critical,
                    diagnosedDate: calendar.date(from: DateComponents(year: 1990, month: 9))!,
                    notes: "重度の発作歴あり。吸入器を常時携帯"
                ),
            ],
            medications: [
                Medication(
                    name: "メトホルミン",
                    dosage: "500mg",
                    frequency: .twiceDaily,
                    purpose: "血糖値管理",
                    isEssential: true
                ),
                Medication(
                    name: "アムロジピン",
                    dosage: "5mg",
                    frequency: .daily,
                    purpose: "血圧管理",
                    isEssential: true
                ),
                Medication(
                    name: "サルブタモール吸入",
                    dosage: "100μg",
                    frequency: .asNeeded,
                    purpose: "喘息発作時",
                    isEssential: true
                ),
            ],
            allergies: [
                MedicalAllergy(
                    name: "ペニシリン",
                    reaction: "全身蕁麻疹・呼吸困難",
                    severity: .anaphylaxis
                ),
                MedicalAllergy(
                    name: "アスピリン",
                    reaction: "喘息発作誘発",
                    severity: .severe
                ),
                MedicalAllergy(
                    name: "ラテックス",
                    reaction: "接触性皮膚炎",
                    severity: .moderate
                ),
            ],
            emergencyContacts: [
                EmergencyContact(
                    name: "田中 花子",
                    relationship: "配偶者",
                    phoneNumber: "090-1234-5678",
                    isPrimary: true
                ),
                EmergencyContact(
                    name: "田中 一郎",
                    relationship: "父",
                    phoneNumber: "090-8765-4321"
                ),
            ],
            insurance: InsuranceInfo(
                providerName: "全国健康保険協会",
                policyNumber: "12345678",
                holderName: "田中 太郎",
                validUntil: calendar.date(from: DateComponents(year: 2026, month: 3, day: 31))!
            ),
            primaryDoctorName: "佐藤 健一 医師",
            primaryDoctorPhone: "03-1234-5678",
            organDonor: true,
            lastUpdated: calendar.date(from: DateComponents(year: 2025, month: 1, day: 10))!
        )

        let profile2 = MedicalProfile(
            ownerName: "鈴木 美咲",
            dateOfBirth: calendar.date(from: DateComponents(year: 1972, month: 11, day: 8))!,
            bloodType: .bNegative,
            conditions: [
                MedicalCondition(
                    name: "心房細動",
                    severity: .critical,
                    diagnosedDate: calendar.date(from: DateComponents(year: 2019, month: 4))!,
                    notes: "ワルファリン服用中。手術時は事前中止が必要"
                ),
                MedicalCondition(
                    name: "骨粗鬆症",
                    severity: .moderate,
                    diagnosedDate: calendar.date(from: DateComponents(year: 2021, month: 7))!,
                    notes: "ビスホスホネート治療中"
                ),
            ],
            medications: [
                Medication(
                    name: "ワルファリン",
                    dosage: "3mg",
                    frequency: .daily,
                    purpose: "抗凝固療法",
                    isEssential: true
                ),
                Medication(
                    name: "ビソプロロール",
                    dosage: "2.5mg",
                    frequency: .daily,
                    purpose: "心拍数管理",
                    isEssential: true
                ),
                Medication(
                    name: "アレンドロン酸",
                    dosage: "35mg",
                    frequency: .weekly,
                    purpose: "骨粗鬆症治療"
                ),
            ],
            allergies: [
                MedicalAllergy(
                    name: "造影剤（ヨード系）",
                    reaction: "アナフィラキシーショック",
                    severity: .anaphylaxis
                ),
                MedicalAllergy(
                    name: "スギ花粉",
                    reaction: "鼻炎・結膜炎",
                    severity: .mild
                ),
            ],
            emergencyContacts: [
                EmergencyContact(
                    name: "鈴木 大輔",
                    relationship: "息子",
                    phoneNumber: "090-5555-1234",
                    isPrimary: true
                ),
                EmergencyContact(
                    name: "山田 恵子",
                    relationship: "姉",
                    phoneNumber: "090-6666-5678"
                ),
            ],
            insurance: InsuranceInfo(
                providerName: "東京都国民健康保険",
                policyNumber: "87654321",
                holderName: "鈴木 美咲",
                validUntil: calendar.date(from: DateComponents(year: 2026, month: 7, day: 31))!
            ),
            primaryDoctorName: "中村 明子 医師",
            primaryDoctorPhone: "03-9876-5432",
            organDonor: false,
            lastUpdated: calendar.date(from: DateComponents(year: 2025, month: 2, day: 5))!
        )

        profiles = [profile1, profile2]
    }
}
