//
//  FriendsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import AlertToast
import SwiftData
import SwiftUI

struct PresentToast: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: .init(get: { toast != nil }, set: { if $0 == false { toast = nil }}), offsetY: 20) {
                if let toast = toast {
                    return toast.alert()
                } else {
                    return AlertToast(displayMode: .hud, type: .loading)
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(PresentToast(toast: toast))
    }
}

struct FriendsView: View {
    var user: APIUser
    @Query var friends: [Friend] = []
    @Query var requests: [FriendRequest] = []
    @State var showAllFriends = false
    @State var showAllSent = false
    @State var showAllReceived = false
    @State var loadingRequest: String?
    @Environment(ToastManager.self) var toastManager

    var sent: [FriendRequest] {
        requests.filter { $0.sent && $0.status == .sent }
    }

    var received: [FriendRequest] {
        requests.filter { !$0.sent && $0.status == .sent }
    }

    func updateRequest(id: String, accept: Bool) {
        loadingRequest = id
        Task {
            do {
                try await API.updateFriendRequest(id, status: accept ? .accepted : .revoked)
                let dataLayer = DataLayer()
                try await dataLayer.refreshFriends()
                await MainActor.run {
                    loadingRequest = nil
                    toastManager.toast = accept ? .friendRequestAccepted : .friendRequestRejected
                }
            } catch {
                toastManager.toast = .errorOccurred
            }
        }
    }

    var body: some View {
        List {
            CardList(items: received, title: "Received Friend Requests") { id in
                HStack(spacing: 20) {
                    if id == loadingRequest {
                        ProgressView()
                    } else {
                        Menu {
                            Button {
                                updateRequest(id: id, accept: true)
                            } label: {
                                Label("Accept", systemImage: "checkmark")
                            }
                            Button {
                                updateRequest(id: id, accept: false)
                            } label: {
                                Label("Dismiss", systemImage: "xmark")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }.disabled(loadingRequest != nil)
                    }
                }
            }

            NavigationLink("Find Friends") {
                FriendSearchView()
            }

            CardList(items: friends, title: "Friends") { _ in }

            CardList(items: sent, title: "Sent Friend Requests") { _ in }
        }
        .toolbar {
            ShareLink(item: URL(string: "https://www.pixee-app.com")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FriendsView(user: APIUser.example)
        .modelContainer(Container.modelContainer)
}

protocol Card: Identifiable {
    var id: String { get set }
    var name: String? { get set }
    var username: String { get set }
}

extension Friend: Card {}
extension FriendRequest: Card {}

struct CardList<Content: View>: View {
    var items: [any Card]
    var title: String
    @State private var showAll = false
    @ViewBuilder var content: (String) -> Content

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items.prefix(showAll ? Int.max : 5), id: \.id) { item in
                    UserCard(name: item.name, username: item.username) { content(item.id) }
                }
            } header: {
                HStack {
                    Text(title)
                    Spacer()
                    if items.count > 5 {
                        Button {
                            withAnimation {
                                showAll.toggle()
                            }
                        } label: {
                            Text(showAll ? "See Less" : "See More")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}
