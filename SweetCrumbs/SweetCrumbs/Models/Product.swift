import SwiftUI

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let blurb: String          // short text for cards
    let details: String        // long text for the detail page
    let price: Double          // base price (Small size)
    let rating: Double
    let reviews: Int
    let category: ProductCategory
    let emoji: String
    let tint: Color
    let ingredients: [String]
    var isPopular: Bool = false

    /// Optional asset name: add an image called "product_<id>" to Assets.xcassets.
    var imageName: String { "product_\(id)" }

    // Identity is the id only, so navigation values and favorites stay stable.
    static func == (l: Product, r: Product) -> Bool { l.id == r.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum ProductSize: String, CaseIterable, Identifiable {
    case small = "Small", medium = "Medium", large = "Large"
    var id: String { rawValue }
    var multiplier: Double {
        switch self { case .small: 1.0; case .medium: 1.35; case .large: 1.8 }
    }
    var caption: String {
        switch self { case .small: "Serves 1–2"; case .medium: "Serves 3–4"; case .large: "Serves 6+" }
    }
}

enum AddOn: String, CaseIterable, Identifiable, Hashable {
    case extraChocolate = "Extra chocolate"
    case candles = "Birthday candles"
    case message = "Custom message"
    case giftBox = "Gift packaging"

    var id: String { rawValue }
    var price: Double {
        switch self { case .extraChocolate: 49; case .candles: 29; case .message: 0; case .giftBox: 59 }
    }
    var icon: String {
        switch self {
        case .extraChocolate: "cube.fill"
        case .candles: "flame.fill"
        case .message: "text.bubble.fill"
        case .giftBox: "gift.fill"
        }
    }
}

// MARK: - Sample data
extension Product {
    static let samples: [Product] = [
        Product(id: 1, name: "Chocolate Truffle Cake", blurb: "Dark ganache, silky layers",
                details: "Three layers of moist cocoa sponge wrapped in velvety dark chocolate ganache and finished with hand-shaved truffle curls.",
                price: 699, rating: 4.8, reviews: 214, category: .cakes, emoji: "🎂",
                tint: Color(red: 0.55, green: 0.33, blue: 0.24),
                ingredients: ["Dark chocolate", "Cocoa", "Fresh cream", "Butter", "Free-range eggs"], isPopular: true),
        Product(id: 2, name: "Red Velvet Cake", blurb: "Cream cheese frosting",
                details: "Crimson buttermilk sponge with a tangy cream cheese frosting and a soft vanilla finish.",
                price: 799, rating: 4.9, reviews: 342, category: .cakes, emoji: "🍰",
                tint: Color(red: 0.85, green: 0.30, blue: 0.38),
                ingredients: ["Buttermilk", "Cream cheese", "Cocoa", "Vanilla", "Flour"], isPopular: true),
        Product(id: 3, name: "Strawberry Cupcake", blurb: "Berry buttercream swirl",
                details: "Fluffy vanilla cupcake filled with strawberry compote and topped with a pink buttercream swirl.",
                price: 149, rating: 4.7, reviews: 128, category: .cupcakes, emoji: "🧁",
                tint: Color(red: 0.98, green: 0.62, blue: 0.70),
                ingredients: ["Strawberries", "Butter", "Vanilla", "Sugar", "Eggs"], isPopular: true),
        Product(id: 4, name: "Chocolate Croissant", blurb: "Flaky, buttery, molten",
                details: "Laminated butter croissant baked golden with two bars of dark chocolate melting inside.",
                price: 129, rating: 4.6, reviews: 187, category: .pastries, emoji: "🥐",
                tint: Color(red: 0.90, green: 0.65, blue: 0.35),
                ingredients: ["Butter", "Dark chocolate", "Flour", "Yeast", "Milk"], isPopular: true),
        Product(id: 5, name: "Classic Donut", blurb: "Soft, glazed, pillowy",
                details: "Our signature yeast donut, fried fresh each morning and dipped in a sweet vanilla glaze.",
                price: 99, rating: 4.5, reviews: 96, category: .donuts, emoji: "🍩",
                tint: Color(red: 0.95, green: 0.72, blue: 0.80),
                ingredients: ["Flour", "Yeast", "Sugar", "Vanilla glaze", "Milk"], isPopular: true),
        Product(id: 6, name: "Blueberry Cheesecake", blurb: "Baked, creamy, jammy",
                details: "Baked New York-style cheesecake on a buttery biscuit base, crowned with slow-cooked blueberry compote.",
                price: 499, rating: 4.8, reviews: 156, category: .cakes, emoji: "🍰",
                tint: Color(red: 0.45, green: 0.45, blue: 0.75),
                ingredients: ["Cream cheese", "Blueberries", "Biscuit base", "Eggs", "Lemon"], isPopular: true),
        Product(id: 7, name: "Choco Chip Cookies", blurb: "Box of 6, gooey centres",
                details: "Brown-butter cookies loaded with chocolate chunks and finished with a pinch of sea salt.",
                price: 179, rating: 4.6, reviews: 203, category: .cookies, emoji: "🍪",
                tint: Color(red: 0.80, green: 0.60, blue: 0.38),
                ingredients: ["Brown butter", "Chocolate chunks", "Flour", "Brown sugar", "Sea salt"]),
        Product(id: 8, name: "Sourdough Loaf", blurb: "48-hour slow ferment",
                details: "Crackly crust, open crumb and gentle tang from a house starter that is over five years old.",
                price: 220, rating: 4.7, reviews: 88, category: .breads, emoji: "🍞",
                tint: Color(red: 0.85, green: 0.68, blue: 0.45),
                ingredients: ["Sourdough starter", "Wheat flour", "Water", "Sea salt"], isPopular: true),
        Product(id: 9, name: "Almond Croissant", blurb: "Frangipane filled",
                details: "Twice-baked croissant filled with almond cream and topped with toasted flaked almonds.",
                price: 149, rating: 4.5, reviews: 74, category: .pastries, emoji: "🥐",
                tint: Color(red: 0.93, green: 0.75, blue: 0.50),
                ingredients: ["Almonds", "Butter", "Flour", "Sugar", "Eggs"]),
        Product(id: 10, name: "Vanilla Bean Cupcake", blurb: "Classic with real vanilla",
                details: "Cloud-soft vanilla bean sponge with whipped vanilla buttercream and rainbow sprinkles.",
                price: 139, rating: 4.4, reviews: 65, category: .cupcakes, emoji: "🧁",
                tint: Color(red: 0.98, green: 0.85, blue: 0.62),
                ingredients: ["Vanilla beans", "Butter", "Sugar", "Eggs", "Sprinkles"]),
        Product(id: 11, name: "Caramel Latte", blurb: "Espresso with salted caramel",
                details: "Double-shot espresso, steamed milk and house-made salted caramel sauce.",
                price: 189, rating: 4.6, reviews: 141, category: .beverages, emoji: "☕",
                tint: Color(red: 0.72, green: 0.48, blue: 0.30),
                ingredients: ["Espresso", "Milk", "Salted caramel"]),
        Product(id: 12, name: "Sprinkle Glazed Donut", blurb: "Pink glaze, rainbow crunch",
                details: "Fluffy ring donut with strawberry glaze and a shower of rainbow sprinkles.",
                price: 119, rating: 4.5, reviews: 92, category: .donuts, emoji: "🍩",
                tint: Color(red: 0.98, green: 0.68, blue: 0.75),
                ingredients: ["Flour", "Strawberry glaze", "Sprinkles", "Yeast"]),
        Product(id: 13, name: "Iced Mocha", blurb: "Chocolate + espresso over ice",
                details: "Cold espresso, dark chocolate sauce and milk poured over ice with a cream cap.",
                price: 199, rating: 4.4, reviews: 58, category: .beverages, emoji: "☕",
                tint: Color(red: 0.50, green: 0.32, blue: 0.24),
                ingredients: ["Espresso", "Chocolate sauce", "Milk", "Ice"])
    ]
}
