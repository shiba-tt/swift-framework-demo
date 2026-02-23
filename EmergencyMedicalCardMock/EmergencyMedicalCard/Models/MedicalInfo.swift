import SwiftUI

// MARK: - BloodType

enum BloodType: String, CaseIterable, Identifiable, Sendable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case oPositive = "O+"
    case oNegative = "O-"
    case abPositive = "AB+"
    case abNegative = "AB-"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .aPositive, .aNegative: .red
        case .bPositive, .bNegative: .blue
        case .oPositive, .oNegative: .green
        case .abPositive, .abNegative: .purple
        }
    }
}

// MARK: - MedicalCondition

struct MedicalCondition: Identifiable, Sendable {
    let id: UUID
    let name: String
    let severity: ConditionSeverity
    let diagnosedDate: Date
    let notes: String

    init(
        id: UUID = UUID(),
        name: String,
        severity: ConditionSeverity,
        diagnosedDate: Date,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.severity = severity
        self.diagnosedDate = diagnosedDate
        self.notes = notes
    }
}

// MARK: - ConditionSeverity

enum ConditionSeverity: String, CaseIterable, Identifiable, Sendable {
    case critical = "重篤"
    case moderate = "中程度"
    case mild = "軽度"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .critical: "exclamationmark.triangle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .mild: "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .critical: .red
        case .moderate: .orange
        case .mild: .yellow
        }
    }
}

// MARK: - Medication

struct Medication: Identifiable, Sendable {
    let id: UUID
    let name: String
    let dosage: String
    let frequency: MedicationFrequency
    let purpose: String
    let isEssential: Bool

    init(
        id: UUID = UUID(),
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        purpose: String,
        isEssential: Bool = false
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.purpose = purpose
        self.isEssential = isEssential
    }
}

// MARK: - MedicationFrequency

enum MedicationFrequency: String, CaseIterable, Identifiable, Sendable {
    case daily = "毎日"
    case twiceDaily = "1日2回"
    case threeTimesDaily = "1日3回"
    case weekly = "週1回"
    case asNeeded = "必要時"

    var id: String { rawValue }
}

// MARK: - MedicalAllergy

struct MedicalAllergy: Identifiable, Sendable {
    let id: UUID
    let name: String
    let reaction: String
    let severity: AllergySeverity

    init(
        id: UUID = UUID(),
        name: String,
        reaction: String,
        severity: AllergySeverity
    ) {
        self.id = id
        self.name = name
        self.reaction = reaction
        self.severity = severity
    }
}

// MARK: - AllergySeverity

enum AllergySeverity: String, CaseIterable, Identifiable, Sendable {
    case anaphylaxis = "アナフィラキシー"
    case severe = "重度"
    case moderate = "中程度"
    case mild = "軽度"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .anaphylaxis: "bolt.trianglebadge.exclamationmark.fill"
        case .severe: "exclamationmark.triangle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .mild: "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .anaphylaxis: .red
        case .severe: .orange
        case .moderate: .yellow
        case .mild: .blue
        }
    }
}

// MARK: - EmergencyContact

struct EmergencyContact: Identifiable, Sendable {
    let id: UUID
    let name: String
    let relationship: String
    let phoneNumber: String
    let isPrimary: Bool

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        phoneNumber: String,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phoneNumber = phoneNumber
        self.isPrimary = isPrimary
    }
}

// MARK: - InsuranceInfo

struct InsuranceInfo: Identifiable, Sendable {
    let id: UUID
    let providerName: String
    let policyNumber: String
    let holderName: String
    let validUntil: Date

    init(
        id: UUID = UUID(),
        providerName: String,
        policyNumber: String,
        holderName: String,
        validUntil: Date
    ) {
        self.id = id
        self.providerName = providerName
        self.policyNumber = policyNumber
        self.holderName = holderName
        self.validUntil = validUntil
    }
}

// MARK: - AccessLevel

enum AccessLevel: Int, CaseIterable, Identifiable, Sendable, Comparable {
    case basic = 0
    case authenticated = 1
    case full = 2

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .basic: "基本情報"
        case .authenticated: "認証済み"
        case .full: "完全アクセス"
        }
    }

    var description: String {
        switch self {
        case .basic: "血液型・アレルギー・緊急連絡先"
        case .authenticated: "持病・服薬情報"
        case .full: "保険証・かかりつけ医"
        }
    }

    var icon: String {
        switch self {
        case .basic: "lock.open.fill"
        case .authenticated: "lock.shield.fill"
        case .full: "lock.doc.fill"
        }
    }

    var color: Color {
        switch self {
        case .basic: .green
        case .authenticated: .blue
        case .full: .purple
        }
    }

    static func < (lhs: AccessLevel, rhs: AccessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - MedicalProfile

struct MedicalProfile: Identifiable, Sendable {
    let id: UUID
    let ownerName: String
    let dateOfBirth: Date
    let bloodType: BloodType
    let conditions: [MedicalCondition]
    let medications: [Medication]
    let allergies: [MedicalAllergy]
    let emergencyContacts: [EmergencyContact]
    let insurance: InsuranceInfo?
    let primaryDoctorName: String
    let primaryDoctorPhone: String
    let organDonor: Bool
    let lastUpdated: Date

    init(
        id: UUID = UUID(),
        ownerName: String,
        dateOfBirth: Date,
        bloodType: BloodType,
        conditions: [MedicalCondition],
        medications: [Medication],
        allergies: [MedicalAllergy],
        emergencyContacts: [EmergencyContact],
        insurance: InsuranceInfo? = nil,
        primaryDoctorName: String,
        primaryDoctorPhone: String,
        organDonor: Bool = false,
        lastUpdated: Date = .now
    ) {
        self.id = id
        self.ownerName = ownerName
        self.dateOfBirth = dateOfBirth
        self.bloodType = bloodType
        self.conditions = conditions
        self.medications = medications
        self.allergies = allergies
        self.emergencyContacts = emergencyContacts
        self.insurance = insurance
        self.primaryDoctorName = primaryDoctorName
        self.primaryDoctorPhone = primaryDoctorPhone
        self.organDonor = organDonor
        self.lastUpdated = lastUpdated
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year ?? 0
    }

    var criticalConditions: [MedicalCondition] {
        conditions.filter { $0.severity == .critical }
    }

    var essentialMedications: [Medication] {
        medications.filter { $0.isEssential }
    }

    var severeAllergies: [MedicalAllergy] {
        allergies.filter { $0.severity == .anaphylaxis || $0.severity == .severe }
    }

    var primaryContact: EmergencyContact? {
        emergencyContacts.first { $0.isPrimary } ?? emergencyContacts.first
    }
}
