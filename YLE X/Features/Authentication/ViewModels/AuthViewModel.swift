//
//  AuthViewModel.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import Combine

@MainActor
public class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthServicing
    private var authStateListener: AuthStateDidChangeListenerHandle?

    public init(authService: AuthServicing = AuthService()) {
        self.authService = authService
        self.currentUser = authService.currentUser
        self.isAuthenticated = currentUser != nil
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            authService.removeAuthStateListener(listener)
        }
    }

    // MARK: - Email/Password Authentication
    public func signIn(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signIn(email: email, password: password)
            await updateAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signUp(email: email, password: password, displayName: displayName)
            await updateAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func signOut() {
        isLoading = true
        defer { isLoading = false }

        do {
            try authService.signOut()
            updateAuthStateSync()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Social Sign-In
    public func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithGoogle()
            await updateAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithApple(credential: credential, rawNonce: rawNonce)
            await updateAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

        

    // MARK: - Private Methods
    private func setupAuthStateListener() {
        authStateListener = authService.observeAuthState { [weak self] user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }

    private func updateAuthStateSync() {
        currentUser = authService.currentUser
        isAuthenticated = currentUser != nil
    }

    private func updateAuthState() async {
        currentUser = authService.currentUser
        isAuthenticated = currentUser != nil
    }
}
