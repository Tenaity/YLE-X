//
//  OTPVerificationView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct OTPVerificationView: View {
    let phoneNumber: String
    let verificationID: String

    @StateObject private var authViewModel = AuthViewModel()
    @State private var otpCode: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var remainingSeconds: Int = 60
    @State private var canResend = false
    @State private var timer: Timer?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Header
            VStack(spacing: AppSpacing.sm) {
                Text("Enter Verification Code")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appText)

                Text("We've sent a code to \(phoneNumber)")
                    .appBodyMedium()
                    .foregroundColor(.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xl)

            // OTP Input
            VStack(spacing: AppSpacing.md) {
                // 6-digit code input
                HStack(spacing: AppSpacing.md) {
                    ForEach(0..<6, id: \.self) { index in
                        VStack(spacing: AppSpacing.sm) {
                            Text(index < otpCode.count ? String(Array(otpCode)[index]) : "")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appText)

                            Divider()
                                .frame(height: 1)
                                .background(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, AppSpacing.lg)

                // Invisible TextField for input
                TextField("", text: $otpCode)
                    .keyboardType(.numberPad)
                    .frame(height: 0)
                    .onChange(of: otpCode) { newValue in
                        // Keep only first 6 digits
                        let filtered = newValue.filter { $0.isNumber }
                        otpCode = String(filtered.prefix(6))

                        // Auto-submit when all 6 digits entered
                        if otpCode.count == 6 {
                            verifyOTP()
                        }
                    }

                // Resend button
                HStack(spacing: AppSpacing.md) {
                    Text("Didn't receive the code?")
                        .appCaptionMedium()
                        .foregroundColor(.appTextSecondary)

                    if canResend {
                        Button(action: resendCode) {
                            Text("Resend")
                                .appCaptionMedium()
                                .foregroundColor(.appPrimary)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text("Resend in \(remainingSeconds)s")
                            .appCaptionMedium()
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()
                }
                .padding(.top, AppSpacing.md)
            }
            .padding(.horizontal, AppSpacing.lg)

            Spacer()

            // Verify button
            Button(action: verifyOTP) {
                HStack {
                    Text("Verify")
                        .appBodyMedium()
                        .foregroundColor(.white)
                        .fontWeight(.semibold)

                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
                .background(Color.appPrimary)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(isLoading || otpCode.count != 6)
            .opacity(isLoading || otpCode.count != 6 ? 0.7 : 1)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)

            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.appError)

                    Text(errorMessage)
                        .appCaptionMedium()
                        .foregroundColor(.appError)

                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(Color.appError.opacity(0.1))
                .cornerRadius(AppRadius.md)
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))

                        Text("Back")
                            .appBodyMedium()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            startResendTimer()
            // Auto-focus on the invisible text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil)
            }
        }
        .onDisappear {
            stopResendTimer()
        }
    }

    private func verifyOTP() {
        guard otpCode.count == 6 else {
            errorMessage = "Please enter all 6 digits"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authViewModel.signInWithPhoneVerificationCode(
                    verificationCode: otpCode,
                    verificationID: verificationID
                )
                // Success - dismiss view
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func resendCode() {
        Task {
            if let id = await authViewModel.sendPhoneVerificationCode(phoneNumber: phoneNumber) {
                verificationID = id
                startResendTimer()
            }
        }
    }

    private func startResendTimer() {
        stopResendTimer()
        remainingSeconds = 60
        canResend = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                canResend = true
                stopResendTimer()
            }
        }
    }

    private func stopResendTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    NavigationView {
        OTPVerificationView(phoneNumber: "+84912345678", verificationID: "test_verification_id")
    }
}
