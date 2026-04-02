import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    var onForgotPassword: () -> Void
    var onSignUp: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 60)

                    Text("Login")
                        .font(.system(size: 40, weight: .bold))
                        .italic()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        TextField("Enter input here", text: $viewModel.loginEmail)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        SecureField("Enter input here", text: $viewModel.loginPassword)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { if viewModel.canLogin { viewModel.login() } }

                        HStack {
                            Spacer()
                            Button("Forgot password?", action: onForgotPassword)
                                .font(.footnote)
                                .foregroundStyle(.cyan)
                        }
                    }

                    Spacer().frame(height: 20)

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Login button
                    Button(action: { viewModel.login() }) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Login")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .italic()
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canLogin && !viewModel.isLoading ? AppColors.primaryCTA : AppColors.primaryCTA.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    .disabled(!viewModel.canLogin || viewModel.isLoading)

                    // Sign up link
                    HStack {
                        Spacer()
                        Text("Don't have an account?")
                            .font(.footnote)
                            .foregroundStyle(.white)
                        Button("Sign Up", action: onSignUp)
                            .font(.footnote.bold())
                            .foregroundStyle(.cyan)
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { viewModel.clearError() }
            .onChange(of: viewModel.loginEmail) { viewModel.clearError() }
            .onChange(of: viewModel.loginPassword) { viewModel.clearError() }
        }
    }
}

#Preview {
    LoginView(
        viewModel: AuthViewModel(),
        onForgotPassword: {},
        onSignUp: {}
    )
}
