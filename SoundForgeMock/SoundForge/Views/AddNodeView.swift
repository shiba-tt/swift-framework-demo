import SwiftUI

struct AddNodeView: View {
    @Bindable var viewModel: SoundForgeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(NodeCategory.allCases, id: \.rawValue) { category in
                    Section {
                        let types = AudioNodeType.allCases.filter { $0.category == category }
                        ForEach(types) { type in
                            Button {
                                viewModel.addNode(type: type)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(type.emoji)
                                        .font(.title3)
                                        .frame(width: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(type.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        Text("\(type.defaultParameters.count) パラメータ")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Circle()
                                        .fill(Color(type.colorName).opacity(0.3))
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    } header: {
                        Label(category.rawValue, systemImage: category.systemImage)
                    }
                }
            }
            .navigationTitle("ノードを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddNodeView(viewModel: SoundForgeViewModel())
}
