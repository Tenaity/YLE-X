//
//  App.swift
//  YLE X
//
//  Main App Entry Point
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}

@main
struct YLEXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate



    var body: some Scene {
        WindowGroup {
            MainAppFlow()
        }
    }
}
