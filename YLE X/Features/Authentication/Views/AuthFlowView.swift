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


