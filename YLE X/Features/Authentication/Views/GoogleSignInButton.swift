//
//  GoogleSignInButton.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct GoogleSignInButton: View {
    let action: () async -> Void
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Button(action: {
            Task {
                isLoading = true
                do {
                    await action()
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)

                Text("Sign in with Google")
                    .appBodyMedium()
                    .foregroundColor(.white)

                if isLoading {
                    ProgressView()
                        .frame(width: 16, height: 16)
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .appCardPadding()
            .background(Color(red: 0.2, green: 0.5, blue: 0.95))
            .appCardRadius()
            .appShadow(level: .light)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            if let error = errorMessage {
                Text(error)
            }
        })
    }
}

#Preview {
    GoogleSignInButton(action: {})
        .padding(AppSpacing.lg)
}
