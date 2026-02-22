import SwiftUI

struct AllergenSelectionView: View {
    @Bindable var viewModel: AllergyGuardViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("アレルギー情報を選択", systemImage: "shield.checkered")
                            .font(.headline)
                        Text("該当するアレルゲンをタップして選択してください。メニューの安全性が自動判定されます。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("特定原材料（表示義務）") {
                    ForEach(Allergen.allCases.filter(\.isMandatory)) { allergen in
                        allergenRow(allergen)
                    }
                }

                Section("特定原材料に準ずるもの") {
                    ForEach(Allergen.allCases.filter { !$0.isMandatory }) { allergen in
                        allergenRow(allergen)
                    }
                }

                if viewModel.hasSelectedAllergens {
                    Section {
                        Button(role: .destructive) {
                            viewModel.clearAllergens()
                        } label: {
                            Label("選択をすべてクリア", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("アレルギー設定")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.hasSelectedAllergens {
                        Text("\(viewModel.selectedAllergens.count)件選択中")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func allergenRow(_ allergen: Allergen) -> some View {
        let isSelected = viewModel.selectedAllergens.contains(allergen)

        Button {
            withAnimation(.snappy) {
                viewModel.toggleAllergen(allergen)
            }
        } label: {
            HStack {
                Image(systemName: allergen.icon)
                    .foregroundStyle(allergen.color)
                    .frame(width: 28)

                Text(allergen.rawValue)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .listRowBackground(
            isSelected ? Color.red.opacity(0.08) : Color.clear
        )
    }
}

#Preview {
    AllergenSelectionView(viewModel: AllergyGuardViewModel())
}
