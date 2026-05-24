import SwiftUI

// email and password login form
struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onForgotPassword: () -> Void
    var onSignUp: () -> Void

    @FocusState private var focusedField: Field?
    private enum Field { case email, password } // tab between fields

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 60)

                    Text("Login")
                        .font(.system(size: 40, weight: .bold))
                        .italic()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

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

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: { viewModel.login() }) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Login")
                                    .font(.title3).fontWeight(.bold).italic()
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canLogin && !viewModel.isLoading ? AppColors.primaryCTA : AppColors.primaryCTA.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    .disabled(!viewModel.canLogin || viewModel.isLoading)

                    HStack {
                        Spacer()
                        Text("Don't have an account?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
            .onChange(of: viewModel.loginEmail) { viewModel.clearError() } // clear error when they start typing again
            .onChange(of: viewModel.loginPassword) { viewModel.clearError() }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(), onForgotPassword: {}, onSignUp: {})
}
