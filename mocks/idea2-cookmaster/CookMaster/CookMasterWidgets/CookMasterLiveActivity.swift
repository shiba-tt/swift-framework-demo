import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

// MARK: - CookMaster Live Activity Widget Bundle

/// Widget Extension のエントリーポイント
@main
struct CookMasterWidgets: WidgetBundle {
    var body: some Widget {
        CookMasterLiveActivity()
    }
}

// MARK: - Live Activity Widget

/// 料理タイマーの Live Activity 表示を管理する Widget
struct CookMasterLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // AlarmKit の AlarmAttributes を使用して Live Activity を構成
        // CookingAlarmMetadata.activityConfiguration で定義された UI が表示される
        ActivityConfiguration(for: AlarmAttributes<CookingAlarmMetadata>.self) { context in
            // MARK: ロック画面 / StandBy / バナー表示
            CookMasterLockScreenView(context: context)
        } dynamicIsland: { context in
            // MARK: Dynamic Island 表示
            DynamicIsland {
                // 展開時 — 詳細表示
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text(context.attributes.metadata.emoji)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(context.attributes.metadata.timerName)
                                .font(.headline)
                                .lineLimit(1)
                            Text(context.attributes.metadata.category.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if context.state.isCountingDown {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("調理中")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.red)
                            Text("完了!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .bold()
                        }
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    // 中央にはカウントダウン表示
                    if context.state.isCountingDown {
                        Text("残り時間")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCountingDown {
                        // カウントダウン中: プログレスバー風表示
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            ProgressView(value: 0.5)
                                .tint(.orange)
                            Text("調理中...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                    } else {
                        // アラート中: アクションボタン
                        HStack(spacing: 12) {
                            Text("\(context.attributes.metadata.emoji) \(context.attributes.metadata.timerName)が完了!")
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
            } compactLeading: {
                // コンパクト表示（左）— 絵文字アイコン
                HStack(spacing: 4) {
                    Text(context.attributes.metadata.emoji)
                    Text(context.attributes.metadata.timerName)
                        .font(.caption2)
                        .lineLimit(1)
                }
            } compactTrailing: {
                // コンパクト表示（右）— 残り時間 or ベルアイコン
                if context.state.isCountingDown {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } minimal: {
                // 最小表示 — 絵文字のみ
                ZStack {
                    if context.state.isCountingDown {
                        Text(context.attributes.metadata.emoji)
                            .font(.caption)
                    } else {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

// MARK: - ロック画面ビュー

/// ロック画面・StandBy に表示される詳細な Live Activity UI
struct CookMasterLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<CookingAlarmMetadata>>

    var body: some View {
        VStack(spacing: 12) {
            // ヘッダー行
            HStack(alignment: .top) {
                // 左: アイコン + 情報
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(context.state.isCountingDown ? Color.orange.opacity(0.2) : Color.red.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Text(context.attributes.metadata.emoji)
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.metadata.timerName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(context.attributes.metadata.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // 右: ステータスバッジ
                statusBadge
            }

            Divider()

            // メインコンテンツ
            if context.state.isCountingDown {
                // カウントダウン中
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("調理中")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    // プログレスバー
                    ProgressView(value: 0.5)
                        .tint(.orange)

                    HStack {
                        Text("残り時間")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("サイレントモードでも完了時に通知します")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                // アラート中（タイマー完了）
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.red)
                        Text("\(context.attributes.metadata.timerName)が完了しました!")
                            .font(.subheadline)
                            .bold()
                        Spacer()
                    }

                    Text("「完了」をタップするか、「+1分追加」で延長できます")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }

    private var statusBadge: some View {
        Group {
            if context.state.isCountingDown {
                Label("調理中", systemImage: "flame.fill")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            } else {
                Label("完了", systemImage: "checkmark.circle.fill")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Widget Extension Info.plist

/// CookMasterWidgets の Info.plist に必要な設定:
///
/// ```xml
/// <key>NSExtension</key>
/// <dict>
///     <key>NSExtensionPointIdentifier</key>
///     <string>com.apple.widgetkit-extension</string>
/// </dict>
/// <key>NSSupportsLiveActivities</key>
/// <true/>
/// ```
