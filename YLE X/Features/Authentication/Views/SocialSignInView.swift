//
//  SocialSignInView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import AuthenticationServices

struct SocialSignInView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Divider with text
            HStack(spacing: AppSpacing.md) {
                VStack { Divider() }
                Text("Or continue with")
                    .appCaptionMedium()
                    .foregroundColor(.appTextSecondary)
                VStack { Divider() }
            }
            .padding(.vertical, AppSpacing.md)

            // Social sign-in buttons
            VStack(spacing: AppSpacing.md) {
                // Google Sign-In Button
                GoogleSignInButton {
                    await handleGoogleSignIn()
                }

                // Apple Sign-In Button
                AppleSignInButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                )
                .frame(height: 44)
            }
        }
        .alert("Sign-In Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            if let error = errorMessage {
                Text(error)
            }
        })
    }

    // MARK: - Google Sign-In Handler
    private func handleGoogleSignIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authViewModel.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Apple Sign-In Handler
    private func handleAppleSignIn(_ result: Result<ASAuthorizationAppleIDCredential, Error>) {
        isLoading = true
        defer { isLoading = false }

        switch result {
        case .success(let credential):
            Task {
                do {
                    try await authViewModel.signInWithApple(credential: credential)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        case .failure(let error):
            // User cancelled or error occurred
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SocialSignInView()
        .padding(AppSpacing.lg)
}
