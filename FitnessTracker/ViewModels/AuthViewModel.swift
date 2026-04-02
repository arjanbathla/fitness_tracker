import SwiftUI
import FirebaseAuth

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var isLoading = false
    var errorMessage: String?

    // MARK: - Login
    var loginEmail = ""
    var loginPassword = ""

    // MARK: - Sign Up
    var signUpName = ""
    var signUpEmail = ""
    var signUpPassword = ""
    var agreedToTerms = false

    // MARK: - Password Reset
    var resetEmail = ""
    var emailResent = false

    private let authService: any AuthServiceProtocol
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init(authService: any AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
        listenForAuthChanges()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Validation

    var canLogin: Bool {
        !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty
        && !loginPassword.isEmpty
    }

    var canSignUp: Bool {
        !signUpName.trimmingCharacters(in: .whitespaces).isEmpty
        && !signUpEmail.trimmingCharacters(in: .whitespaces).isEmpty
        && !signUpPassword.isEmpty
        && agreedToTerms
    }

    var canSendReset: Bool {
        !resetEmail.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    func login() {
        guard canLogin else { return }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                _ = try await authService.signIn(
                    email: loginEmail.trimmingCharacters(in: .whitespaces),
                    password: loginPassword
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signUp() {
        guard canSignUp else { return }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                _ = try await authService.createAccount(
                    email: signUpEmail.trimmingCharacters(in: .whitespaces),
                    password: signUpPassword
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func sendPasswordReset() {
        guard canSendReset else { return }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                try await authService.sendPasswordReset(
                    email: resetEmail.trimmingCharacters(in: .whitespaces)
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func resendConfirmationEmail() {
        isLoading = true
        Task {
            do {
                try await authService.sendPasswordReset(
                    email: resetEmail.trimmingCharacters(in: .whitespaces)
                )
                emailResent = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private

    private func listenForAuthChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if user == nil {
                self?.clearFields()
            }
        }
    }

    private func clearFields() {
        loginEmail = ""
        loginPassword = ""
        signUpName = ""
        signUpEmail = ""
        signUpPassword = ""
        agreedToTerms = false
        resetEmail = ""
        emailResent = false
        errorMessage = nil
    }
}
