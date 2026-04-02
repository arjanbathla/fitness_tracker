import SwiftUI

struct SignUpView: View {
    @Bindable var viewModel: AuthViewModel
    var onLogin: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 40)

                    Text("Sign up")
                        .font(.system(size: 40, weight: .bold))
                        .italic()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)

                    // Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        TextField("Enter input here", text: $viewModel.signUpName)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        TextField("Enter input here", text: $viewModel.signUpEmail)
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

                        SecureField("Enter input here", text: $viewModel.signUpPassword)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }

                    // Terms checkbox
                    Button {
                        viewModel.agreedToTerms.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundStyle(viewModel.agreedToTerms ? .cyan : .gray)
                                .font(.title3)

                            Text("I agree to the ") +
                            Text("terms and conditions")
                                .foregroundColor(.cyan)
                                .italic()
                        }
                        .font(.footnote)
                        .foregroundStyle(.white)
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Sign Up button
                    Button(action: { viewModel.signUp() }) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Sign Up")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .italic()
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canSignUp && !viewModel.isLoading ? AppColors.primaryCTA : AppColors.primaryCTA.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    .disabled(!viewModel.canSignUp || viewModel.isLoading)

                    // Login link
                    HStack {
                        Spacer()
                        Text("Already have an account?")
                            .font(.footnote)
                            .foregroundStyle(.white)
                        Button("Login", action: onLogin)
                            .font(.footnote.bold())
                            .foregroundStyle(.cyan)
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { viewModel.clearError() }
            .onChange(of: viewModel.signUpEmail) { viewModel.clearError() }
            .onChange(of: viewModel.signUpPassword) { viewModel.clearError() }
        }
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel(), onLogin: {})
}
