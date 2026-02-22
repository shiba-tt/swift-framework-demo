import SwiftUI

struct GameFieldView: View {
    let viewModel: ProximityPartyViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let session = viewModel.session {
                gameHeader(session)
                radarView(session)
                gameControls(session)
            }
        }
        .navigationTitle(viewModel.session?.mode.rawValue ?? "ゲーム")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("終了") { viewModel.endGame() }
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Header

    private func gameHeader(_ session: GameSession) -> some View {
        HStack {
            Label(session.state.rawValue, systemImage: session.state.icon)
                .font(.subheadline.bold())
                .foregroundStyle(.blue)

            Spacer()

            if session.mode == .distanceQuiz {
                Text("R\(session.roundNumber)/\(session.totalRounds)")
                    .font(.subheadline.monospacedDigit())
            }

            if session.mode == .spatialTag {
                Label("\(session.timeRemaining)秒", systemImage: "timer")
                    .font(.subheadline.monospacedDigit())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Radar

    private func radarView(_ session: GameSession) -> some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // 同心円
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { ratio in
                    Circle()
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                        .frame(
                            width: maxRadius * 2 * ratio,
                            height: maxRadius * 2 * ratio
                        )
                }

                // 十字線
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - maxRadius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + maxRadius))
                    path.move(to: CGPoint(x: center.x - maxRadius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + maxRadius, y: center.y))
                }
                .stroke(.gray.opacity(0.15), lineWidth: 1)

                // 距離ラベル
                ForEach([3, 6, 9, 12], id: \.self) { distance in
                    let ratio = CGFloat(distance) / 15.0
                    Text("\(distance)m")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(
                            x: center.x + maxRadius * ratio + 15,
                            y: center.y - 5
                        )
                }

                // 自分（中央）
                Circle()
                    .fill(.blue)
                    .frame(width: 16, height: 16)
                    .position(center)
                Text("自分")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .position(x: center.x, y: center.y + 16)

                // プレイヤードット
                ForEach(session.players) { player in
                    let normalizedDistance = min(CGFloat(player.distance) / 15.0, 1.0)
                    let angle = player.angle
                    let x = center.x + maxRadius * normalizedDistance * CGFloat(sin(angle))
                    let y = center.y - maxRadius * normalizedDistance * CGFloat(cos(angle))

                    playerDot(player, session: session)
                        .position(x: x, y: y)
                }
            }
        }
        .padding()
    }

    private func playerDot(_ player: Player, session: GameSession) -> some View {
        VStack(spacing: 2) {
            ZStack {
                // タグ範囲表示（鬼ごっこモード）
                if session.mode == .spatialTag && player.id == session.currentTaggerId {
                    Circle()
                        .stroke(.red.opacity(0.3), lineWidth: 2)
                        .frame(width: 40, height: 40)
                }

                Text(player.avatarEmoji)
                    .font(.title3)

                if player.isTagged && session.mode == .spatialTag {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .offset(x: 10, y: -10)
                }
            }

            Text(player.name)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(player.distanceText)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Controls

    @ViewBuilder
    private func gameControls(_ session: GameSession) -> some View {
        VStack(spacing: 12) {
            switch session.mode {
            case .spatialTag:
                tagGameControls(session)
            case .treasureHunt:
                treasureHuntControls(session)
            case .distanceQuiz:
                distanceQuizControls(session)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func tagGameControls(_ session: GameSession) -> some View {
        VStack(spacing: 8) {
            if let taggerId = session.currentTaggerId,
               let tagger = session.players.first(where: { $0.id == taggerId }) {
                Label("鬼: \(tagger.name) \(tagger.avatarEmoji)", systemImage: "figure.run")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
            }

            let nearbyPlayers = session.players.filter { $0.distance <= session.mode.tagDistance && !$0.isTagged }
            if !nearbyPlayers.isEmpty {
                ForEach(nearbyPlayers) { player in
                    Button {
                        viewModel.tagPlayer(player)
                    } label: {
                        Label("\(player.name)をタッチ!", systemImage: "hand.tap.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else {
                Text("3m 以内にプレイヤーがいません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // スコアボード
            HStack(spacing: 16) {
                ForEach(session.players.prefix(4)) { player in
                    VStack {
                        Text(player.avatarEmoji)
                        Text("\(session.scores[player.id, default: 0])")
                            .font(.caption.monospacedDigit())
                    }
                }
            }
        }
    }

    private func treasureHuntControls(_ session: GameSession) -> some View {
        VStack(spacing: 8) {
            if let treasureId = session.treasureHolderId,
               let treasure = session.players.first(where: { $0.id == treasureId }) {
                let hint = viewModel.treasureHint(for: treasure.distance)
                Label(hint.rawValue, systemImage: hint.icon)
                    .font(.title3.bold())
                    .foregroundStyle(hint == .burning || hint == .hot ? .red : .blue)

                Text("宝までの距離: \(treasure.distanceText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if treasure.distance < 1.0 {
                    Button {
                        viewModel.findTreasure()
                    } label: {
                        Label("宝を発見!", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
    }

    private func distanceQuizControls(_ session: GameSession) -> some View {
        VStack(spacing: 8) {
            if let target = session.quizTargetDistance {
                Text("2人のプレイヤー間の距離は?")
                    .font(.subheadline.bold())

                if session.state == .finished {
                    Text("正解: \(String(format: "%.2f", target)) m")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    HStack {
                        TextField("推定距離 (m)", text: $viewModel.quizGuess)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)

                        Button("回答") {
                            viewModel.submitQuizGuess()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.quizGuess.isEmpty)
                    }
                }
            }

            if !viewModel.quizResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("結果")
                        .font(.caption.bold())
                    ForEach(viewModel.quizResults.suffix(session.players.count)) { result in
                        HStack {
                            Text(result.playerName)
                                .font(.caption)
                            Spacer()
                            Text(result.errorText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
