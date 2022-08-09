//
//  LedGridApp.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI

@main
struct LedGridApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selection = 0
    @State private var loggedIn = false

    init() {
        UNUserNotificationCenter.current().delegate  = NotificationManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(Color(uiColor: .label))
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            NotificationManager.shared.selectedTab = 1
        }
        return true
    }
}

