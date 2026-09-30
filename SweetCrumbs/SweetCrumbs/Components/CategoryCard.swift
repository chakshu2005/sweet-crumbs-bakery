import SwiftUI

struct CategoryCard: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.emoji)
                    .font(.title)
                    .frame(width: 62, height: 62)
                    .background(isSelected ? Theme.pink : Theme.card, in: Circle())
                    .overlay(Circle().stroke(isSelected ? Theme.rose : .clear, lineWidth: 2))
                    .shadow(color: Theme.chocolate.opacity(0.10), radius: 6, y: 3)
                Text(category.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? Theme.rose : Theme.text)
            }
            .scaleEffect(isSelected ? 1.06 : 1)
        }
        .buttonStyle(PressableStyle())
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}
