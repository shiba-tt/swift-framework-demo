import SwiftUI

// MARK: - PedalDetailView（ペダル詳細画面）

struct PedalDetailView: View {
    let pedal: EffectPedal
    @Bindable var viewModel: PedalBoardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ペダルヘッダー
                    pedalHeader

                    // パラメータノブ
                    parameterSection

                    // AUv3 プラグイン UI 表示エリア
                    auv3UISection

                    // 操作ボタン
                    actionButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(pedal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    // MARK: - Pedal Header

    private var pedalHeader: some View {
        VStack(spacing: 12) {
            // ペダル筐体風デザイン
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(pedal.colorName).opacity(0.3),
                                Color(pedal.colorName).opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)

                VStack(spacing: 8) {
                    Text(pedal.emoji)
                        .font(.system(size: 40))
                    Text(pedal.type.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }

            // ON/OFF トグル
            HStack {
                Text("エフェクト")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { pedal.isEnabled },
                    set: { _ in viewModel.togglePedal(pedal) }
                ))
                .tint(Color(pedal.colorName))
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Parameter Section

    private var parameterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dial.medium")
                    .foregroundStyle(Color(pedal.colorName))
                Text("パラメータ")
                    .font(.headline)
            }

            // ノブスタイルの表示
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(Array(pedal.parameters.enumerated()), id: \.element.id) { index, param in
                    ParameterKnobView(
                        parameter: param,
                        color: Color(pedal.colorName),
                        onValueChanged: { newValue in
                            viewModel.updateParameter(
                                pedalID: pedal.id,
                                parameterIndex: index,
                                value: newValue
                            )
                        }
                    )
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - AUv3 UI Section

    private var auv3UISection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform.badge.plus")
                    .foregroundStyle(.blue)
                Text("AUv3 プラグイン UI")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                Image(systemName: "rectangle.dashed")
                    .font(.largeTitle)
                    .foregroundStyle(.quaternary)

                Text("CoreAudioKit AUViewController")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("AUv3 プラグインのカスタム UI を\nここに埋め込み表示します")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
                    .multilineTextAlignment(.center)

                Text("requestViewController → AUViewController / AUGenericViewController")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 3]))
                    .foregroundStyle(.quaternary)
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(role: .destructive) {
                viewModel.removePedal(pedal)
                dismiss()
            } label: {
                Label("このペダルを削除", systemImage: "trash")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - ParameterKnobView（パラメータノブ）

struct ParameterKnobView: View {
    let parameter: PedalParameter
    let color: Color
    let onValueChanged: (Float) -> Void

    var body: some View {
        VStack(spacing: 8) {
            // ノブ表示
            ZStack {
                // 外枠
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 64, height: 64)

                // 値インジケーター
                Circle()
                    .trim(from: 0, to: CGFloat(parameter.normalizedValue) * 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(135))

                // 値表示
                Text(parameter.formattedValue)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .monospacedDigit()
            }

            // パラメータ名
            Text(parameter.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            // スライダー
            Slider(
                value: Binding(
                    get: { parameter.value },
                    set: { onValueChanged($0) }
                ),
                in: parameter.range
            )
            .tint(color)
        }
        .padding(.vertical, 8)
    }
}
