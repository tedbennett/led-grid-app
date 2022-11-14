//
//  NotificationsManager.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation
import UserNotifications
import WidgetKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static var shared = NotificationManager()
    
    private override init() { super.init() }
    
    func requestPermission() async {
        do {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
             
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
    
    // User opened notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let payload = response.notification.request.content.userInfo["payload"] as? [String: Any] {
            handleNotification(payload: payload)
        }
        
        completionHandler()
    }
    
    
    func handleNotification(payload: [String: Any]) {
        guard let type = payload["type"] as? String,
              let notification = PixeeNotification(rawValue: type) else {
            return
        }
        
        guard notification != .friend,
              let artId = payload["art_id"] as? String,
              let sender = payload["sender"] as? String else {
            return
        }
        
        switch notification {
        case .art:
            Task {
                await PixeeProvider.fetchArt()
                WidgetCenter.shared.reloadAllTimelines()
                NavigationManager.shared.navigateTo(friend: sender, grid: artId)
            }
        case .reaction:
            Task {
                await PixeeProvider.fetchReactions()
                NavigationManager.shared.navigateTo(friend: sender, grid: artId)
            }
        case .friend: break
        }
    }
}

enum PixeeNotification: String {
    case art = "art"
    case reaction = "reaction"
    case friend = "friend"
}
