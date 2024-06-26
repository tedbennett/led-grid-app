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
    @Environment(ToastManager.self) var toastManager

    func logout() {
        LocalStorage.clear()
        Keychain.clear(key: .apiKey)
        Task {
            let container = Container()
            do {
                try await container.clearDatabase()
                await MainActor.run {
                    isLoading = false
                    toastManager.toast = .logoutSuccess
                }
            } catch {
                logger.error("Error logging user out: \(error.localizedDescription)")
                toastManager.toast = .errorOccurred
            }
        }
    }

    func updateFromServer(fetchSent: Bool = false) {
        let since: Date? = LocalStorage.fetchDate
        Task {
            do {
                try await DataLayer().importData(since: since, fetchSent: fetchSent)
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
        @Bindable var toastManager = toastManager
        NavigationStack {
            if isLoading {
                Spinner()
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
                            .refreshable {
                                do {
                                    let since = LocalStorage.fetchDate
                                    try await DataLayer().importReceivedDrawings(since: since, opened: false)
                                    LocalStorage.fetchDate = .now
                                } catch {
                                    logger.error("\(error)")
                                }
                            }
                    }
                }.ignoresSafeArea()
            }
        }.ignoresSafeArea()
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.handleSignIn)) {
                _ in
                updateFromServer(fetchSent: true)
                toastManager.toast = .signInSuccess
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logout)) {
                _ in
                logout()
            }
            .tint(.primary)
            .toast($toastManager.toast)
    }
}

#Preview {
    Home().environment(ToastManager())
        .modelContainer(PreviewStore.container)
}
