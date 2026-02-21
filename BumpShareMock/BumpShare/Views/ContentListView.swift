import SwiftUI

/// 共有可能コンテンツ一覧画面
struct ContentListView: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(ShareableContentType.allCases) { type in
                    let contents = viewModel.shareableContents.filter { $0.type == type }
                    if !contents.isEmpty {
                        Section {
                            ForEach(contents) { content in
                                ContentRow(content: content, isSelected: viewModel.selectedContent?.id == content.id) {
                                    viewModel.selectedContent = content
                                }
                            }
                        } header: {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                }
            }
            .navigationTitle("コンテンツ")
        }
    }
}

// MARK: - Content Row

private struct ContentRow: View {
    let content: ShareableContent
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // アイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(content.type.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: content.type.icon)
                        .foregroundStyle(content.type.color)
                }

                // コンテンツ情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(content.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ContentDetailText(data: content.data)
                }

                Spacer()

                // 選択状態
                if isSelected {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.cyan)
                        Text("選択中")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.cyan)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct ContentDetailText: View {
    let data: ShareData

    var body: some View {
        Group {
            switch data {
            case .contact(let name, let phone, _):
                Text("\(name) · \(phone)")
            case .wifi(let ssid, _, let security):
                Text("\(ssid) · \(security)")
            case .appData(let appName, _):
                Text(appName)
            case .arContent(let modelName, let fileSize):
                Text("\(modelName) (\(fileSize))")
            }
        }
        .font(.system(size: 10, design: .monospaced))
        .foregroundStyle(.tertiary)
    }
}
