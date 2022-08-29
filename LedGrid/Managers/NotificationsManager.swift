//
//  NotificationsManager.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation
import UserNotifications
import WidgetKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static var shared = NotificationManager()
    
    private override init() { super.init() }
    
    @Published var selectedTab = 0
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task {
            await GridManager.shared.handleReceivedNotification()
            WidgetCenter.shared.reloadAllTimelines()
        }
        completionHandler([[.banner, .badge, .sound]])
    }
    
    // User opened notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await GridManager.shared.handleReceivedNotification()
        await MainActor.run {
            self.selectedTab = 1
        }
    }
}
