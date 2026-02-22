import SwiftUI

struct ContextSettingsView: View {
    @Bindable var viewModel: ContextDJViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentContextSection
                    moodPreferencesSection
                    contextLearningSection
                    siriSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("コンテキスト設定")
        }
    }

    // MARK: - Current Context

    private var currentContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("現在のコンテキスト")
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.refreshContext()
                } label: {
                    Label("更新", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
            }

            if let context = viewModel.currentContext {
                VStack(spacing: 12) {
                    contextRow(
                        icon: context.timeOfDay.icon,
                        title: "時間帯",
                        value: context.timeOfDay.displayName,
                        color: .orange
                    )

                    if let weather = context.weather {
                        contextRow(
                            icon: weather.icon,
                            title: "天気",
                            value: weather.displayName,
                            color: .blue
                        )
                    }

                    if let location = context.location {
                        contextRow(
                            icon: location.icon,
                            title: "場所",
                            value: location.displayName,
                            color: .green
                        )
                    }

                    if let activity = context.activity {
                        contextRow(
                            icon: activity.icon,
                            title: "アクティビティ",
                            value: activity.displayName,
                            color: .purple
                        )
                    }
                }

                let suggestedMood = viewModel.suggestedMoods.first
                if let mood = suggestedMood {
                    HStack {
                        Text("おすすめムード:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(mood.displayName, systemImage: mood.icon)
                            .font(.caption.bold())
                            .foregroundStyle(mood.color)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Mood Preferences

    private var moodPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ムード × ジャンル設定")
                .font(.headline)

            ForEach(MoodType.allCases) { mood in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: mood.icon)
                            .foregroundStyle(mood.color)
                        Text(mood.displayName)
                            .font(.subheadline.bold())
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(mood.preferredGenres, id: \.rawValue) { genre in
                                Text(genre.displayName)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(genre.color.opacity(0.15))
                                    .foregroundStyle(genre.color)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.vertical, 4)

                if mood != MoodType.allCases.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Context Learning

    private var contextLearningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("コンテキスト学習")
                .font(.headline)

            HStack(spacing: 12) {
                Image(systemName: "brain")
                    .font(.title2)
                    .foregroundStyle(.purple)
                    .frame(width: 44, height: 44)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text("iOS コンテキスト学習")
                        .font(.subheadline.bold())
                    Text("使い続けることで、時間帯・場所・天気に基づいて最適な音楽を自動提案します")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                learningRow(icon: "clock", text: "月曜朝の通勤時 → アップテンポな曲")
                learningRow(icon: "moon", text: "夜22時以降 → チルアウト系")
                learningRow(icon: "dumbbell", text: "ジムの近く → ワークアウトプレイリスト")
                learningRow(icon: "cloud.rain", text: "雨の日 → ジャズやローファイ")
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Siri Section

    private var siriSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Siri コマンド")
                .font(.headline)

            VStack(spacing: 8) {
                siriCommand("「Hey Siri、集中できる音楽かけて」")
                siriCommand("「Hey Siri、ドライブ用の音楽」")
                siriCommand("「Hey Siri、今の状況に合う音楽を」")
                siriCommand("「Hey Siri、この曲に似た曲を探して」")
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func contextRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }

    private func learningRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func siriCommand(_ text: String) -> some View {
        HStack {
            Image(systemName: "mic.fill")
                .foregroundStyle(.blue)
            Text(text)
                .font(.caption)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
