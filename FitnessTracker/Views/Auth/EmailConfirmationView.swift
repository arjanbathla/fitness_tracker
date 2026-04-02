import SwiftUI

struct EmailConfirmationView: View {
    @Bindable var viewModel: AuthViewModel
    var onReturnToLogin: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Back + title
                HStack(spacing: 12) {
                    Button(action: onReturnToLogin) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    Text("Confirmation\nemail sent")
                        .font(.system(size: 30, weight: .bold))
                        .italic()
                        .foregroundStyle(.white)
                }
                .padding(.top, 16)

                Spacer().frame(height: 48)

                // Check your email section
                Text("Check your email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 12)

                Text("We have sent instructions to reset your password to the email provided")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                Spacer().frame(height: 40)

                // Didn't receive section
                Text("Didn't receive email?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.white)
                            .padding(.top, 6)
                        Text("Check your spam folders")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.white)
                            .padding(.top, 6)
                        Button("Resend email") {
                            viewModel.resendConfirmationEmail()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.cyan)
                    }
                }

                Spacer()

                // Return to login button
                Button(action: onReturnToLogin) {
                    Text("Return to login")
                        .font(.title3)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColors.primaryCTA)
                        .clipShape(Capsule())
                }

                // Email resent indicator
                if viewModel.emailResent {
                    Button {} label: {
                        Text("email resent")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(white: 0.2))
                            .clipShape(Capsule())
                    }
                    .disabled(true)
                    .padding(.top, 10)
                }

                Spacer().frame(height: 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    EmailConfirmationView(
        viewModel: AuthViewModel(),
        onReturnToLogin: {}
    )
}
