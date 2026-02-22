import SwiftUI

// MARK: - HistoricalEra

struct HistoricalEra: Identifiable, Sendable {
    let id: UUID
    let name: String
    let yearRange: String
    let year: Int
    let description: String
    let color: Color

    init(
        id: UUID = UUID(),
        name: String,
        yearRange: String,
        year: Int,
        description: String,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.yearRange = yearRange
        self.year = year
        self.description = description
        self.color = color
    }
}

// MARK: - Predefined Eras

extension HistoricalEra {
    static let edo = HistoricalEra(
        name: "江戸時代",
        yearRange: "1603–1868",
        year: 1700,
        description: "徳川幕府による太平の世。城下町が栄え、町人文化が花開いた時代。",
        color: .indigo
    )

    static let meiji = HistoricalEra(
        name: "明治時代",
        yearRange: "1868–1912",
        year: 1890,
        description: "文明開化と近代化の時代。西洋建築が取り入れられ、街並みが大きく変化。",
        color: .brown
    )

    static let taisho = HistoricalEra(
        name: "大正時代",
        yearRange: "1912–1926",
        year: 1920,
        description: "大正デモクラシーとモダニズム。和洋折衷の建築が数多く建てられた時代。",
        color: .orange
    )

    static let showaPre = HistoricalEra(
        name: "昭和前期",
        yearRange: "1926–1945",
        year: 1935,
        description: "モダニズム建築の興隆と戦争の影。多くの建造物が空襲で失われた。",
        color: .gray
    )

    static let showaPost = HistoricalEra(
        name: "昭和後期",
        yearRange: "1945–1989",
        year: 1965,
        description: "戦後復興と高度経済成長。コンクリート建築が増え、都市が急速に変貌。",
        color: .teal
    )

    static let heisei = HistoricalEra(
        name: "平成時代",
        yearRange: "1989–2019",
        year: 2000,
        description: "バブル崩壊から復興へ。再開発と歴史的建造物の保存が進んだ時代。",
        color: .blue
    )

    static let present = HistoricalEra(
        name: "現在",
        yearRange: "2019–",
        year: 2025,
        description: "令和の今日。歴史と未来が共存する現在の街並み。",
        color: .green
    )

    static let allEras: [HistoricalEra] = [
        .edo, .meiji, .taisho, .showaPre, .showaPost, .heisei, .present
    ]
}
