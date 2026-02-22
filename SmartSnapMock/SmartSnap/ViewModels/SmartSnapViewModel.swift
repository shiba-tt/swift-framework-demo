import Foundation

/// SmartSnap のメイン ViewModel
@MainActor
@Observable
final class SmartSnapViewModel {
    private let analyzer = PhotoAnalyzer.shared

    // MARK: - UI State

    var selectedTab: AppTab = .albums

    enum AppTab: String, CaseIterable, Sendable {
        case albums = "アルバム"
        case photos = "写真"
        case search = "検索"

        var systemImageName: String {
            switch self {
            case .albums:  return "rectangle.stack.fill"
            case .photos:  return "photo.fill"
            case .search:  return "magnifyingglass"
            }
        }
    }

    // MARK: - State

    var photos: [Photo] = []
    var albums: [Album] = []
    var selectedAlbum: Album?
    var selectedPhoto: Photo?
    var searchQuery = ""
    var searchResults: [SearchResult] = []
    var errorMessage: String?

    var isAnalyzing: Bool { analyzer.isAnalyzing }
    var isModelAvailable: Bool { analyzer.isAvailable }
    var analysisProgress: String? { analyzer.analysisProgress }

    var recentPhotos: [Photo] {
        photos.sorted { $0.takenAt > $1.takenAt }
    }

    var photosByMonth: [(month: String, photos: [Photo])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"

        let grouped = Dictionary(grouping: photos) { formatter.string(from: $0.takenAt) }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (month: $0.key, photos: $0.value.sorted { $0.takenAt > $1.takenAt }) }
    }

    // MARK: - Setup

    func loadPhotos() async {
        // Vision フレームワークによるオブジェクト検出・OCR のモック
        try? await Task.sleep(for: .seconds(1))
        photos = Photo.samplePhotos
        generateAlbums()
    }

    // MARK: - Album Generation

    /// 写真のタグとメタデータに基づいてアルバムを自動生成
    private func generateAlbums() {
        var generatedAlbums: [Album] = []

        // タグベースでグルーピング
        let tagGroups: [(title: String, tags: Set<String>, category: AlbumCategory)] = [
            ("沖縄旅行 2025", ["旅行", "沖縄"], .travel),
            ("お母さんの誕生日", ["家族", "誕生日"], .family),
            ("iOS Dev Conference", ["仕事", "カンファレンス"], .work),
            ("秋の散歩", ["紅葉", "散歩"], .nature),
            ("うちのペットたち", ["ペット"], .pet),
            ("おいしいもの記録", ["グルメ", "料理"], .food),
        ]

        for group in tagGroups {
            let matchingPhotos = photos.filter { photo in
                !photo.tags.filter { group.tags.contains($0) }.isEmpty
            }
            guard !matchingPhotos.isEmpty else { continue }

            let dates = matchingPhotos.map(\.takenAt).sorted()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "M/d"
            let dateRange: String
            if let first = dates.first, let last = dates.last, first != last {
                dateRange = "\(formatter.string(from: first)) - \(formatter.string(from: last))"
            } else if let first = dates.first {
                dateRange = formatter.string(from: first)
            } else {
                dateRange = ""
            }

            let album = Album(
                title: group.title,
                subtitle: "\(matchingPhotos.count)枚の写真",
                coverPhotoID: matchingPhotos.first?.id,
                photoIDs: matchingPhotos.map(\.id),
                category: group.category,
                dateRange: dateRange
            )
            generatedAlbums.append(album)
        }

        albums = generatedAlbums
    }

    // MARK: - AI Actions

    /// 写真のキャプションを AI で生成
    func generateCaption(for photo: Photo) async {
        guard let index = photos.firstIndex(where: { $0.id == photo.id }) else { return }
        errorMessage = nil

        do {
            let caption = try await analyzer.generateCaption(for: photo)
            photos[index].caption = caption.caption
            photos[index].tags = caption.tags
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// アルバムのストーリーを AI で生成
    func generateAlbumStory(for album: Album) async {
        guard let albumIndex = albums.firstIndex(where: { $0.id == album.id }) else { return }
        errorMessage = nil

        let albumPhotos = album.photoIDs.compactMap { photoID in
            photos.first { $0.id == photoID }
        }

        do {
            let story = try await analyzer.generateAlbumStory(
                albumTitle: album.title,
                photos: albumPhotos
            )
            albums[albumIndex].story = story.narrative
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search

    /// 自然言語で写真を検索
    func search() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        errorMessage = nil
        searchResults = await analyzer.searchPhotos(query: searchQuery, in: photos)
    }

    // MARK: - Photo Selection

    func selectPhoto(_ photo: Photo) {
        selectedPhoto = photo
    }

    func selectAlbum(_ album: Album) {
        selectedAlbum = album
    }

    func photosForAlbum(_ album: Album) -> [Photo] {
        album.photoIDs.compactMap { photoID in
            photos.first { $0.id == photoID }
        }
    }

    // MARK: - Prewarm

    func prewarmModel() async {
        await analyzer.prewarmModel()
    }
}
