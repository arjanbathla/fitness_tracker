import SwiftUI

struct SplashView: View {
    var onJoinNow: () -> Void
    var onLogin: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("FITNESS\nTRACKER")
                    .font(.system(size: 48, weight: .bold))
                    .italic()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer()

                // Runner illustration placeholder
                Image(systemName: "figure.run")
                    .font(.system(size: 100))
                    .foregroundStyle(.pink)
                    .padding(.bottom, 40)

                Spacer()

                VStack(spacing: 12) {
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
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.white)
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
    SplashView(onJoinNow: {}, onLogin: {})
}
