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
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task {
            // Handle notification
            NotificationCenter.default.post(name: Notification.Name("REFRESH_ART"), object: nil)
            WidgetCenter.shared.reloadAllTimelines()
        }
        completionHandler([.banner, .badge, .sound])
    }
    
    // User opened notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let _ = notificationBody(from: response.notification.request.content.userInfo) {
            // pass
        }
        
        DispatchQueue.main.async {
            NavigationManager.shared.currentTab = 1
        }
        completionHandler()
    }
    
    func notificationBody(from payload: [AnyHashable : Any]) -> [String: Any]? {
        if let aps = payload["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let body = alert["body"] as? [String: Any] {
            return body
        }
        return nil
    }
}
