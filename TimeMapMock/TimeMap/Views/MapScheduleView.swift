import SwiftUI
import MapKit

/// 地図上にスケジュールを表示するメインマップ画面
struct MapScheduleView: View {
    @Bindable var viewModel: TimeMapViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 地図
                Map(position: $cameraPosition) {
                    // イベントマーカー
                    ForEach(viewModel.locatedEvents) { event in
                        if let coord = event.coordinate {
                            Annotation(event.title, coordinate: coord) {
                                EventMapPin(event: event)
                            }
                        }
                    }

                    // 移動ルート（ポリラインの代わりにマーカー間の視覚表示）
                    ForEach(viewModel.routes) { route in
                        Annotation(
                            route.travelTimeText,
                            coordinate: midpoint(route.origin, route.destination)
                        ) {
                            TravelTimeBadge(route: route)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))

                // 下部情報パネル
                bottomPanel
            }
            .navigationTitle("TimeMap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    transportTypePicker
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDatePicker = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(
                    selectedDate: viewModel.selectedDate,
                    onSelect: { date in
                        Task {
                            await viewModel.changeDate(to: date)
                        }
                        showDatePicker = false
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Components

    /// 移動手段ピッカー
    private var transportTypePicker: some View {
        Menu {
            ForEach(TransportType.allCases, id: \.self) { type in
                Button {
                    viewModel.selectedTransportType = type
                } label: {
                    Label(type.rawValue, systemImage: type.systemImageName)
                }
            }
        } label: {
            Image(systemName: viewModel.selectedTransportType.systemImageName)
        }
    }

    /// 下部情報パネル
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("読み込み中...")
                    .padding()
            } else if viewModel.locatedEvents.isEmpty {
                emptyStatePanel
            } else {
                summaryPanel
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    /// サマリーパネル
    private var summaryPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Label(
                    "\(viewModel.locatedEventCount)件の予定",
                    systemImage: "mappin.circle.fill"
                )
                .font(.subheadline.bold())
                .foregroundStyle(.indigo)

                Spacer()

                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                statItem(
                    icon: "arrow.triangle.turn.up.right.diamond",
                    label: "移動",
                    value: viewModel.totalTravelTimeText
                )
                statItem(
                    icon: "clock",
                    label: "空き",
                    value: viewModel.totalFreeTimeText
                )
                statItem(
                    icon: "calendar",
                    label: "予定",
                    value: "\(viewModel.totalEventCount)件"
                )
            }
        }
        .padding(16)
    }

    /// イベントがない時の表示
    private var emptyStatePanel: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("場所付きの予定がありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("カレンダーイベントに場所を設定すると\n地図上に表示されます")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
    }

    /// 統計アイテム
    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    /// 日付フォーマット
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: viewModel.selectedDate)
    }

    /// 2座標の中点を計算
    private func midpoint(
        _ a: CLLocationCoordinate2D,
        _ b: CLLocationCoordinate2D
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (a.latitude + b.latitude) / 2,
            longitude: (a.longitude + b.longitude) / 2
        )
    }
}

// MARK: - Supporting Views

/// 地図上のイベントピン
struct EventMapPin: View {
    let event: ScheduleEvent

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(colorForEvent)
                    .frame(width: 32, height: 32)

                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            Text(timeText)
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }

    private var colorForEvent: Color {
        switch event.calendarColor {
        case .blue: .blue
        case .red: .red
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        case .yellow: .yellow
        case .brown: .brown
        case .pink: .pink
        }
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: event.startDate)
    }
}

/// 移動時間バッジ
struct TravelTimeBadge: View {
    let route: TravelRoute

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: route.transportType.systemImageName)
                .font(.system(size: 10))
            Text(route.travelTimeText)
                .font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.indigo.opacity(0.85))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
}

/// 日付選択シート
struct DatePickerSheet: View {
    let selectedDate: Date
    let onSelect: (Date) -> Void

    @State private var pickerDate: Date

    init(selectedDate: Date, onSelect: @escaping (Date) -> Void) {
        self.selectedDate = selectedDate
        self.onSelect = onSelect
        self._pickerDate = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationStack {
            DatePicker(
                "日付を選択",
                selection: $pickerDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("日付を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("決定") {
                        onSelect(pickerDate)
                    }
                }
            }
        }
    }
}
