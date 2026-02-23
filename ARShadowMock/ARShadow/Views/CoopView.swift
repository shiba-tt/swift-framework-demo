import SwiftUI

struct CoopView: View {
    var viewModel: ARShadowViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)

                    Text("協力プレイ")
                        .font(.title2.bold())

                    Text("2人で協力して影絵パズルを解こう！\n1人が光源を操作、もう1人が物体を配置")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                if viewModel.coopManager.isConnected {
                    connectedView
                } else {
                    connectionOptions
                }

                Spacer()
            }
            .padding()
            .navigationTitle("マルチプレイ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Connection Options

    private var connectionOptions: some View {
        VStack(spacing: 16) {
            // Host
            Button {
                Task {
                    await viewModel.hostCoopSession()
                }
            } label: {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("セッションを作成")
                            .font(.headline)
                        Text("ホストとして他のプレイヤーを待つ")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // Join
            VStack(spacing: 12) {
                Text("セッションに参加")
                    .font(.headline)

                HStack {
                    TextField("セッションコード", text: $viewModel.joinCode)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .font(.title3.monospaced())

                    Button {
                        Task {
                            await viewModel.joinCoopSession()
                        }
                    } label: {
                        Text("参加")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.joinCode.count < 6)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Connected View

    private var connectedView: some View {
        VStack(spacing: 16) {
            // Session code
            if viewModel.coopManager.isHosting {
                VStack(spacing: 8) {
                    Text("セッションコード")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.coopManager.sessionCode)
                        .font(.system(.largeTitle, design: .monospaced).bold())
                        .foregroundStyle(.orange)
                }
                .padding()
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            }

            // Players
            VStack(alignment: .leading, spacing: 12) {
                Text("プレイヤー")
                    .font(.headline)

                ForEach(viewModel.coopManager.connectedPlayers) { player in
                    HStack {
                        Image(systemName: player.role.systemImage)
                            .foregroundStyle(.orange)
                        Text(player.name)
                            .font(.subheadline)
                        Spacer()
                        Text(player.role.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Circle()
                            .fill(player.isReady ? .green : .gray)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

            // Role info
            VStack(alignment: .leading, spacing: 8) {
                Text("役割分担")
                    .font(.headline)

                roleInfoRow(
                    icon: "sun.max.fill",
                    role: "光源担当",
                    desc: "光源の位置・強度を調整して影の形を操作"
                )
                roleInfoRow(
                    icon: "cube.fill",
                    role: "物体配置担当",
                    desc: "仮想オブジェクトを配置・回転して影を作る"
                )
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

            // Disconnect
            Button {
                viewModel.disconnectCoop()
            } label: {
                Label("切断", systemImage: "xmark.circle")
                    .foregroundStyle(.red)
            }
        }
    }

    private func roleInfoRow(icon: String, role: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(role)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    CoopView(viewModel: ARShadowViewModel())
}
