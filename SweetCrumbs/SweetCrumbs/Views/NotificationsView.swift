import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            if appState.notifications.isEmpty {
                EmptyStateView(emoji: "🔔", title: "All caught up", message: "No notifications right now.")
            } else {
                VStack(spacing: 12) {
                    ForEach(appState.notifications) { n in
                        HStack(alignment: .top, spacing: 14) {
                            Text(n.emoji).font(.title2)
                                .frame(width: 48, height: 48).background(Theme.pink.opacity(0.35), in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(n.title).font(.subheadline.bold()).foregroundStyle(Theme.text)
                                Text(n.message).font(.caption).foregroundStyle(Theme.subtext)
                                Text(n.time).font(.caption2).foregroundStyle(Theme.caramel)
                            }
                            Spacer()
                            if !n.isRead { Circle().fill(Theme.rose).frame(width: 9, height: 9) }
                        }
                        .cardStyle(padding: 14)
                    }
                }
                .padding(20)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Notifications")
        .onDisappear { appState.markAllRead() }
    }
}
