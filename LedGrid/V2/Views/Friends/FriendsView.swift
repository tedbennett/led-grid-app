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
    @Query var receivedRequests: [FriendRequest] = []
    @Query var sentRequests: [FriendRequest] = []

    init(user: APIUser) {
        self.user = user
        let sent = FriendRequestStatus.sent.rawValue

        let sentFilter = #Predicate<FriendRequest> { request in
            request.sent && request._status == sent
        }
        let receivedFilter = #Predicate<FriendRequest> { request in
            !request.sent && request._status == sent
        }
        _sentRequests = Query(filter: sentFilter)
        _receivedRequests = Query(filter: receivedFilter)
    }

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
                ForEach(sentRequests) { request in
                    UserCard(name: request.name, username: request.username) {}
                }
            }
            Section("Received Friend Requests") {
                ForEach(receivedRequests) { request in
                    UserCard(name: request.name, username: request.username) {}
                }
            }
        }
    }
}

#Preview {
    FriendsView(user: APIUser.example)
        .modelContainer(Container.modelContainer)
}
