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
    
    var body: some Scene {
        WindowGroup {
            ContentView(selection: $selection)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in }
        )
        application.registerForRemoteNotifications()
        
        if launchOptions?[.remoteNotification] != nil {
            // Set tab
        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let grid = parseGrid(from: userInfo) {
            Utility.receivedGrids.append(grid)
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print(notification.request.content.userInfo)
        if let grid = parseGrid(from: notification.request.content.userInfo) {
            Utility.receivedGrids.append(grid)
        }
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print(token)
        print("did register")
        NetworkManager.shared.postToken(token)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("failed to register")
        
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        print(userInfo)
        
        completionHandler()
    }
    
    func parseGrid(from hashable: [AnyHashable: Any]) -> ColorGrid? {
        guard let grid = hashable["grid"] as? [AnyHashable: Any],
              let colors = grid["grid"] as? [[[AnyHashable: Any]]],
              let id = grid["id"] as? String,
              let sentAt = grid["sentAt"] as? String,
              let date = try? Date(sentAt, strategy: .iso8601) else {
            return nil
        }
        if colors.count != 8 || !colors.allSatisfy( { $0.count == 8 }) { return nil }
        let colorGrid: [[Color]] = colors.map { row in row.map { col in
            print(col)
            guard let red = col["red"] as? Double, let green = col["green"] as? Double, let blue = col["blue"] as? Double else {
                return Color(red: 0, green: 0, blue: 0)
            }
            return Color(red: red, green: green, blue: blue) } }
        return ColorGrid(id: id, grid: colorGrid, sentAt: date, opened: false)
    }
}
