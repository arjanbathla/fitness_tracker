import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(white: 0.2))
            .clipShape(Capsule())
            .shadow(radius: 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            ToastView(message: "Workout added")
                .padding(.bottom, 30)
        }
    }
}
