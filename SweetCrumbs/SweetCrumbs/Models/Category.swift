import Foundation

enum ProductCategory: String, CaseIterable, Identifiable {
    case cakes = "Cakes", pastries = "Pastries", cupcakes = "Cupcakes", cookies = "Cookies"
    case donuts = "Donuts", breads = "Breads", beverages = "Beverages"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cakes: "🎂"
        case .pastries: "🥐"
        case .cupcakes: "🧁"
        case .cookies: "🍪"
        case .donuts: "🍩"
        case .breads: "🍞"
        case .beverages: "☕"
        }
    }
}
