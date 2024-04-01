//
//  App.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import AlertToast
import SwiftData
import SwiftUI

@main
struct AppV2: App {
    init() {
//        if Keychain.apiKey == nil,
//           let accessToken = ProcessInfo.processInfo.environment["ACCESS_TOKEN"]
//        {
//            Keychain.set(accessToken, for: .apiKey)
//        }
    }

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
    }
}
