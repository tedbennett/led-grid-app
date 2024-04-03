//
//  FriendsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import SwiftData
import SwiftUI

struct FriendsView: View {
    var user: APIUser
    @Query var friends: [Friend] = []
    @Query var requests: [FriendRequest] = []
    @State var showAllFriends = false
    @State var showAllSent = false
    @State var showAllReceived = false

    var sent: [FriendRequest] {
        requests.filter { $0.sent && $0.status == .sent }
    }

    var received: [FriendRequest] {
        requests.filter { !$0.sent && $0.status == .sent }
    }

    var body: some View {
        List {
            if !received.isEmpty {
                CardList(items: received, title: "Received Friend Requests")
            }

            NavigationLink("Find Friends") {
                FriendSearchView()
            }

            CardList(items: friends, title: "Friends")

            if !sent.isEmpty {
                CardList(items: sent, title: "Sent Friend Requests")
            }
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

struct CardList: View {
    var items: [any Card]
    var title: String
    @State private var showAll = false

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items.prefix(showAll ? Int.max : 5), id: \.id) { item in
                    UserCard(name: item.name, username: item.username) {}
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
