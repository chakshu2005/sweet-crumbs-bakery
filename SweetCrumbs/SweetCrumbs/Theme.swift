import SwiftUI

extension Color {
    /// Adaptive color: automatically switches between Light and Dark Mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
}

/// Central design system: every color used in the app lives here.
enum Theme {
    static let background = Color(light: Color(red: 1.0, green: 0.976, blue: 0.94),
                                  dark: Color(red: 0.10, green: 0.075, blue: 0.065))   // cream
    static let card = Color(light: .white, dark: Color(red: 0.17, green: 0.13, blue: 0.115))
    static let text = Color(light: Color(red: 0.33, green: 0.20, blue: 0.14),
                            dark: Color(red: 0.97, green: 0.92, blue: 0.86))            // chocolate
    static let subtext = Color(light: Color(red: 0.55, green: 0.42, blue: 0.36),
                               dark: Color(red: 0.75, green: 0.66, blue: 0.60))
    static let pink = Color(red: 0.98, green: 0.76, blue: 0.80)
    static let peach = Color(red: 1.0, green: 0.78, blue: 0.62)
    static let caramel = Color(red: 0.80, green: 0.53, blue: 0.27)
    static let chocolate = Color(red: 0.36, green: 0.22, blue: 0.16)
    static let rose = Color(red: 0.86, green: 0.40, blue: 0.47)
    static let brandGradient = LinearGradient(colors: [rose, caramel], startPoint: .topLeading, endPoint: .bottomTrailing)
}

// MARK: - Helpers

extension Double {
    /// 699 -> "₹699"
    var rupees: String { "₹\(Int(self.rounded()))" }
}

extension String {
    var isValidEmail: Bool {
        let s = trimmingCharacters(in: .whitespaces)
        let parts = s.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".") && !s.contains(" ") && !s.hasSuffix(".")
    }
}

// MARK: - Styles

/// Gentle "squish" when a button is pressed.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Big rounded gradient label. Used inside Buttons and NavigationLinks.
struct PrimaryLabel: View {
    let title: String
    var icon: String? = nil
    var body: some View {
        HStack(spacing: 8) {
            if let icon { Image(systemName: icon) }
            Text(title)
        }
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.rose.opacity(0.35), radius: 10, y: 5)
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) { PrimaryLabel(title: title, icon: icon) }
            .buttonStyle(PressableStyle())
    }
}

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Theme.chocolate.opacity(0.10), radius: 12, y: 6)
    }
}

/// Small pop-up message at the top of the screen.
struct ToastModifier: ViewModifier {
    @Binding var message: String?
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let text = message {
                    Text(text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(Theme.chocolate, in: Capsule())
                        .shadow(radius: 8, y: 4)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .task(id: text) {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation { self.message = nil }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: message)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View { modifier(CardStyle(padding: padding)) }
    func toast(_ message: Binding<String?>) -> some View { modifier(ToastModifier(message: message)) }
    /// Shows the floating custom tab bar (applied only to each tab's root screen).
    func withTabBar() -> some View { safeAreaInset(edge: .bottom) { CustomTabBar() } }
    /// Lets any screen push a ProductDetailView with NavigationLink(value:).
    func productDestination() -> some View {
        navigationDestination(for: Product.self) { ProductDetailView(product: $0) }
    }
}
