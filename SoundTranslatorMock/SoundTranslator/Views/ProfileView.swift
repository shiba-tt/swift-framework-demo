import SwiftUI

struct ProfileView: View {
    var viewModel: SoundTranslatorViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("環境に合わせたリスニングプロファイルを選択してください。プロファイルにより優先的に検出する音のカテゴリが変わります。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("プロファイル一覧") {
                    ForEach(Array(viewModel.profiles.enumerated()), id: \.element.id) { index, profile in
                        ProfileRow(
                            profile: profile,
                            isActive: index == viewModel.activeProfileIndex
                        ) {
                            viewModel.selectProfile(index)
                        }
                    }
                }

                Section("優先検出カテゴリ") {
                    if let profile = viewModel.activeProfile {
                        ForEach(profile.prioritySounds, id: \.self) { category in
                            HStack {
                                Image(systemName: category.systemImage)
                                    .foregroundStyle(category.color)
                                    .frame(width: 24)
                                Text(category.rawValue)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.teal)
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text("プロファイルを選択してください")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("プロファイル")
        }
    }
}

// MARK: - ProfileRow

struct ProfileRow: View {
    let profile: ListeningProfile
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isActive ? .teal.opacity(0.15) : .gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: profile.systemImage)
                        .font(.title3)
                        .foregroundStyle(isActive ? .teal : .gray)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(profile.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.teal)
                }
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: SoundTranslatorViewModel())
}
