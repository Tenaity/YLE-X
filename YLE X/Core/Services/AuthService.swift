//
//  AuthService.swift
//  YLE X
//
//  Intended path: Core/Services/
//  Created by Tenaity on 6/11/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

struct AuthService {
    // MARK: - Email/Password
    func signIn(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                    return
                }
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { commitError in
                    if let commitError {
                        continuation.resume(throwing: commitError)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Placeholders for social sign-in (to be implemented later)
    func signInWithGoogle() async throws {
        throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In integration pending."])
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        throw NSError(domain: "Auth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Apple Sign-In integration pending."])
    }

    // MARK: - Auth State
    var currentUser: User? { Auth.auth().currentUser }

    func observeAuthState(_ onChange: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in onChange(user) }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
