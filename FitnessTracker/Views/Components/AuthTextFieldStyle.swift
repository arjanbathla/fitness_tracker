import SwiftUI

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(Color(white: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
