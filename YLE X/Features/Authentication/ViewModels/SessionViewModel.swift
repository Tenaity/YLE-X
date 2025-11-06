//
//  SessionViewModel.swift
//  YLE X
//
//  Intended path: Features/Learning/ViewModels/
//  Purpose: Manages the authenticated user session state for the app.
//  Notes: Clean Architecture & MVVM — decoupled from concrete AuthService via protocol.
//

import Foundation
import Combine
import FirebaseAuth


// MARK: - SessionViewModel
/// ViewModel responsible for observing and exposing the authenticated user session.
/// - Architecture: MVVM
/// - Threading: MainActor — UI-bound published properties are updated on the main thread.
@MainActor
public final class SessionViewModel: ObservableObject {
    // MARK: - Published State
    /// The currently authenticated user. `nil` when signed out.
    @Published public private(set) var user: FirebaseUser?

    // MARK: - Dependencies
    private let authService: AuthServicing

    // MARK: - Internal State
    private var authHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Initialization
    /// Creates a new SessionViewModel.
    /// - Parameter authService: An object conforming to `AuthServicing`. Defaults to `AuthService()`.
    public init(authService: AuthServicing = AuthService()) {
        self.authService = authService
        startObservingAuthState()
    }

    deinit {
        if let handle = authHandle {
            authService.removeAuthStateListener(handle)
            authHandle = nil
        }
    }

    // MARK: - Public API
    /// Signs the current user out.
    public func signOut() {
        do {
            try authService.signOut()
        } catch {
            // In production, forward this to a logging/analytics system
            print("[SessionViewModel] Sign out error: \(error)")
        }
    }

    // MARK: - Private Helpers
    private func startObservingAuthState() {
        authHandle = authService.observeAuthState { [weak self] user in
            guard let self else { return }
            // Ensure state updates happen on the main actor
            Task { @MainActor in
                self.user = user
            }
        }
    }
}
