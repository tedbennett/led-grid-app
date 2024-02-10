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
    case drafts
    case draw
    case art
}

struct Home: View {
    @State private var selectedDraftId: String?
    @State private var isLoading = true

    func updateFromServer() {
        let since = UserDefaults.standard.data(forKey: "LAST_RECEIVED_DRAWINGS").flatMap {
            try? JSONDecoder().decode(Date.self, from: $0)
        }
        Task {
            let container = Container()
            // Fetch drawings
            let drawings = try await API.getReceivedDrawings(since: since)
            try await container.insertReceivedDrawings(drawings)

            // Fetch friends
            let friends = try await API.getFriends()
            try await container.insertFriends(friends)

            // Fetch user
            let user = try await API.getMe()
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: "USER")
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
                            DrawView(selectedDraftId: $selectedDraftId) {
                                scrollProxy.scrollTo(Tab.art)
                            }.safeAreaPadding()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                                .background(Color(uiColor: .secondarySystemBackground)).id(Tab.draw)
                            DrawingsView(selectedDraftId: $selectedDraftId) {
                                scrollProxy.scrollTo(Tab.draw)
                            }.safeAreaPadding()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                                .background(Color(uiColor: .secondarySystemBackground)).id(Tab.art)
                        }.scrollIndicators(.never)
                            .scrollTargetBehavior(.paging).toolbar(.hidden)
                            .scrollBounceBehavior(.basedOnSize)
                            .frame(maxHeight: .infinity)
                    }
                }.ignoresSafeArea()
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    Home()
        .environment(UserManager(user: APIUser.example))
}
