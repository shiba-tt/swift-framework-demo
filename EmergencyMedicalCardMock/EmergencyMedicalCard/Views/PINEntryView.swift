import SwiftUI

struct PINEntryView: View {
    @Bindable var viewModel: EmergencyMedicalCardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                VStack(spacing: 8) {
                    Text("PIN コードを入力")
                        .font(.title3)
                        .fontWeight(.bold)

                    if let next = viewModel.nextAccessLevel {
                        Text("\(next.displayName)にアクセスするにはPINコードが必要です")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                // PIN Dots
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.pinInput.count ? Color.blue : Color(.systemGray4))
                            .frame(width: 16, height: 16)
                    }
                }

                // Number Pad
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                numberButton(String(number))
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        Color.clear
                            .frame(width: 72, height: 52)

                        numberButton("0")

                        Button {
                            if !viewModel.pinInput.isEmpty {
                                viewModel.pinInput.removeLast()
                            }
                        } label: {
                            Image(systemName: "delete.backward.fill")
                                .font(.title3)
                                .frame(width: 72, height: 52)
                                .foregroundStyle(.primary)
                        }
                    }
                }

                if viewModel.showAuthError {
                    Label("PINコードが正しくありません", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Text("デモ用PIN: 1234")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.pinInput) {
                if viewModel.pinInput.count == 4 {
                    viewModel.submitPIN()
                }
            }
        }
    }

    private func numberButton(_ number: String) -> some View {
        Button {
            if viewModel.pinInput.count < 4 {
                viewModel.pinInput += number
                viewModel.showAuthError = false
            }
        } label: {
            Text(number)
                .font(.title2)
                .fontWeight(.medium)
                .frame(width: 72, height: 52)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PINEntryView(viewModel: EmergencyMedicalCardViewModel())
}
