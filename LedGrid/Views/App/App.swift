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

    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
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
