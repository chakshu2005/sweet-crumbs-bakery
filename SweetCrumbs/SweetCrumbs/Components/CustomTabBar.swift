import SwiftUI

/// Floating pill-shaped tab bar with a sliding highlight and a cart badge.
struct CustomTabBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cart: CartManager
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let selected = appState.selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { appState.selectedTab = tab }
                } label: {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.icon)
                                .symbolVariant(selected ? .fill : .none)
                                .font(.system(size: 20, weight: .semibold))
                                .symbolEffect(.bounce, value: tab == .cart ? cart.count : 0)
                            if tab == .cart && cart.count > 0 {
                                Text("\(cart.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(Theme.rose, in: Capsule())
                                    .offset(x: 12, y: -8)
                                    .transition(.scale)
                            }
                        }
                        Text(tab.title).font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selected ? Theme.rose : Theme.subtext)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selected {
                            Capsule().fill(Theme.pink.opacity(0.35)).matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.14), radius: 14, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: cart.count)
    }
}
