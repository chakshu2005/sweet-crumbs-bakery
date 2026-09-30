import SwiftUI

/// Text field used by Login and Sign Up (supports show/hide password + inline error).
struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var error: String? = nil
    @State private var reveal = false

    var body: some View {
        let capitalization: TextInputAutocapitalization = (isSecure || keyboard == .emailAddress) ? .never : .words
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(Theme.caramel).frame(width: 22)
                Group {
                    if isSecure && !reveal { SecureField(placeholder, text: $text) }
                    else { TextField(placeholder, text: $text) }
                }
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()

                if isSecure {
                    Button { reveal.toggle() } label: {
                        Image(systemName: reveal ? "eye.slash.fill" : "eye.fill").foregroundStyle(Theme.subtext)
                    }
                }
            }
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(error == nil ? Theme.pink.opacity(0.6) : Color.red.opacity(0.8), lineWidth: 1.2))

            if let error {
                Text(error).font(.caption).foregroundStyle(.red).padding(.leading, 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}
