import SwiftUI

/// Shows an asset image named "product_<id>" if it exists, otherwise emoji on a soft gradient.
struct ProductArt: View {
    let product: Product
    var emojiSize: CGFloat = 64

    var body: some View {
        ZStack {
            LinearGradient(colors: [product.tint.opacity(0.30), product.tint.opacity(0.85)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            if UIImage(named: product.imageName) != nil {   // tiny UIKit check so missing assets never break the UI
                Image(product.imageName).resizable().scaledToFill()
            } else {
                Text(product.emoji).font(.system(size: emojiSize))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 4)
            }
        }
        .clipped()
    }
}

struct HeartButton: View {
    let product: Product
    @EnvironmentObject var appState: AppState
    @State private var pop = false

    var body: some View {
        let liked = appState.isFavorite(product)
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
                appState.toggleFavorite(product)
                pop.toggle()
            }
        } label: {
            Image(systemName: liked ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundStyle(liked ? Theme.rose : Theme.chocolate)
                .padding(9)
                .background(.ultraThinMaterial, in: Circle())
                .scaleEffect(liked ? 1.15 : 1)
                .symbolEffect(.bounce, value: pop)
        }
        .buttonStyle(PressableStyle())
    }
}

struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cart: CartManager
    @State private var added = false

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: 8) {
                ProductArt(product: product)
                    .frame(height: 118)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(product.name)
                    .font(.system(.subheadline, design: .serif).weight(.bold))
                    .foregroundStyle(Theme.text).lineLimit(1)
                Text(product.blurb)
                    .font(.caption).foregroundStyle(Theme.subtext).lineLimit(1)
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").foregroundStyle(.orange)
                    Text(String(format: "%.1f", product.rating))
                }
                .font(.caption.weight(.semibold)).foregroundStyle(Theme.text)

                Text(product.price.rupees)
                    .font(.headline).foregroundStyle(Theme.rose)
                    .padding(.top, 2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Theme.chocolate.opacity(0.10), radius: 10, y: 5)
        }
        .buttonStyle(PressableStyle())
        // Favorite button (top-right of the image)
        .overlay(alignment: .topTrailing) { HeartButton(product: product).padding(18) }
        // Quick add-to-cart "+" (bottom-right of the card)
        .overlay(alignment: .bottomTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cart.add(product)
                    added = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(1.2))
                    withAnimation { added = false }
                }
            } label: {
                Image(systemName: added ? "checkmark" : "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(added ? Color.green : Theme.rose, in: Circle())
                    .shadow(color: Theme.rose.opacity(0.4), radius: 6, y: 3)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(PressableStyle())
            .padding(12)
        }
    }
}
