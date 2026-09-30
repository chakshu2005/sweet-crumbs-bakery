import SwiftUI

struct Address: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
    var street: String
    var city: String
    var pincode: String
    var oneLine: String { "\(street), \(city) – \(pincode)" }
}

enum DeliveryOption: String, CaseIterable, Identifiable {
    case standard = "Standard Delivery", express = "Express Delivery", pickup = "Pickup from Store"
    var id: String { rawValue }
    var fee: Double { switch self { case .standard: 49; case .express: 99; case .pickup: 0 } }
    var eta: String { switch self { case .standard: "45–60 min"; case .express: "20–30 min"; case .pickup: "Ready in 30 min" } }
    var icon: String { switch self { case .standard: "bicycle"; case .express: "bolt.fill"; case .pickup: "storefront.fill" } }
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    case upi = "UPI", card = "Credit / Debit Card", cod = "Cash on Delivery", applePay = "Apple Pay"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .upi: "indianrupeesign.circle.fill"
        case .card: "creditcard.fill"
        case .cod: "banknote.fill"
        case .applePay: "apple.logo"
        }
    }
}

enum OrderStage: Int, CaseIterable, Identifiable {
    case placed, baking, packed, outForDelivery, delivered
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .placed: "Order Placed"
        case .baking: "Baking"
        case .packed: "Packed"
        case .outForDelivery: "Out for Delivery"
        case .delivered: "Delivered"
        }
    }
    var caption: String {
        switch self {
        case .placed: "We received your order"
        case .baking: "Our bakers are on it 🍰"
        case .packed: "Boxed with love"
        case .outForDelivery: "Your treats are on the way 🚚"
        case .delivered: "Enjoy every crumb!"
        }
    }
}

struct Order: Identifiable {
    let id = UUID()
    let number: String
    let items: [CartItem]
    let address: Address
    let delivery: DeliveryOption
    let payment: PaymentMethod
    let total: Double
    let date = Date()
    var stage: OrderStage = .placed
    var isGift = false
    var giftMessage = ""
    var giftDate: Date? = nil
}

struct Offer: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let code: String
    let emoji: String
    let colors: [Color]

    static let samples: [Offer] = [
        Offer(title: "20% OFF", subtitle: "On your first order", code: "SWEET20", emoji: "🎂",
              colors: [Color(red: 0.98, green: 0.72, blue: 0.76), Color(red: 0.95, green: 0.55, blue: 0.62)]),
        Offer(title: "BUY 2 GET 1", subtitle: "Selected cupcakes", code: "BUY2GET1", emoji: "🧁",
              colors: [Color(red: 1.0, green: 0.80, blue: 0.62), Color(red: 0.95, green: 0.62, blue: 0.40)]),
        Offer(title: "FREE DELIVERY", subtitle: "On orders above ₹999", code: "FREEDEL", emoji: "🚚",
              colors: [Color(red: 0.80, green: 0.62, blue: 0.45), Color(red: 0.55, green: 0.36, blue: 0.26)])
    ]
}
