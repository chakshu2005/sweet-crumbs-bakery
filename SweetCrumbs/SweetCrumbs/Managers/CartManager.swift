import SwiftUI

/// Cart contents, coupon logic, price totals and gift-mode settings.
@MainActor
final class CartManager: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published var couponCode: String?
    @Published var deliveryOption: DeliveryOption = .standard
    @Published var isGift = false
    @Published var giftWrap = true
    @Published var giftMessage = ""
    @Published var giftDate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now

    // MARK: Totals
    var count: Int { items.reduce(0) { $0 + $1.quantity } }
    var subtotal: Double { items.reduce(0) { $0 + $1.total } }

    var discount: Double {
        switch couponCode {
        case "SWEET20":
            return subtotal * 0.20
        case "BUY2GET1":
            // For every 3 cupcakes, one is free.
            return items.filter { $0.product.category == .cupcakes }
                .reduce(0) { $0 + Double($1.quantity / 3) * $1.unitPrice }
        default:
            return 0
        }
    }

    var deliveryCharge: Double {
        guard !items.isEmpty else { return 0 }
        if couponCode == "FREEDEL" && subtotal >= 999 { return 0 }
        return deliveryOption.fee
    }

    var giftWrapFee: Double { isGift && giftWrap && !items.isEmpty ? 59 : 0 }
    var total: Double { max(subtotal - discount + deliveryCharge + giftWrapFee, 0) }

    // MARK: Actions
    func add(_ product: Product, size: ProductSize = .small, addOns: Set<AddOn> = [],
             message: String = "", quantity: Int = 1) {
        let sorted = AddOn.allCases.filter { addOns.contains($0) }
        // Same product + same options = just increase quantity.
        if let i = items.firstIndex(where: {
            $0.product.id == product.id && $0.size == size && $0.addOns == sorted && $0.message == message
        }) {
            items[i].quantity += quantity
        } else {
            items.append(CartItem(product: product, size: size, addOns: sorted, message: message, quantity: quantity))
        }
    }

    func changeQuantity(of id: UUID, by delta: Int) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].quantity += delta
        if items[i].quantity <= 0 { items.remove(at: i) }
    }

    func remove(_ id: UUID) { items.removeAll { $0.id == id } }

    func clear() {
        items.removeAll()
        couponCode = nil
        isGift = false
        giftMessage = ""
        deliveryOption = .standard
    }

    /// Returns true if the code is valid and was applied.
    func applyCoupon(_ raw: String) -> Bool {
        let code = raw.trimmingCharacters(in: .whitespaces).uppercased()
        guard Offer.samples.contains(where: { $0.code == code }) else { return false }
        couponCode = code
        return true
    }
}
