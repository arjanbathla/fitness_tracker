import SwiftUI

// first screen the user sees - logo and get started button
struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    var onJoinNow: () -> Void
    var onLogin: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("FITNESS\nTRACKER")
                    .font(.system(size: 48, weight: .bold))
                    .italic()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Spacer()

                // Runner illustration placeholder
                Image(systemName: "figure.run")
                    .font(.system(size: 100))
                    .foregroundStyle(.pink)
                    .padding(.bottom, 40)

                Spacer()

                VStack(spacing: 12) {
                    // yellow cta
                    Button(action: onJoinNow) {
                        Text("JOIN NOW")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppColors.primaryCTA)
                            .clipShape(Capsule())
                    }

                    Button(action: onLogin) {
                        Text("LOGIN")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(colorScheme == .dark ? Color.white : Color.black)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    WelcomeView(onJoinNow: {}, onLogin: {})
}
