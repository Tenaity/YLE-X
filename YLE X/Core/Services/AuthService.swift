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
import GoogleSignIn
import CryptoKit
import Security

// MARK: - Type Aliases
public typealias FirebaseUser = User

// MARK: - AuthServicing Protocol
public protocol AuthServicing {
    var currentUser: FirebaseUser? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, displayName: String) async throws
    func signOut() throws
    func observeAuthState(_ onChange: @escaping (FirebaseUser?) -> Void) -> AuthStateDidChangeListenerHandle
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
    func signInWithGoogle() async throws
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws
}

// MARK: - AuthService Implementation
public struct AuthService: AuthServicing {
    public init() {}

    // MARK: - Auth State
    public var currentUser: FirebaseUser? {
        Auth.auth().currentUser
    }

    // MARK: - Email/Password Authentication
    public func signIn(email: String, password: String) async throws {
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

    public func signUp(email: String, password: String, displayName: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = result?.user else {
                    continuation.resume(throwing: AuthError.userCreationFailed)
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

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Auth State Observation
    public func observeAuthState(_ onChange: @escaping (FirebaseUser?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            onChange(user)
        }
    }

    public func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    // MARK: - Google Sign-In
    public func signInWithGoogle() async throws {
        // Get the root view controller for presenting sign-in flow
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.viewControllerNotFound
        }

        // Perform Google Sign-In
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )

        // Get ID token and access token
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.googleTokenNotFound
        }

        let accessToken = result.user.accessToken.tokenString

        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )

        // Sign in with Firebase
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // MARK: - Apple Sign-In
    public func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async throws {
        // Get identity token
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthError.appleTokenNotFound
        }

        // Create Firebase credential with identity token and nonce
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: identityToken,
            rawNonce: rawNonce
        )

        // Sign in with Firebase
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        let user = result.user

        // Update user profile with Apple-provided information if available
        if (user.displayName?.isEmpty ?? true) || (user.email?.isEmpty ?? true) {
            let changeRequest = user.createProfileChangeRequest()

            if let fullName = credential.fullName {
                changeRequest.displayName = formatAppleDisplayName(fullName)
            }

            // Note: Apple only provides email on first sign-in
            if let email = credential.email {
                changeRequest.email = email
            }

            try await changeRequest.commitChanges()
        }
    }

    // MARK: - Helper Methods
    private func formatAppleDisplayName(_ fullName: PersonNameComponents) -> String {
        var components: [String] = []
        if let givenName = fullName.givenName {
            components.append(givenName)
        }
        if let familyName = fullName.familyName {
            components.append(familyName)
        }
        return components.joined(separator: " ")
    }
}

// MARK: - Custom Auth Errors
public enum AuthError: LocalizedError {
    case userCreationFailed
    case viewControllerNotFound
    case googleSignInCancelled
    case googleTokenNotFound
    case appleTokenNotFound
    case firebaseSignInFailed(String)

    public var errorDescription: String? {
        switch self {
        case .userCreationFailed:
            return "Failed to create user account"
        case .viewControllerNotFound:
            return "Unable to find view controller for sign-in"
        case .googleSignInCancelled:
            return "Google Sign-In was cancelled"
        case .googleTokenNotFound:
            return "Failed to retrieve Google ID token"
        case .appleTokenNotFound:
            return "Failed to retrieve Apple identity token"
        case .firebaseSignInFailed(let message):
            return "Firebase sign-in failed: \(message)"
        }
    }
}
