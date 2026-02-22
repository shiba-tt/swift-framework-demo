import Foundation

// MARK: - SpotManager

@MainActor
@Observable
final class SpotManager {

    static let shared = SpotManager()

    private(set) var spots: [HistoricalSpot] = []
    private(set) var visitRecords: [VisitRecord] = []

    private init() {
        spots = Self.generateSampleSpots()
    }

    func spot(for id: String) -> HistoricalSpot? {
        spots.first { $0.id.uuidString == id }
    }

    func spot(byNFCTag tagID: String) -> HistoricalSpot? {
        spots.first { $0.nfcTagID == tagID }
    }

    func recordVisit(spotID: UUID, spotName: String, erasViewed: [HistoricalEra], audioGuideListened: Bool) {
        let record = VisitRecord(
            spotID: spotID,
            spotName: spotName,
            erasViewed: erasViewed,
            audioGuideListened: audioGuideListened
        )
        visitRecords.insert(record, at: 0)
    }

    var totalVisits: Int { visitRecords.count }

    var uniqueSpotsVisited: Int {
        Set(visitRecords.map(\.spotID)).count
    }

    // MARK: - Sample Data

    private static func generateSampleSpots() -> [HistoricalSpot] {
        [
            HistoricalSpot(
                name: "江戸城（皇居）",
                subtitle: "徳川幕府の居城から皇居へ",
                description: "かつて世界最大級の城郭であった江戸城。明治維新後に皇居となり、現在も東京の中心に位置する歴史的シンボル。",
                category: .castle,
                latitude: 35.6852,
                longitude: 139.7528,
                nfcTagID: "NFC-EDOJO-001",
                snapshots: [
                    EraSnapshot(
                        era: .edo,
                        title: "江戸城天守閣",
                        description: "1638年に再建された五層の天守閣。明暦の大火（1657年）で焼失するまで、江戸の象徴として君臨した。",
                        modelName: "edo_castle_tenshu",
                        audioGuideDuration: 90
                    ),
                    EraSnapshot(
                        era: .meiji,
                        title: "皇居・明治宮殿",
                        description: "明治維新後、天皇の住居として明治宮殿が建設された。和洋折衷の壮麗な木造建築。",
                        modelName: "meiji_palace",
                        audioGuideDuration: 75
                    ),
                    EraSnapshot(
                        era: .showaPre,
                        title: "宮城（戦前の皇居）",
                        description: "明治宮殿は1945年の空襲で焼失。戦前最後の姿を再現。",
                        modelName: "prewar_palace",
                        audioGuideDuration: 60
                    ),
                    EraSnapshot(
                        era: .present,
                        title: "現在の皇居",
                        description: "1968年に完成した現在の宮殿。伝統と現代が調和するデザイン。皇居東御苑は一般開放されている。",
                        modelName: "current_palace",
                        audioGuideDuration: 60
                    ),
                ]
            ),
            HistoricalSpot(
                name: "日本橋",
                subtitle: "五街道の起点から首都高の下へ",
                description: "1603年に架けられて以来、日本の道路網の起点として機能してきた象徴的な橋。現在の石造アーチ橋は1911年に完成。",
                category: .bridge,
                latitude: 35.6839,
                longitude: 139.7744,
                nfcTagID: "NFC-NIHONBASHI-001",
                snapshots: [
                    EraSnapshot(
                        era: .edo,
                        title: "木造の日本橋",
                        description: "五街道の起点として賑わう木造の太鼓橋。浮世絵にも数多く描かれた江戸の象徴。",
                        modelName: "nihonbashi_wood",
                        audioGuideDuration: 80
                    ),
                    EraSnapshot(
                        era: .meiji,
                        title: "石造アーチの日本橋",
                        description: "1911年に完成した現在の石造二連アーチ橋。ルネサンス様式の装飾が施された近代建築の傑作。",
                        modelName: "nihonbashi_stone",
                        audioGuideDuration: 70
                    ),
                    EraSnapshot(
                        era: .showaPost,
                        title: "首都高に覆われた日本橋",
                        description: "1963年の首都高速道路建設により、橋の上空が高架道路で覆われた。景観論争の象徴的存在に。",
                        modelName: "nihonbashi_highway",
                        audioGuideDuration: 65
                    ),
                    EraSnapshot(
                        era: .present,
                        title: "再生する日本橋",
                        description: "首都高地下化プロジェクトが進行中。2040年には再び青空の下に日本橋が現れる予定。",
                        modelName: "nihonbashi_future",
                        audioGuideDuration: 60
                    ),
                ]
            ),
            HistoricalSpot(
                name: "浅草寺・雷門",
                subtitle: "東京最古の寺院の千年の変遷",
                description: "628年創建と伝わる東京最古の寺院。雷門の大提灯は浅草のシンボルとして世界的に知られる。",
                category: .temple,
                latitude: 35.7148,
                longitude: 139.7967,
                nfcTagID: "NFC-SENSOJI-001",
                snapshots: [
                    EraSnapshot(
                        era: .edo,
                        title: "江戸時代の浅草寺",
                        description: "徳川家康により祈願所に定められ、江戸有数の繁華街として栄えた。仲見世通りも江戸時代に形成。",
                        modelName: "sensoji_edo",
                        audioGuideDuration: 85
                    ),
                    EraSnapshot(
                        era: .taisho,
                        title: "大正ロマンの浅草",
                        description: "浅草六区が日本最大の歓楽街として栄華を極めた時代。凌雲閣（十二階）がランドマークとして聳え立つ。",
                        modelName: "sensoji_taisho",
                        audioGuideDuration: 75
                    ),
                    EraSnapshot(
                        era: .showaPre,
                        title: "戦前の浅草寺",
                        description: "関東大震災で被災するも復興。しかし1945年の東京大空襲で本堂・五重塔が焼失した。",
                        modelName: "sensoji_prewar",
                        audioGuideDuration: 70
                    ),
                    EraSnapshot(
                        era: .present,
                        title: "現在の浅草寺",
                        description: "1958年に再建された鉄筋コンクリート造の本堂。年間約3000万人が訪れる東京屈指の観光スポット。",
                        modelName: "sensoji_current",
                        audioGuideDuration: 60
                    ),
                ]
            ),
            HistoricalSpot(
                name: "東京駅丸の内駅舎",
                subtitle: "赤レンガ駅舎の100年",
                description: "1914年に辰野金吾の設計で開業した赤レンガ駅舎。2012年に創建時の姿に復原された。",
                category: .station,
                latitude: 35.6812,
                longitude: 139.7671,
                nfcTagID: "NFC-TOKYOSTA-001",
                snapshots: [
                    EraSnapshot(
                        era: .taisho,
                        title: "開業当時の東京駅",
                        description: "1914年開業。辰野金吾設計の壮麗な赤レンガ造り3階建て駅舎。南北にドームを戴くルネサンス様式。",
                        modelName: "tokyo_sta_original",
                        audioGuideDuration: 80
                    ),
                    EraSnapshot(
                        era: .showaPost,
                        title: "戦災復旧の東京駅",
                        description: "1945年の空襲で3階部分とドームが焼失。戦後に2階建てに応急修復された姿で半世紀以上使用された。",
                        modelName: "tokyo_sta_postwar",
                        audioGuideDuration: 70
                    ),
                    EraSnapshot(
                        era: .present,
                        title: "復原された東京駅",
                        description: "2012年に創建時の3階建て・ドーム屋根の姿に完全復原。免震構造を備えた近代的保存の模範例。",
                        modelName: "tokyo_sta_restored",
                        audioGuideDuration: 65
                    ),
                ]
            ),
            HistoricalSpot(
                name: "銀座四丁目交差点",
                subtitle: "文明開化からモダン銀座へ",
                description: "日本初のガス灯が灯り、煉瓦街が建設された近代化の象徴。和光の時計塔が見守る東京を代表する交差点。",
                category: .street,
                latitude: 35.6700,
                longitude: 139.7638,
                nfcTagID: "NFC-GINZA4-001",
                snapshots: [
                    EraSnapshot(
                        era: .meiji,
                        title: "銀座煉瓦街",
                        description: "1872年の大火後、ジョサイア・コンドル監修で建設された西洋式煉瓦街。ガス灯が灯る文明開化の象徴。",
                        modelName: "ginza_brick",
                        audioGuideDuration: 75
                    ),
                    EraSnapshot(
                        era: .taisho,
                        title: "大正モダンの銀座",
                        description: "モダンガールとモダンボーイが闊歩した華やかな銀座。カフェ文化が花開き、百貨店が次々と開業。",
                        modelName: "ginza_taisho",
                        audioGuideDuration: 70
                    ),
                    EraSnapshot(
                        era: .showaPost,
                        title: "高度成長期の銀座",
                        description: "ネオンサインが輝き、ソニービルなどの近代建築が建ち並ぶ。日本の経済成長を象徴する繁華街。",
                        modelName: "ginza_showa",
                        audioGuideDuration: 65
                    ),
                    EraSnapshot(
                        era: .present,
                        title: "現在の銀座",
                        description: "GINZA SIXなど再開発が進む一方、和光の時計塔は変わらず交差点を見守る。伝統と革新が共存する街。",
                        modelName: "ginza_current",
                        audioGuideDuration: 60
                    ),
                ]
            ),
        ]
    }
}
