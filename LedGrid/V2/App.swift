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
    init() {
    }

    @UIApplicationDelegateAdaptor var appDelegate: MyAppDelegate
    @State private var showToast = false
    @State private var currentToast: Toast?
    @State private var presentSignIn = false

    var body: some Scene {
        WindowGroup {
            Home()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.toast)) { notif in
                    if let toast = notif.object as? Toast {
                        currentToast = toast
                        showToast.toggle()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.showSignIn)) {
                    _ in
                    presentSignIn.toggle()
                }
                .toast(isPresenting: $showToast, duration: 2, offsetY: 10) {
                    currentToast?.alert() ?? AlertToast(displayMode: .alert, type: .loading)
                }.fullScreenCover(isPresented: $presentSignIn) {
                    SignIn()
                }

        }.modelContainer(Container.modelContainer)
            .environment(\.toast, .constant(nil))
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

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in
                }
            )
        UIApplication.shared.registerForRemoteNotifications()
        return true
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
