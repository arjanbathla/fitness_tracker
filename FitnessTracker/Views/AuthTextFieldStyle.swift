import SwiftUI

// rounded text field for login/signup
struct AuthTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .foregroundStyle(.primary)
            .background(colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
