//
//  SignInView.swift
//  YLE X
//
//  Intended path: Features/Authentication/Views/
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct SignInView: View {
    // Accept a shared ViewModel from parent
    @ObservedObject var viewModel: SignInViewModel
    @Binding var isShowingSignUp: Bool // Dùng để chuyển sang màn hình Đăng ký
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chào mừng trở lại!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Luyện thi Starters, Movers, Flyers cùng Gia Sư AI")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // MARK: - Email/Password Fields
            Group {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Mật khẩu", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading) // Vô hiệu hóa khi đang loading
            
            // MARK: - Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // MARK: - Sign In Button
            Button(action: viewModel.signIn) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Đăng nhập")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            Divider()
            
            // MARK: - Third-Party Sign In (Placeholder)
            Text("Hoặc đăng nhập bằng")
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                // Nút Google (Placeholder)
                AuthButton(title: "Google", color: .red) {
                    viewModel.signInWithGoogle()
                }
                
                // Nút Apple (Placeholder)
                AuthButton(title: "Apple", color: .black) {
                    viewModel.signInWithApple()
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Switch to Sign Up
            HStack {
                Text("Chưa có tài khoản?")
                Button("Đăng ký ngay") {
                    isShowingSignUp = true
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
        .padding(.top, 50)
    }
}

// MARK: - AuthButton Component
struct AuthButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(8)
        }
    }
}