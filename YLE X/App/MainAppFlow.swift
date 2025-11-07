import SwiftUI
import FirebaseCore

struct MainAppFlow: View {
    @StateObject private var session = SessionViewModel()

    var body: some View {
        Group {
            if session.user != nil {
                TabBarView()
            } else {
                AuthFlowView()
            }
        }
        .environmentObject(session)
    }
}


