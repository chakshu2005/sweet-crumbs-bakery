import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home, explore, favorites, cart, profile
    var id: Int { rawValue }
    var title: String {
        switch self { case .home: "Home"; case .explore: "Explore"; case .favorites: "Favorites"; case .cart: "Cart"; case .profile: "Profile" }
    }
    var icon: String {
        switch self { case .home: "house"; case .explore: "magnifyingglass"; case .favorites: "heart"; case .cart: "cart"; case .profile: "person" }
    }
}

/// App-wide state: login, favorites, orders, notifications and tab selection.
@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user = User.guest
    @Published var favorites: Set<Int> = []
    @Published var orders: [Order] = []
    @Published var notifications = AppNotification.samples
    @Published var selectedTab: AppTab = .home

    private struct Account { var name: String; var password: String }
    /// Fake "database". Demo login: demo@sweetcrumbs.com / bakery123
    private var accounts: [String: Account] = [
        "demo@sweetcrumbs.com": Account(name: "Chakshu", password: "bakery123")
    ]

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    // MARK: Auth
    func login(email: String, password: String) -> Bool {
        let key = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard let account = accounts[key], account.password == password else { return false }
        user = User(name: account.name, email: key)
        selectedTab = .home
        isLoggedIn = true
        return true
    }

    /// Returns an error message, or nil on success (and logs the user in).
    func register(name: String, email: String, password: String) -> String? {
        let key = email.trimmingCharacters(in: .whitespaces).lowercased()
        if accounts[key] != nil { return "An account with this email already exists." }
        accounts[key] = Account(name: name, password: password)
        _ = login(email: key, password: password)
        return nil
    }

    /// Simulated Google / Apple sign-in (no backend needed).
    func socialLogin(provider: String) {
        user = User(name: "Chakshu", email: "chakshu@\(provider.lowercased()).com")
        selectedTab = .home
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        selectedTab = .home
        user = .guest
    }

    // MARK: Favorites
    func isFavorite(_ p: Product) -> Bool { favorites.contains(p.id) }
    func toggleFavorite(_ p: Product) {
        if favorites.contains(p.id) { favorites.remove(p.id) } else { favorites.insert(p.id) }
    }

    // MARK: Orders
    func placeOrder(cart: CartManager, address: Address, delivery: DeliveryOption, payment: PaymentMethod) -> Order {
        let order = Order(number: "SC" + String(Int.random(in: 100_000...999_999)),
                          items: cart.items, address: address, delivery: delivery, payment: payment,
                          total: cart.total, isGift: cart.isGift, giftMessage: cart.giftMessage,
                          giftDate: cart.isGift ? cart.giftDate : nil)
        orders.insert(order, at: 0)
        notify("🍰", "Order placed", "Order #\(order.number) is confirmed.")
        simulateProgress(for: order.id)
        return order
    }

    func markAllRead() {
        for i in notifications.indices { notifications[i].isRead = true }
    }

    private func notify(_ emoji: String, _ title: String, _ message: String) {
        notifications.insert(AppNotification(emoji: emoji, title: title, message: message, time: "Just now"), at: 0)
    }

    /// Demo only: moves the order through every stage every 10 seconds.
    private func simulateProgress(for id: UUID) {
        Task {
            for stage in OrderStage.allCases.dropFirst() {
                try? await Task.sleep(for: .seconds(10))
                guard let i = orders.firstIndex(where: { $0.id == id }) else { return }
                withAnimation(.spring) { orders[i].stage = stage }
                switch stage {
                case .baking: notify("🍰", "Your order is being baked 🍰", "Fresh from the oven soon.")
                case .outForDelivery: notify("🚚", "Your order is out for delivery 🚚", "Get ready to open the door!")
                case .delivered: notify("🎉", "Delivered!", "Enjoy your treats.")
                default: break
                }
            }
        }
    }
}
