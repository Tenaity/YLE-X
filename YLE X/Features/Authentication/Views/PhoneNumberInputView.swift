//
//  PhoneNumberInputView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct PhoneNumberInputView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var phoneNumber: String = ""
    @State private var countryCode: String = "+84"
    @State private var verificationID: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOTPInput = false
    @State private var showingCountryPicker = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Header
            VStack(spacing: AppSpacing.sm) {
                Text("Enter Phone Number")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appText)

                Text("We'll send you a verification code")
                    .appBodyMedium()
                    .foregroundColor(.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xl)

            // Phone input section
            VStack(spacing: AppSpacing.md) {
                // Country code and phone number input
                HStack(spacing: AppSpacing.md) {
                    // Country code button
                    Button(action: { showingCountryPicker = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Text(countryCode)
                                .appBodyMedium()
                                .foregroundColor(.appText)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.md)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(AppRadius.md)
                    }

                    // Phone number input
                    TextField("Phone number", text: $phoneNumber)
                        .appBodyMedium()
                        .keyboardType(.phonePad)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.md)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(AppRadius.md)
                        .onChange(of: phoneNumber) { newValue in
                            // Remove non-numeric characters
                            phoneNumber = newValue.filter { $0.isNumber || $0 == "-" || $0 == " " }
                        }
                }

                // Info badge
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.appInfo)
                        .font(.system(size: 16))

                    Text("Standard SMS rates may apply")
                        .appCaptionMedium()
                        .foregroundColor(.appTextSecondary)
                }
                .padding(AppSpacing.md)
                .background(Color.appInfo.opacity(0.1))
                .cornerRadius(AppRadius.md)
            }
            .padding(.horizontal, AppSpacing.lg)

            Spacer()

            // Continue button
            Button(action: sendVerificationCode) {
                HStack {
                    Text("Send Code")
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
            .disabled(isLoading || phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(isLoading || phoneNumber.isEmpty ? 0.7 : 1)
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
        .sheet(isPresented: $showingCountryPicker) {
            CountryCodePickerView(selectedCode: $countryCode)
        }
        .navigationDestination(isPresented: $showOTPInput) {
            OTPVerificationView(
                phoneNumber: countryCode + phoneNumber,
                verificationID: verificationID
            )
        }
    }

    private func sendVerificationCode() {
        guard !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a valid phone number"
            return
        }

        isLoading = true
        errorMessage = nil

        let fullPhoneNumber = countryCode + phoneNumber

        Task {
            do {
                let id = try await authViewModel.authService.sendPhoneVerificationCode(phoneNumber: fullPhoneNumber)
                verificationID = id
                showOTPInput = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Country Code Picker
struct CountryCodePickerView: View {
    @Binding var selectedCode: String
    @Environment(\.dismiss) var dismiss

    let countryCodes = [
        ("+1", "United States"),
        ("+44", "United Kingdom"),
        ("+81", "Japan"),
        ("+86", "China"),
        ("+84", "Vietnam"),
        ("+60", "Malaysia"),
        ("+66", "Thailand"),
        ("+62", "Indonesia"),
        ("+65", "Singapore"),
        ("+63", "Philippines"),
    ]

    var body: some View {
        NavigationView {
            List(countryCodes, id: \.0) { code, name in
                Button(action: {
                    selectedCode = code
                    dismiss()
                }) {
                    HStack {
                        Text(name)
                            .foregroundColor(.appText)

                        Spacer()

                        if selectedCode == code {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PhoneNumberInputView()
    }
}
