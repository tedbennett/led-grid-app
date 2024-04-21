//
//  Delegate.swift
//  LedGrid
//
//  Created by Ted Bennett on 21/04/2024.
//

import UIKit
import UserNotifications

enum NotificationType: String, Codable {
    case requestSent = "FriendRequestSent"
    case requestAccepted = "FriendRequestAccepted"
    case drawing = "Drawing"
    case reaction = "Reaction"
}

struct Payload: Codable {
    var type: NotificationType
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("Remote server url: \(API.url.absoluteString)")

        if let accessToken = ProcessInfo.processInfo.environment["ACCESS_TOKEN"] {
            logger.info("Loaded access token from environment")
            Keychain.set(accessToken, for: .apiKey)
        }

        UNUserNotificationCenter.current().delegate = self

        if Keychain.apiKey != nil {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: authOptions,
                    completionHandler: { _, _ in
                    }
                )
            UIApplication.shared.registerForRemoteNotifications()
        }
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if let string = notification.request.content.userInfo["payload"] as? String,
           let data = string.data(using: .utf8),
           let payload = try? JSONDecoder().decode(Payload.self, from: data)
        {
            switch payload.type {
            case .drawing:
                let since = LocalStorage.fetchDate
                Task {
                    try await DataLayer().importReceivedDrawings(since: since, opened: false)
                    LocalStorage.fetchDate = .now
                }
            default: break
            }
        }
        completionHandler([.banner, .sound, .badge])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Task {
            do {
                #if DEBUG
                let sandbox = true
                #else
                let sandbox = false
                #endif
                try await API.createDevice(deviceId: token, sandbox: sandbox)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
