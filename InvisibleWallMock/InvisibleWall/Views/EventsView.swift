import SwiftUI

struct EventsView: View {
    let viewModel: InvisibleWallViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    eventStats()
                    eventList()
                }
                .padding()
            }
            .navigationTitle("セキュリティイベント")
        }
    }

    // MARK: - Event Stats

    private func eventStats() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日のイベント概要")
                .font(.headline)

            let events = viewModel.events
            let typeGroups = Dictionary(grouping: events) { $0.eventType }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(SecurityEventType.allCases.filter { typeGroups[$0] != nil }) { type in
                    VStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .foregroundStyle(type.color)
                        Text("\(typeGroups[type]?.count ?? 0)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(type.displayName)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Event List

    private func eventList() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("イベント履歴")
                .font(.headline)

            ForEach(viewModel.events) { event in
                eventRow(event)
            }
        }
    }

    private func eventRow(_ event: SecurityEvent) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(event.eventType.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: event.eventType.icon)
                    .font(.caption)
                    .foregroundStyle(event.eventType.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(event.eventType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(event.zone.displayName)
                        .font(.system(size: 9))
                        .foregroundStyle(event.zone.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(event.zone.color.opacity(0.1), in: Capsule())
                }

                HStack(spacing: 4) {
                    Image(systemName: "iphone")
                        .font(.system(size: 9))
                    Text(event.device)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(event.dateFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let d = event.distance {
                    Text(String(format: "%.1fm", d))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }
}
