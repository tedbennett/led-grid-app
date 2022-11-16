//
//  LedGridApp.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import WidgetKit
import Sentry
import Mixpanel

@main
struct LedGridApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var loggedIn: Bool

    init() {
        UNUserNotificationCenter.current().delegate  = NotificationManager.shared
        WidgetCenter.shared.reloadAllTimelines()
        StoreManager.shared.getProducts()
        
        AnalyticsManager.initialiseMixpanel()
        AnalyticsManager.initialiseSentry()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if AuthService.canRenew() && Utility.user?.id != nil {
            _loggedIn = State(initialValue: true)
            if hasNoData() {
                Task {
                    try? await PixeeProvider.fetchAllData()
                }
                
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            _loggedIn = State(initialValue: false)
        }
    }
    
    func hasNoData() -> Bool {
        let fetch = User.fetchRequest()
        return (try? PersistenceManager.shared.viewContext.count(for: fetch) == 0) ?? true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(loggedIn: $loggedIn).accentColor(Color(uiColor: .label))
                .environment(
                    \.managedObjectContext,
                    PersistenceManager.shared.container.viewContext
                )
        }
    }
}

