import Foundation
import Firebase
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserId: String?
    @Published var currentUserName: String?
    @Published var isAnonymous = false
    @Published var error: String?
    @Published var isLoading = false
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.currentUserId = user?.uid
                self?.isAnonymous = user?.isAnonymous ?? false
                self?.currentUserName = user?.displayName
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        error = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = self?.getReadableError(error) ?? error.localizedDescription
                } else if let user = result?.user {
                    self?.isAuthenticated = true
                    self?.currentUserId = user.uid
                    self?.currentUserName = user.displayName
                    self?.isAnonymous = false
                }
            }
        }
    }
    
    func register(name: String, email: String, password: String) {
        isLoading = true
        error = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.error = self?.getReadableError(error) ?? error.localizedDescription
                }
                return
            }
            
            // Update display name
            if let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if let error = error {
                            self?.error = error.localizedDescription
                        } else {
                            self?.isAuthenticated = true
                            self?.currentUserId = user.uid
                            self?.currentUserName = name
                            self?.isAnonymous = false
                        }
                    }
                }
            }
        }
    }
    
    func signInAnonymously() {
        isLoading = true
        error = nil
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                } else if let user = result?.user {
                    self?.isAuthenticated = true
                    self?.currentUserId = user.uid
                    self?.isAnonymous = true
                    self?.currentUserName = "Guest"
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        isLoading = true
        error = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = self?.getReadableError(error) ?? error.localizedDescription
                } else {
                    self?.error = "Password reset email sent. Check your inbox."
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUserId = nil
                self.currentUserName = nil
                self.isAnonymous = false
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Helper Methods
    
    private func getReadableError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Please login instead."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please use at least 6 characters."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email. Please register first."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
}
