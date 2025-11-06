import SwiftUI
import FirebaseCore

struct MainAppFlow: View {
    @StateObject private var session = SessionViewModel.live()

    var body: some View {
        Group {
            if session.user != nil {
                HomeView()
            } else {
                AuthFlowView()
            }
        }
        .environmentObject(session)
    }
}

// HomeView is defined in Features/Home/Views/HomeView.swift
