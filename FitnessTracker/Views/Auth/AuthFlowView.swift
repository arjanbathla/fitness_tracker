import SwiftUI

struct AuthFlowView: View {
    @Bindable var viewModel: AuthViewModel

    @State private var path = NavigationPath()

    private enum AuthRoute: Hashable {
        case login
        case signUp
        case passwordReset
        case emailConfirmation
    }

    var body: some View {
        NavigationStack(path: $path) {
            SplashView(
                onJoinNow: { path.append(AuthRoute.signUp) },
                onLogin: { path.append(AuthRoute.login) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(
                        viewModel: viewModel,
                        onForgotPassword: { path.append(AuthRoute.passwordReset) },
                        onSignUp: {
                            path.removeLast(path.count)
                            path.append(AuthRoute.signUp)
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .signUp:
                    SignUpView(
                        viewModel: viewModel,
                        onLogin: {
                            path.removeLast(path.count)
                            path.append(AuthRoute.login)
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .passwordReset:
                    PasswordResetView(
                        viewModel: viewModel,
                        onSendReset: {
                            viewModel.sendPasswordReset()
                            path.append(AuthRoute.emailConfirmation)
                        },
                        onBackToLogin: {
                            path.removeLast()
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .emailConfirmation:
                    EmailConfirmationView(
                        viewModel: viewModel,
                        onReturnToLogin: {
                            path.removeLast(path.count)
                            path.append(AuthRoute.login)
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }
}

#Preview {
    AuthFlowView(viewModel: AuthViewModel())
}
