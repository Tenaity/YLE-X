import SwiftUI
import FirebaseCore

struct MainAppFlow: View {
    @StateObject private var session = SessionViewModel()
    @StateObject private var programStore = ProgramSelectionStore()

    var body: some View {
        Group {
            if session.user != nil {
                TabBarView()
            } else {
                AuthFlowView()
            }
        }
        .environmentObject(session)
        .environmentObject(programStore)
    }
}

