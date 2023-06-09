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
import FirebaseCore

struct LedGridApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel: LoginViewModel
    
    init() {
        UNUserNotificationCenter.current().delegate  = NotificationManager.shared
        WidgetCenter.shared.reloadAllTimelines()
        StoreManager.shared.getProducts()
        
//        AnalyticsManager.initialiseMixpanel()
        AnalyticsManager.initialiseSentry()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let systemFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        var font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 36)
        } else {
            font = systemFont
        }
        let strokeTextAttributes = [
            NSAttributedString.Key.font : font,
        ] as [NSAttributedString.Key : Any]
        
        UINavigationBar.appearance().largeTitleTextAttributes = strokeTextAttributes
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
        FirebaseApp.configure()
        if AuthService.isLoggedIn && Utility.user?.id != nil {
            _viewModel = StateObject(wrappedValue: LoginViewModel(loggedIn: true))
            if hasNoData() {
                Task {
                    try? await PixeeProvider.fetchAllData()
                }
                
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            _viewModel = StateObject(wrappedValue: LoginViewModel(loggedIn: false))
        }
    }
    
    func hasNoData() -> Bool {
        let fetch = User.fetchRequest()
        return (try? PersistenceManager.shared.viewContext.count(for: fetch) == 0) ?? true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .accentColor(Color(uiColor: .label))
                .environment(
                    \.managedObjectContext,
                    PersistenceManager.shared.container.viewContext
                )
        }
    }
}

