import Foundation
import FirebaseAuth

enum AuthError: LocalizedError {
    case invalidEmail
    case wrongPassword
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            "Please enter a valid email address."
        case .wrongPassword:
            "Incorrect password. Please try again."
        case .emailAlreadyInUse:
            "An account with this email already exists."
        case .weakPassword:
            "Password must be at least 6 characters."
        case .userNotFound:
            "No account found with this email."
        case .networkError:
            "Network error. Please check your connection."
        case .unknown(let message):
            message
        }
    }

    init(from error: NSError) {
        let code = AuthErrorCode(rawValue: error.code)
        switch code {
        case .invalidEmail:
            self = .invalidEmail
        case .wrongPassword, .invalidCredential:
            self = .wrongPassword
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .weakPassword:
            self = .weakPassword
        case .userNotFound:
            self = .userNotFound
        case .networkError:
            self = .networkError
        default:
            self = .unknown(error.localizedDescription)
        }
    }
}

protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> String
    func createAccount(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    var currentUserID: String? { get }
}

struct FirebaseAuthService: AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw AuthError(from: error as NSError)
        }
    }

    func createAccount(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw AuthError(from: error as NSError)
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError(from: error as NSError)
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthError(from: error as NSError)
        }
    }

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
}
