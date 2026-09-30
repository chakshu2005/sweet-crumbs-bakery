import Foundation

struct User {
    var name: String
    var email: String
    var phone: String = ""

    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
    var initials: String { String(name.prefix(1)).uppercased() }
    static let guest = User(name: "Guest", email: "")
}

struct AppNotification: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let message: String
    let time: String
    var isRead = false

    static let samples: [AppNotification] = [
        AppNotification(emoji: "🎁", title: "20% OFF is waiting for you!", message: "Use code SWEET20 on your first order.", time: "Today"),
        AppNotification(emoji: "🧁", title: "New arrivals", message: "Vanilla Bean Cupcakes just came out of the oven.", time: "Yesterday", isRead: true)
    ]
}
