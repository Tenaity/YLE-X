//
//  AppleSignInButton.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void

    var body: some View {
        SignInWithAppleButton(
            onRequest: onRequest,
            onCompletion: onCompletion
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 44)
        .cornerRadius(AppRadius.md)
    }
}

// MARK: - Internal Apple Sign-In Button
struct SignInWithAppleButton: UIViewRepresentable {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProvider {
        let parent: SignInWithAppleButton

        init(_ parent: SignInWithAppleButton) {
            self.parent = parent
        }

        @objc func didTapButton() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            parent.onRequest(request)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization
        ) {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                parent.onCompletion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: nil)))
                return
            }

            parent.onCompletion(.success(appleIDCredential))
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithError error: Error
        ) {
            parent.onCompletion(.failure(error))
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                return ASPresentationAnchor()
            }
            return window
        }
    }
}

#Preview {
    AppleSignInButton(
        onRequest: { _ in },
        onCompletion: { _ in }
    )
    .frame(height: 44)
    .padding(AppSpacing.lg)
}
