import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var size: ProductSize
    var addOns: [AddOn]
    var message: String
    var quantity: Int

    /// Price of ONE unit including size and add-ons.
    var unitPrice: Double {
        product.price * size.multiplier + addOns.reduce(0) { $0 + $1.price }
    }
    var total: Double { unitPrice * Double(quantity) }

    /// e.g. "Medium • Birthday candles • “Happy Birthday”"
    var optionsSummary: String {
        var parts = [size.rawValue] + addOns.filter { $0 != .message }.map(\.rawValue)
        if !message.isEmpty { parts.append("“\(message)”") }
        return parts.joined(separator: " • ")
    }
}
