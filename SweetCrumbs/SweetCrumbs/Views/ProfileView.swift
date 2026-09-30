import SwiftUI

struct InfoRow: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

/// Simple reusable list screen (saved addresses, payment methods, help, about).
struct SimpleInfoView: View {
    let title: String
    let rows: [InfoRow]
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(rows) { row in
                    HStack(spacing: 14) {
                        Image(systemName: row.icon).foregroundStyle(Theme.rose)
                            .frame(width: 44, height: 44).background(Theme.pink.opacity(0.3), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title).font(.subheadline.bold()).foregroundStyle(Theme.text)
                            Text(row.subtitle).font(.caption).foregroundStyle(Theme.subtext)
                        }
                        Spacer()
                    }
                    .cardStyle(padding: 14)
                }
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(title)
    }
}

struct MyOrdersView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ScrollView {
            if appState.orders.isEmpty {
                EmptyStateView(emoji: "📦", title: "No orders yet", message: "Your placed orders will appear here.")
                    .padding(.top, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(appState.orders) { order in
                        NavigationLink { OrderTrackingView(orderID: order.id) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order #\(order.number)").font(.headline)
                                    Text("\(order.items.count) item(s) • \(order.total.rupees)")
                                        .font(.caption).foregroundStyle(Theme.subtext)
                                    Text(order.stage.title).font(.caption.bold()).foregroundStyle(Theme.rose)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(Theme.subtext)
                            }
                            .foregroundStyle(Theme.text)
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Orders")
    }
}

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Your details") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone).keyboardType(.phonePad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty { appState.user.name = name }
                        if email.isValidEmail { appState.user.email = email }
                        appState.user.phone = phone
                        dismiss()
                    }
                }
            }
            .onAppear { name = appState.user.name; email = appState.user.email; phone = appState.user.phone }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cart: CartManager
    @State private var showEdit = false
    @State private var showLogout = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(appState.user.initials)
                        .font(.system(size: 40, weight: .bold, design: .serif)).foregroundStyle(.white)
                        .frame(width: 96, height: 96).background(Theme.brandGradient, in: Circle())
                        .overlay(Circle().stroke(Theme.card, lineWidth: 4))
                        .shadow(color: Theme.rose.opacity(0.35), radius: 10, y: 6)
                    Text(appState.user.name).font(.system(.title2, design: .serif).bold()).foregroundStyle(Theme.text)
                    Text(appState.user.email).font(.subheadline).foregroundStyle(Theme.subtext)
                }
                .padding(.top, 10)

                VStack(spacing: 0) {
                    Button { showEdit = true } label: { row("pencil", "Edit Profile") }
                    divider
                    NavigationLink { MyOrdersView() } label: { row("bag.fill", "My Orders") }
                    divider
                    Button { appState.selectedTab = .favorites } label: { row("heart.fill", "Favorites") }
                    divider
                    NavigationLink {
                        SimpleInfoView(title: "Saved Addresses", rows: [
                            InfoRow(icon: "house.fill", title: "Home", subtitle: "12 Rose Garden Lane, Delhi – 110043"),
                            InfoRow(icon: "briefcase.fill", title: "Work", subtitle: "5 Cyber Hub, Gurugram – 122002")
                        ])
                    } label: { row("mappin.and.ellipse", "Saved Addresses") }
                    divider
                    NavigationLink {
                        SimpleInfoView(title: "Payment Methods", rows: [
                            InfoRow(icon: "creditcard.fill", title: "Visa •••• 4242", subtitle: "Expires 09/28"),
                            InfoRow(icon: "indianrupeesign.circle.fill", title: "UPI", subtitle: "chakshu@upi")
                        ])
                    } label: { row("creditcard.fill", "Payment Methods") }
                    divider
                    NavigationLink { NotificationsView() } label: { row("bell.fill", "Notifications") }
                    divider
                    NavigationLink {
                        SimpleInfoView(title: "Help & Support", rows: [
                            InfoRow(icon: "phone.fill", title: "Call us", subtitle: "+91 98765 43210"),
                            InfoRow(icon: "envelope.fill", title: "Email", subtitle: "hello@sweetcrumbs.com"),
                            InfoRow(icon: "questionmark.circle.fill", title: "FAQs", subtitle: "Orders, delivery and refunds")
                        ])
                    } label: { row("questionmark.circle.fill", "Help & Support") }
                    divider
                    NavigationLink {
                        SimpleInfoView(title: "About Us", rows: [
                            InfoRow(icon: "heart.text.square.fill", title: "Sweet Crumbs Bakery",
                                    subtitle: "Small-batch baking since 2015. Everything is made fresh daily with real butter and lots of love."),
                            InfoRow(icon: "info.circle.fill", title: "Version", subtitle: "1.0.0")
                        ])
                    } label: { row("info.circle.fill", "About Us") }
                }
                .cardStyle(padding: 6)

                Button(role: .destructive) { showLogout = true } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .sheet(isPresented: $showEdit) { EditProfileView() }
        .confirmationDialog("Log out of Sweet Crumbs?", isPresented: $showLogout, titleVisibility: .visible) {
            Button("Logout", role: .destructive) {
                cart.clear()
                appState.logout()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var divider: some View { Divider().padding(.leading, 60) }

    private func row(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).foregroundStyle(Theme.rose)
                .frame(width: 36, height: 36).background(Theme.pink.opacity(0.3), in: Circle())
            Text(title).foregroundStyle(Theme.text)
            Spacer()
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Theme.subtext)
        }
        .padding(10)
        .contentShape(Rectangle())
    }
}
