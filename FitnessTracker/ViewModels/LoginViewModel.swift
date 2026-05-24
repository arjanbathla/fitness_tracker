import SwiftUI
import Combine
import FirebaseAuth

// which screen to show
enum AppState {
    case auth
    case onboarding
    case main
}

// controls all the authentication flow + navigation between screens
class LoginViewModel: ObservableObject {
    @Published var appState: AppState = .auth
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var checkingOnboarding = false
    @Published var errorMessage: String?

    @Published var loginEmail = ""
    @Published var loginPassword = ""

    @Published var signUpName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var agreedToTerms = false

    @Published var resetEmail = ""
    @Published var emailResent = false

    @Published var showLogin = false
    @Published var showSignUp = false
    @Published var showPasswordReset = false
    @Published var showEmailConfirmation = false
    @Published var needsOnboarding = false

    var authService: LoginService
    var firestoreService = FirestoreService()
    private var authStateHandle: AuthStateDidChangeListenerHandle? // firebase listener
    private var isNewSignUp = false

    init(authService: LoginService = LoginService()) {
        self.authService = authService
        listenForAuthChanges()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // form validation
    var canLogin: Bool {
        !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty && !loginPassword.isEmpty
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

    // firebase sign in
    func login() {
        guard canLogin else { return }
        errorMessage = nil
        isLoading = true

        authService.signIn(
            email: loginEmail.trimmingCharacters(in: .whitespaces),
            password: loginPassword
        ) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error
                }
            }
        }
    }

    func signUp() {
        guard canSignUp else { return }
        errorMessage = nil
        isLoading = true
        isNewSignUp = true

        authService.createAccount(
            email: signUpEmail.trimmingCharacters(in: .whitespaces),
            password: signUpPassword
        ) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error
                    self?.isNewSignUp = false
                }
                // auth state listener will handle the transition
            }
        }
    }

    func sendReset() {
        guard canSendReset else { return }
        errorMessage = nil
        isLoading = true

        authService.resetPassword(
            email: resetEmail.trimmingCharacters(in: .whitespaces)
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error
                }
            }
        }
    }

    //reuse reset password for resend
    func resendEmail() {
        isLoading = true
        authService.resetPassword(
            email: resetEmail.trimmingCharacters(in: .whitespaces)
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error
                } else {
                    self?.emailResent = true
                }
            }
        }
    }

    // reset dark mode on logout
    // reset everything on sign out
    func signOut() {
        if let error = authService.signOut() {
            errorMessage = error
        } else {
            UserDefaults.standard.set(true, forKey: "isDarkMode")
            NotificationService.shared.cancelAll()
        }
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        // delete firestore data first, then delete auth account
        firestoreService.deleteAllUserData(userId: uid) { [weak self] in
            user.delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        print("delete account failed: \(error.localizedDescription)")
                    } else {
                        print("account deleted")
                        UserDefaults.standard.set(true, forKey: "isDarkMode")
                        NotificationService.shared.cancelAll()
                        self?.appState = .auth
                    }
                }
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func finishOnboarding() {
        needsOnboarding = false
        isNewSignUp = false
        appState = .main
        dismissAllCovers()
    }

    // not sure if this is the right way to do it
    // not 100% sure this is the right way but it works
    private func listenForAuthChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoggedIn = user != nil

                if let user = user {
                    self.dismissAllCovers()

                    // always check firestore for a profile
                    self.checkingOnboarding = true
                    self.firestoreService.getUser(userId: user.uid) { existingUser in
                        DispatchQueue.main.async {
                            self.checkingOnboarding = false
                            if existingUser != nil && !self.isNewSignUp {
                                self.appState = .main
                            } else {
                                self.needsOnboarding = true
                                self.appState = .onboarding
                            }
                        }
                    }
                } else {
                    self.appState = .auth
                    self.clearFields()
                }
            }
        }
    }

    private func dismissAllCovers() {
        showLogin = false
        showSignUp = false
        showPasswordReset = false
        showEmailConfirmation = false
    }

    // wipe everything on logout
    // wipe everything when logging out
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
        showLogin = false
        showSignUp = false
        showPasswordReset = false
        showEmailConfirmation = false
        needsOnboarding = false
        isNewSignUp = false
    }
}
