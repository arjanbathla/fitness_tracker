import SwiftUI

// create account form with terms checkbox
struct SignUpView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onLogin: () -> Void

    @State private var showTerms = false
    @FocusState private var focusedField: Field? // keyboard navigation
    private enum Field { case name, email, password }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 40)

                    Text("Sign up")
                        .font(.system(size: 40, weight: .bold))
                        .italic()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        TextField("Enter input here", text: $viewModel.signUpName)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        SecureField("Enter input here", text: $viewModel.signUpPassword)
                            .textFieldStyle(AuthTextFieldStyle())
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }

                    HStack(spacing: 10) {
                        Button {
                            viewModel.agreedToTerms.toggle()
                        } label: {
                            Image(systemName: viewModel.agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundStyle(viewModel.agreedToTerms ? .cyan : .gray)
                                .font(.title3)
                        }

                        Text("I agree to the ")
                            .foregroundStyle(.primary) +
                        Text("terms and conditions")
                            .foregroundColor(AppColors.primaryCTA)
                            .italic()
                    }
                    .font(.footnote)
                    .onTapGesture { showTerms = true } // opens the terms sheet
                    .sheet(isPresented: $showTerms) {
                        TermsAndConditionsView()
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: { viewModel.signUp() }) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Sign Up")
                                    .font(.title3).fontWeight(.bold).italic()
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canSignUp && !viewModel.isLoading ? AppColors.primaryCTA : AppColors.primaryCTA.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    .disabled(!viewModel.canSignUp || viewModel.isLoading)

                    HStack {
                        Spacer()
                        Text("Already have an account?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
    SignUpView(viewModel: LoginViewModel(), onLogin: {})
}
