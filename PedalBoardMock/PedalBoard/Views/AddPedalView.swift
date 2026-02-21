import SwiftUI

// MARK: - AddPedalView（ペダル追加画面）

struct AddPedalView: View {
    @Bindable var viewModel: PedalBoardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: EffectCategory = .all

    enum EffectCategory: String, CaseIterable {
        case all = "すべて"
        case drive = "歪み系"
        case modulation = "モジュレーション"
        case timeBased = "空間系"
        case dynamics = "ダイナミクス"

        var effectTypes: [EffectType] {
            switch self {
            case .all: EffectType.allCases
            case .drive: [.overdrive, .distortion]
            case .modulation: [.chorus, .flanger, .phaser, .tremolo, .wah]
            case .timeBased: [.delay, .reverb]
            case .dynamics: [.compressor, .eq, .noiseGate]
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリフィルター
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EffectCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedCategory == category ? .semibold : .regular)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? .orange : .gray.opacity(0.15))
                                    .foregroundStyle(selectedCategory == category ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }

                // エフェクトグリッド
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        ForEach(selectedCategory.effectTypes, id: \.self) { type in
                            EffectTypeCard(type: type) {
                                viewModel.addPedal(type: type)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("ペダルを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

// MARK: - EffectTypeCard

struct EffectTypeCard: View {
    let type: EffectType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(type.emoji)
                    .font(.system(size: 36))

                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                // デフォルトパラメータ数
                Text("\(type.defaultParameters.count) パラメータ")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(type.colorName).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
