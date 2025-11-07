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
    @State private var selectedTab: SignInMethod = .social

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: AppSpacing.sm) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appText)

                Text("Choose your preferred sign-in method")
                    .appBodyMedium()
                    .foregroundColor(.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xl)

            // Tab Selector
            HStack(spacing: 0) {
                TabButton(
                    title: "Social",
                    isSelected: selectedTab == .social,
                    action: { selectedTab = .social }
                )

                TabButton(
                    title: "Phone",
                    isSelected: selectedTab == .phone,
                    action: { selectedTab = .phone }
                )
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)

            // Content
            if selectedTab == .social {
                socialSignInContent
            } else {
                phoneSignInContent
            }

            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .alert("Sign-In Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            if let error = errorMessage {
                Text(error)
            }
        })
    }

    // MARK: - Social Sign-In Content
    @ViewBuilder
    private var socialSignInContent: some View {
        VStack(spacing: AppSpacing.lg) {
            // Info message
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.appPrimary)
                    .font(.system(size: 16))

                Text("Sign in is coming soon for Google and Apple")
                    .appBodySmall()
                    .foregroundColor(.appTextSecondary)
            }
            .padding(AppSpacing.md)
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(AppRadius.md)
            .padding(.horizontal, AppSpacing.lg)

            VStack(spacing: AppSpacing.md) {
                // Google Button
                SignInMethodButton(
                    icon: "g.circle.fill",
                    title: "Google",
                    color: Color(red: 0.2, green: 0.5, blue: 0.95),
                    isLoading: isLoading,
                    action: {
                        Task {
                            await handleGoogleSignIn()
                        }
                    }
                )

                // Apple Button
                SignInMethodButton(
                    icon: "apple",
                    title: "Apple",
                    color: .black,
                    isLoading: isLoading,
                    action: {
                        AppleSignInHelper.randomNonceString()  // Placeholder
                    }
                )

                // Divider
                HStack(spacing: AppSpacing.md) {
                    VStack { Divider() }
                    Text("Or")
                        .appCaptionMedium()
                        .foregroundColor(.appTextSecondary)
                    VStack { Divider() }
                }
                .padding(.vertical, AppSpacing.md)

                // Existing Apple Button
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
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Phone Sign-In Content
    @ViewBuilder
    private var phoneSignInContent: some View {
        NavigationStack {
            PhoneNumberInputView()
        }
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
    private func handleAppleSignIn(_ result: Result<(ASAuthorizationAppleIDCredential, String), Error>) {
        switch result {
        case .success((let credential, let nonce)):
            Task {
                isLoading = true
                defer { isLoading = false }

                do {
                    try await authViewModel.signInWithApple(credential: credential, rawNonce: nonce)
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

// MARK: - Sign-In Method Enum
enum SignInMethod {
    case social
    case phone
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .appBodyMedium()
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)

                if isSelected {
                    Capsule()
                        .fill(Color.appPrimary)
                        .frame(height: 3)
                        .padding(.top, AppSpacing.sm)
                } else {
                    Color.clear
                        .frame(height: 3)
                        .padding(.top, AppSpacing.sm)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

// MARK: - Sign-In Method Button
struct SignInMethodButton: View {
    let icon: String
    let title: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text(title)
                    .appBodyMedium()
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(color)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }
}

#Preview {
    SocialSignInView()
}
