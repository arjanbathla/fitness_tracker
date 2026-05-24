import SwiftUI

// forgot password screen - enter email to get reset link
struct PasswordResetView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onSendReset: () -> Void
    var onBackToLogin: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 12) {
                    Button(action: onBackToLogin) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    Text("Password Reset")
                        .font(.system(size: 30, weight: .bold))
                        .italic()
                        .foregroundStyle(.primary)
                }
                .padding(.top, 16)

                Text("Enter your email address and we'll send you a link to reset your password")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    TextField("Enter input here", text: $viewModel.resetEmail)
                        .textFieldStyle(AuthTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.go)
                        .onSubmit {
                            if viewModel.canSendReset { onSendReset() }
                        }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Spacer()

                Button(action: onSendReset) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Text("Send Reset Link")
                                .font(.title3).fontWeight(.bold).italic()
                        }
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(viewModel.canSendReset && !viewModel.isLoading ? AppColors.primaryCTA : AppColors.primaryCTA.opacity(0.4))
                    .clipShape(Capsule())
                }
                .disabled(!viewModel.canSendReset || viewModel.isLoading)

                HStack {
                    Spacer()
                    Text("Remember your password?")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Login", action: onBackToLogin)
                        .font(.footnote.bold())
                        .foregroundStyle(.cyan)
                    Spacer()
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    PasswordResetView(viewModel: LoginViewModel(), onSendReset: {}, onBackToLogin: {})
}
