//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftData
import SwiftUI
let logger = Logger(subsystem: "Pixee", category: "Canvas")

enum Tab: Hashable {
    case draw
    case art
}

struct Home: View {
    @State private var isLoading = true

    func logout() {
        LocalStorage.clear()
        Keychain.clear(key: .apiKey)
        Task {
            let container = Container()
            do {
                try await container.clearDatabase()
                await MainActor.run {
                    isLoading = false
                    Toast.logoutSuccess.present()
                }
            } catch {
                logger.error("Error logging user out: \(error.localizedDescription)")
                Toast.errorOccurred.present()
            }
        }
    }

    func updateFromServer() {
        let since: Date? = LocalStorage.fetchDate
        Task {
            let container = Container()
            do {
                // Fetch drawings
                let drawings = try await API.getReceivedDrawings(since: since)
                try await container.insertReceivedDrawings(drawings)

                // Fetch friends - may have changed names, etc.
                let friends = try await API.getFriends()
                // TODO: Ensure we're upserting here
                try await container.insertFriends(friends)

                // Fetch user
                let user = try await API.getMe()
                LocalStorage.user = user
                LocalStorage.fetchDate = Date.now
            } catch {
                LocalStorage.user = .none
                logger.error("Error retrieving initialization info: \(error.localizedDescription)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
                    .onAppear {
                        updateFromServer()
                    }
            } else {
                GeometryReader { proxy in
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            DrawView {
                                scrollProxy.scrollTo(Tab.art)
                            }.safeAreaPadding()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                                .id(Tab.draw)
                            DrawingsView {
                                scrollProxy.scrollTo(Tab.draw)
                            }.safeAreaPadding()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                                .id(Tab.art)
                        }.scrollIndicators(.never)
                            .scrollTargetBehavior(.paging).toolbar(.hidden)
                            .scrollBounceBehavior(.basedOnSize)
                            .frame(maxHeight: .infinity)
                    }
                }.ignoresSafeArea()
            }
        }.ignoresSafeArea()
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.handleSignIn)) {
                _ in
                isLoading = true
                updateFromServer()
                Toast.signInSuccess.present()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logout)) {
                _ in
                isLoading = true
                logout()
            }
            .tint(.white)
    }
}

#Preview {
    Home()
}
