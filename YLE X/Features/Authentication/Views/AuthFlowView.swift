//
//  AuthFlowView.swift
//  YLE X
//
//  Intended path: Features/Authentication/Views/
//  Created by Tenaity on 6/11/25.
//

import SwiftUI

struct AuthFlowView: View {
    @StateObject private var vm = SignInViewModel()
    @State private var isShowingSignUp = false

    var body: some View {
        NavigationStack {
            VStack {
                SignInView(viewModel: vm, isShowingSignUp: $isShowingSignUp)
                NavigationLink("", isActive: $isShowingSignUp) {
                    SignUpView(viewModel: vm, isShowingSignUp: $isShowingSignUp)
                }
                .hidden()
            }
            .navigationTitle("Đăng nhập")
        }
    }
}

struct SignInView: View {
    @ObservedObject var viewModel: SignInViewModel
    @Binding var isShowingSignUp: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Chào mừng đến YLE X")
                .font(.largeTitle).bold()
                .foregroundColor(.green)

            Group {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Mật khẩu", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red).font(.caption)
            }

            Button {
                viewModel.signIn()
            } label: {
                HStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    Text("Đăng nhập")
                }
                .frame(maxWidth: .infinity).padding()
                .background(Color.green).foregroundColor(.white).cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)

            Button("Tạo tài khoản mới") {
                isShowingSignUp = true
                viewModel.errorMessage = nil
            }
            .padding(.top, 8)

            HStack {
                Button("Đăng nhập với Google") { viewModel.signInWithGoogle() }
                Button("Đăng nhập với Apple") { viewModel.signInWithApple() }
            }
            .font(.footnote)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.top, 50)
    }
}
