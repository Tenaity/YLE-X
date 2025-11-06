//
//  SignUpView.swift
//  YLE X
//
//  Intended path: Features/Authentication/Views/
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct SignUpView: View {
    // ViewModel sẽ được truyền vào từ View cha để tái sử dụng
    @ObservedObject var viewModel: SignInViewModel
    @Binding var isShowingSignUp: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tạo tài khoản mới")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("Bắt đầu hành trình tiếng Anh của bé ngay!")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // MARK: - Input Fields
            Group {
                TextField("Tên hiển thị (Tên bé)", text: $viewModel.displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Mật khẩu (ít nhất 6 ký tự)", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Xác nhận mật khẩu", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            // MARK: - Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // MARK: - Sign Up Button
            Button(action: viewModel.signUp) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Đăng ký & Bắt đầu")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            Spacer()
            
            // MARK: - Switch to Sign In
            Button("Quay lại Đăng nhập") {
                isShowingSignUp = false
                viewModel.errorMessage = nil // Xóa lỗi khi chuyển màn hình
            }
            .foregroundColor(.green)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
        }
        .padding(.top, 50)
    }
}
