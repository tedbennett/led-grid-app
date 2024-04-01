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


    var body: some View {
        List {
            NavigationLink("Find Friends") {
                FriendSearchView()
            }

            Section("Friends") {
                ForEach(friends) { friend in
                    VStack {
                        UserCard(name: friend.name, username: friend.username) {}
                    }
                }
            }

            Section("Sent Friend Requests") {
                ForEach(requests.filter { $0.sent && $0.status == .sent }) { request in
                    UserCard(name: request.name, username: request.username) {}
                }
            }
            Section("Received Friend Requests") {
                ForEach(requests.filter { !$0.sent && $0.status == .sent }) { request in
                    UserCard(name: request.name, username: request.username) {}
                }
            }
        }
        .toolbar {
            ShareLink(item: URL(string: "https://www.pixee-app.com")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

#Preview {
    FriendsView(user: APIUser.example)
        .modelContainer(Container.modelContainer)
}
