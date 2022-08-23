//
//  LedGridApp.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import WidgetKit

@main
struct LedGridApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selection = 0
    @State private var loggedIn = false

    init() {
        UNUserNotificationCenter.current().delegate  = NotificationManager.shared
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(Color(uiColor: .label))
        }
    }
}

