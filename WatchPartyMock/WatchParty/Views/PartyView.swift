import SwiftUI

struct PartyView: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let content = viewModel.selectedContent {
                        VideoPlayerCard(content: content, viewModel: viewModel)
                        PlaybackControls(viewModel: viewModel)
                        ReactionBar(viewModel: viewModel)
                        ParticipantStatusBar(viewModel: viewModel)
                        RecentReactionsView(viewModel: viewModel)
                    } else {
                        EmptyPartyView(viewModel: viewModel)
                    }
                }
                .padding()
            }
            .navigationTitle("WatchParty")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isSessionActive {
                        Menu {
                            Button {
                                viewModel.showParticipantList = true
                            } label: {
                                Label("参加者", systemImage: "person.2")
                            }
                            Button {
                                viewModel.showChat = true
                            } label: {
                                Label("チャット", systemImage: "bubble.left.and.bubble.right")
                            }
                            Button {
                                viewModel.togglePiP()
                            } label: {
                                Label(
                                    viewModel.isPiPActive ? "PiP 解除" : "PiP モード",
                                    systemImage: "pip"
                                )
                            }
                            Divider()
                            Button(role: .destructive) {
                                viewModel.endSession()
                            } label: {
                                Label("セッション終了", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showContentPicker) {
                LibraryView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showParticipantList) {
                ParticipantListSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showChat) {
                ChatSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Video Player Card

private struct VideoPlayerCard: View {
    let content: VideoContent
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Mock video area
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.black, Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(16 / 9, contentMode: .fit)

                VStack(spacing: 12) {
                    Image(systemName: content.thumbnailSystemImage)
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(content.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    if viewModel.isPiPActive {
                        Label("PiP モード", systemImage: "pip.fill")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }

                // Sync indicator
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("\(viewModel.syncedCount)/\(viewModel.totalParticipants)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(8)
                    }
                    Spacer()
                }

                // Floating reactions
                FloatingReactions(reactions: viewModel.recentReactions)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Seek bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 4)
                            .clipShape(Capsule())

                        Rectangle()
                            .fill(.indigo)
                            .frame(
                                width: geometry.size.width * viewModel.progress,
                                height: 4
                            )
                            .clipShape(Capsule())
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let fraction = max(0, min(1, value.location.x / geometry.size.width))
                                viewModel.seek(to: fraction)
                            }
                    )
                }
                .frame(height: 4)

                HStack {
                    Text(viewModel.currentTimeText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Spacer()
                    Text(viewModel.durationText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Playback Controls

private struct PlaybackControls: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        HStack(spacing: 24) {
            // Speed
            Button {
                viewModel.cyclePlaybackRate()
            } label: {
                Text(viewModel.playbackRateText)
                    .font(.caption.bold())
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()

            // Backward 15s
            Button {
                viewModel.seekBackward()
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title2)
            }

            // Play / Pause
            Button {
                viewModel.togglePlayback()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 52))
            }

            // Forward 15s
            Button {
                viewModel.seekForward()
            } label: {
                Image(systemName: "goforward.15")
                    .font(.title2)
            }

            Spacer()

            // Voice chat
            Button {
                viewModel.toggleVoiceChat()
            } label: {
                Image(
                    systemName: viewModel.isVoiceChatEnabled
                        ? "mic.circle.fill" : "mic.slash.circle"
                )
                .font(.title2)
                .foregroundStyle(viewModel.isVoiceChatEnabled ? .indigo : .secondary)
            }
        }
        .tint(.indigo)
        .padding(.horizontal)
    }
}

// MARK: - Reaction Bar

private struct ReactionBar: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Reaction.availableEmojis, id: \.self) { emoji in
                    Button {
                        viewModel.sendReaction(emoji)
                    } label: {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }

