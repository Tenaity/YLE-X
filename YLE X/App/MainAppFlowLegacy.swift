//
//  MainAppFlowLegacy.swift
//  YLE X
//
//  Intended path: App/
//  Created by Tenaity on 6/11/25.
//

import SwiftUI
import FirebaseAuth

// MARK: - MainAppFlow
// View này lắng nghe trạng thái đăng nhập của Firebase
struct MainAppFlowLegacy: View {
    // @State để lưu trạng thái đăng nhập (true/false)
    @State private var isLoggedIn: Bool = false
    // @State để quản lý việc chuyển đổi giữa Đăng nhập và Đăng ký
    @State private var isShowingSignUp: Bool = false
    // @StateObject để tạo và chia sẻ viewModel giữa SignInView và SignUpView
    @StateObject private var authViewModel = SignInViewModel()
    
    var body: some View {
        Group {
            if isLoggedIn {
                // Nếu đã đăng nhập, hiển thị màn hình Home
                // Lưu ý: HomeView chưa được tạo, chúng ta sẽ tạo nó sau
                Text("Home Screen Placeholder: Đã Đăng Nhập") 
            } else {
                // Nếu chưa đăng nhập, hiển thị luồng Auth
                ZStack {
                    if isShowingSignUp {
                        SignUpView(viewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
                    } else {
                        SignInView(viewModel: authViewModel, isShowingSignUp: $isShowingSignUp)
                    }
                }
                .transition(.opacity)
            }
        }
        // Lắng nghe trạng thái đăng nhập Firebase
        .onAppear {
            setupAuthStateListener()
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        // Thiết lập bộ lắng nghe trạng thái đăng nhập Firebase
        // Đây là cách duy nhất để biết liệu người dùng có thực sự đăng nhập hay không
        Auth.auth().addStateDidChangeListener { auth, user in
            // Cập nhật biến @State isLoggedIn
            withAnimation(.easeInOut) {
                self.isLoggedIn = user != nil
            }
            
            if user != nil {
                print("Trạng thái Auth: Đã Đăng nhập với UID: \(user!.uid)")
                // Nếu đăng nhập, đảm bảo trạng thái đăng ký được reset
                self.isShowingSignUp = false 
            } else {
                print("Trạng thái Auth: Chưa Đăng nhập")
            }
        }
    }
}

