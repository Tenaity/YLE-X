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
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
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

    // MARK: - Social Sign-In (Placeholder implementations)
    public func signInWithGoogle() async throws {
        throw AuthError.googleSignInNotImplemented
    }

    public func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        throw AuthError.appleSignInNotImplemented
    }
}

// MARK: - Custom Auth Errors
public enum AuthError: LocalizedError {
    case userCreationFailed
    case googleSignInNotImplemented
    case appleSignInNotImplemented
    
    public var errorDescription: String? {
        switch self {
        case .userCreationFailed:
            return "Failed to create user account"
        case .googleSignInNotImplemented:
            return "Google Sign-In integration is pending implementation"
        case .appleSignInNotImplemented:
            return "Apple Sign-In integration is pending implementation"
        }
    }
}
