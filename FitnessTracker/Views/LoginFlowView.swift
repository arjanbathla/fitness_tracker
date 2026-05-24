import SwiftUI

// manages which auth screen is showing
struct LoginFlowView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            WelcomeView(
                onJoinNow: { viewModel.showSignUp = true },
                onLogin: { viewModel.showLogin = true }
            )
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $viewModel.showLogin) {
                LoginView(
                    viewModel: viewModel,
                    onForgotPassword: {
                        viewModel.showLogin = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // wait for dismiss animation
                            viewModel.showPasswordReset = true
                        }
                    },
                    onSignUp: {
                        viewModel.showLogin = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showSignUp = true
                        }
                    }
                )
            }
            .fullScreenCover(isPresented: $viewModel.showSignUp) {
                SignUpView(
                    viewModel: viewModel,
                    onLogin: {
                        viewModel.showSignUp = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showLogin = true
                        }
                    }
                )
            }
            .fullScreenCover(isPresented: $viewModel.showPasswordReset) {
                PasswordResetView(
                    viewModel: viewModel,
                    onSendReset: {
                        viewModel.sendReset()
                        viewModel.showPasswordReset = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showEmailConfirmation = true
                        }
                    },
                    onBackToLogin: {
                        viewModel.showPasswordReset = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showLogin = true
                        }
                    }
                )
            }
            .fullScreenCover(isPresented: $viewModel.showEmailConfirmation) {
                EmailConfirmationView(
                    viewModel: viewModel,
                    onReturnToLogin: {
                        viewModel.showEmailConfirmation = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showLogin = true
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    LoginFlowView(viewModel: LoginViewModel())
}
