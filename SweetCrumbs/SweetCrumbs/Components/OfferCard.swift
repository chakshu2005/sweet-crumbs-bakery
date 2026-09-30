import SwiftUI

struct OfferCard: View {
    let offer: Offer
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: offer.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(offer.emoji)
                    .font(.system(size: 80)).opacity(0.35)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title).font(.system(.title3, design: .rounded).weight(.heavy))
                    Text(offer.subtitle).font(.caption)
                    Text("Tap to use \(offer.code)")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.white.opacity(0.28), in: Capsule())
                        .padding(.top, 4)
                }
                .foregroundStyle(.white)
                .padding(16)
            }
            .frame(width: 220, height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: offer.colors.last?.opacity(0.35) ?? .clear, radius: 10, y: 6)
        }
        .buttonStyle(PressableStyle())
    }
}