                Button {
                    viewModel.showChat = true
                } label: {
                    Image(systemName: "bubble.left.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .tint(.indigo)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Participant Status Bar

private struct ParticipantStatusBar: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("参加者", systemImage: "person.2.fill")
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    viewModel.showParticipantList = true
                } label: {
                    Text("すべて表示")
                        .font(.caption)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.participants) { participant in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(participant.avatarColor.color.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Text(String(participant.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundStyle(participant.avatarColor.color)

                                // Status dot
                                VStack {
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(participant.syncStatus.color)
                                            .frame(width: 12, height: 12)
                                            .overlay(
                                                Circle().stroke(.white, lineWidth: 2)
                                            )
                                    }
                                    Spacer()
                                }
                                .frame(width: 44, height: 44)
                            }

                            Text(participant.name)
                                .font(.caption2)
                                .lineLimit(1)

                            if participant.isHost {
                                Text("ホスト")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.indigo)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 1)
                                    .background(.indigo.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Recent Reactions View

private struct RecentReactionsView: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        if !viewModel.recentReactions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("リアクション", systemImage: "face.smiling")
                    .font(.subheadline.bold())

                ForEach(viewModel.recentReactions) { reaction in
                    HStack(spacing: 8) {
                        Text(reaction.emoji)
                            .font(.title3)
                        VStack(alignment: .leading) {
                            Text(reaction.participantName)
                                .font(.caption.bold())
                            Text(reaction.timestampText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Floating Reactions

private struct FloatingReactions: View {
    let reactions: [Reaction]

    var body: some View {
        ZStack {
            ForEach(reactions.suffix(3)) { reaction in
                Text(reaction.emoji)
                    .font(.largeTitle)
                    .offset(
                        x: CGFloat.random(in: -80...80),
                        y: CGFloat.random(in: -60...60)
                    )
                    .opacity(0.8)
            }
        }
    }
}

// MARK: - Empty Party View

private struct EmptyPartyView: View {
    @Bindable var viewModel: WatchPartyViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "play.rectangle.on.rectangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.indigo.opacity(0.5))

            VStack(spacing: 8) {
                Text("WatchParty を始めよう")
                    .font(.title2.bold())
                Text("友人と一緒に動画を同期視聴\n音声チャット・リアクションで盛り上がろう")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    viewModel.showContentPicker = true
                } label: {
                    Label("コンテンツを選ぶ", systemImage: "film")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack(spacing: 16) {
                    FeatureItem(icon: "shareplay", title: "同期再生")
                    FeatureItem(icon: "mic.fill", title: "音声チャット")
                    FeatureItem(icon: "face.smiling", title: "リアクション")
                    FeatureItem(icon: "pip.fill", title: "PiP対応")
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
    }
}

private struct FeatureItem: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.indigo)
                .frame(width: 44, height: 44)
                .background(.indigo.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Participant List Sheet

private struct ParticipantListSheet: View {
    @Bindable var viewModel: WatchPartyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("参加中 (\(viewModel.totalParticipants)人)") {
                    ForEach(viewModel.participants) { participant in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(participant.avatarColor.color.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Text(String(participant.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundStyle(participant.avatarColor.color)
                            }

                            VStack(alignment: .leading) {
                                HStack {
                                    Text(participant.name)
                                        .font(.body)
                                    if participant.isHost {
                                        Text("ホスト")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.indigo.opacity(0.1))
                                            .foregroundStyle(.indigo)
                                            .clipShape(Capsule())
                                    }
                                }
                                HStack(spacing: 4) {
                                    Image(systemName: participant.syncStatus.systemImage)
                                        .foregroundStyle(participant.syncStatus.color)
                                    Text(participant.syncStatus.rawValue)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                            }

                            Spacer()

                            if participant.isMuted {
                                Image(systemName: "mic.slash.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        viewModel.showInviteSheet = true
                    } label: {
                        Label("友達を招待", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("参加者")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert("友達を招待", isPresented: $viewModel.showInviteSheet) {
                TextField("名前", text: $viewModel.inviteName)
                Button("招待") { viewModel.inviteParticipant() }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }
}

// MARK: - Chat Sheet

private struct ChatSheet: View {
    @Bindable var viewModel: WatchPartyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.chatMessages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }

                Divider()

                HStack(spacing: 8) {
                    TextField("メッセージを入力...", text: $viewModel.chatInputText)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        viewModel.sendChatMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.indigo)
                    }
                    .disabled(
                        viewModel.chatInputText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
                .padding()
            }
            .navigationTitle("チャット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var isMe: Bool { message.senderName == "あなた" }

    var body: some View {
        HStack {
            if isMe { Spacer() }
            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
                if !isMe {
                    Text(message.senderName)
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isMe ? Color.indigo : Color(.systemGray5))
                    .foregroundStyle(isMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(message.timestampText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            if !isMe { Spacer() }
        }
    }
}
