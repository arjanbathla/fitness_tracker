import Foundation
import Combine
import FirebaseAuth

// handles firebase authentication
class LoginService: ObservableObject {
    @Published var currentUserID: String?

    init() {
        currentUserID = Auth.auth().currentUser?.uid
    }

    func signIn(email: String, password: String, completion: @escaping (String?, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                self.currentUserID = result?.user.uid
                completion(result?.user.uid, nil)
            }
        }
    }

    func createAccount(email: String, password: String, completion: @escaping (String?, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                self.currentUserID = result?.user.uid
                completion(result?.user.uid, nil)
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }

    //returns non if it worked
    func signOut() -> String? {
        do {
            try Auth.auth().signOut()
            currentUserID = nil
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}
