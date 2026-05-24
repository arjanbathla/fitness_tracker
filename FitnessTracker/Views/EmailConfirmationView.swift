import SwiftUI

// shown after password reset email is sent
struct EmailConfirmationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: LoginViewModel
    var onReturnToLogin: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: onReturnToLogin) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    Text("Confirmation\nemail sent")
                        .font(.system(size: 30, weight: .bold))
                        .italic()
                        .foregroundStyle(.primary)
                }
                .padding(.top, 16)

                Spacer().frame(height: 48)

                Text("Check your email")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 12)

                Text("We have sent instructions to reset your password to the email provided")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                Spacer().frame(height: 40)

                Text("Didn't receive email?")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.primary)
                            .padding(.top, 6)
                        Text("Check your spam folders")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.primary)
                            .padding(.top, 6)
                        Button("Resend email") {
                            viewModel.resendEmail()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.cyan)
                    }
                }

                Spacer()

                Button(action: onReturnToLogin) {
                    Text("Return to login")
                        .font(.title3).fontWeight(.bold).italic()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColors.primaryCTA)
                        .clipShape(Capsule())
                }

                if viewModel.emailResent {
                    Button {} label: {
                        Text("email resent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.systemGray5))
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
    EmailConfirmationView(viewModel: LoginViewModel(), onReturnToLogin: {})
}
