//
//  App.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import AlertToast
import SwiftData
import SwiftUI
import UserNotifications

@main
struct AppV2: App {
    init() {}

    @UIApplicationDelegateAdaptor var appDelegate: MyAppDelegate
    @State private var showToast = false
    @State private var currentToast: Toast?
    @State private var presentSignIn = false
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            Home()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.showSignIn)) {
                    _ in
                    presentSignIn.toggle()
                }
                .fullScreenCover(isPresented: $presentSignIn) {
                    SignIn()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        let since = LocalStorage.fetchDate
                        Task {
                            try await DataLayer().importReceivedDrawings(since: since, opened: false)
                            LocalStorage.fetchDate = .now
                        }
                    }
                }

        }.modelContainer(Container.modelContainer)
            .environment(ToastManager())
    }
}

class MyAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
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
        print("Received notification")
        if let type = notification.request.content.userInfo["type"] as? NotificationType {
            switch type {
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

enum NotificationType: String {
    case requestSent = "FriendRequestSent"
    case requestAccepted = "FriendRequestAccepted"
    case drawing = "Drawing"
    case reaction = "Reaction"
}
