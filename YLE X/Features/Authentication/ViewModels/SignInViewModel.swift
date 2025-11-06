//
//  SignInViewModel.swift
//  YLE X
//  
//  Intended path: Features/Authentication/ViewModels/
//  Created by Tenaity on 6/11/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - SignInViewModel
// Quản lý logic và trạng thái của màn hình Đăng nhập/Đăng ký

final class SignInViewModel: ObservableObject {
    
    // Thuộc tính @Published để View lắng nghe và cập nhật
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var isLoading = false // Trạng thái loading khi gọi API
    @Published var errorMessage: String? // Thông báo lỗi cho người dùng
    
    // Tham chiếu đến Service để thực hiện các thao tác
    private let authService = AuthService()
    
    // MARK: - Đăng nhập
    @MainActor
    func signIn() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ Email và Mật khẩu."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Gọi hàm đăng nhập từ AuthService
                try await authService.signIn(email: email, password: password)
                // Đăng nhập thành công, trạng thái user sẽ được cập nhật ở MainAppFlow
            } catch {
                // Xử lý và hiển thị lỗi
                errorMessage = error.localizedDescription
                print("Lỗi Đăng nhập: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // MARK: - Đăng ký
    @MainActor
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ thông tin bắt buộc."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Mật khẩu xác nhận không khớp."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Gọi hàm đăng ký từ AuthService (bao gồm cả việc lưu user vào Firestore)
                try await authService.signUp(email: email, password: password, displayName: displayName)
                // Đăng ký thành công, user sẽ tự động đăng nhập và được chuyển hướng
            } catch {
                // Xử lý và hiển thị lỗi
                errorMessage = error.localizedDescription
                print("Lỗi Đăng ký: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // MARK: - Đăng nhập bằng Google và Apple
    // *LƯU Ý: Việc tích hợp Google/Apple cần thêm code cấu hình bên ngoài. 
    // Hiện tại, chúng ta sẽ để phần logic gọi này là placeholder*
    @MainActor
    func signInWithGoogle() {
        errorMessage = "Tính năng Google Sign-In đang được phát triển..."
        // Logic thực tế sẽ nằm ở đây
    }
    
    @MainActor
    func signInWithApple() {
        errorMessage = "Tính năng Apple Sign-In đang được phát triển..."
        // Logic thực tế sẽ nằm ở đây
    }
}

