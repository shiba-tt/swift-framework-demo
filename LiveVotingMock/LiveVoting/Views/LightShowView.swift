import SwiftUI

struct LightShowView: View {
    @Bindable var viewModel: LiveVotingViewModel

    @State private var pulseScale: CGFloat = 1.0
    @State private var selectedColor: LightShowColor?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.lightShowActive {
                    activeView
                } else {
                    inactiveView
                }
            }
            .navigationTitle("ライトショー")
        }
    }

    // MARK: - Active View

    private var activeView: some View {
        viewModel.lightShowColor
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "light.max")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                        .onAppear { pulseScale = 1.2 }

                    Text("ライトショー参加中")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("スマホを掲げてスタジアムを彩ろう！")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    Button {
                        viewModel.deactivateLightShow()
                        pulseScale = 1.0
                    } label: {
                        Text("ライトショーを終了")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
    }

    // MARK: - Inactive View

    private var inactiveView: some View {
        ScrollView {
            VStack(spacing: 24) {
                infoHeader

                Text("色を選んで参加")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(LightShowColor.allCases, id: \.rawValue) { lightColor in
                        colorButton(lightColor)
                    }
                }

                if let color = selectedColor {
                    Button {
                        viewModel.activateLightShow(color: color.color)
                    } label: {
                        Label("ライトショーを開始", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(color.color)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Info Header

    private var infoHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("スタジアムライトショー")
                .font(.title2.bold())

            Text("あなたのスマホ画面がスタジアムの一部に。\n全員で同じ色を選んで会場を一色に染めよう！")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Color Button

    private func colorButton(_ lightColor: LightShowColor) -> some View {
        Button {
            selectedColor = lightColor
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(lightColor.color)
                    .frame(width: 60, height: 60)
                    .overlay {
                        if lightColor == .white {
                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        }
                    }
                    .shadow(color: lightColor.color.opacity(0.5), radius: 8)

                Text(lightColor.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedColor == lightColor ? lightColor.color.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if selectedColor == lightColor {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lightColor.color, lineWidth: 2)
                }
            }
        }
    }
}
