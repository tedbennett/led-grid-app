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
    @State private var loggedIn = false

    init() {
        UNUserNotificationCenter.current().delegate  = NotificationManager.shared
        WidgetCenter.shared.reloadAllTimelines()
        StoreManager.shared.getProducts()
        #if !DEBUG
        Mixpanel.initialize(token: "e2084c8238e48af2dc78abebd84c3f01", trackAutomaticEvents: true)
        SentrySDK.start { options in
            options.dsn = "https://e29612af279847dda6037ba43aa31e1a@o1421379.ingest.sentry.io/6769769"
            options.tracesSampleRate = 0.5
        }
        #endif
        
        if AuthService.canRenew() && Utility.user?.id != nil && hasNoData() {
            Task {
                try? await PixeeProvider.fetchAllData()
            }
        }
    }
    
    func hasNoData() -> Bool {
        let fetch = User.fetchRequest()
        return (try? PersistenceManager.shared.viewContext.count(for: fetch) == 0) ?? true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(Color(uiColor: .label))
                .environment(
                    \.managedObjectContext,
                    PersistenceManager.shared.container.viewContext
                )
        }
    }
}

