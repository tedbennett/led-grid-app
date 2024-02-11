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
            request.status.rawValue == sent && request.sent
        }
        let receivedFilter = #Predicate<FriendRequest> { request in
            request.status.rawValue == sent && !request.sent
        }
        _sentRequests = Query(filter: sentFilter)
        _receivedRequests = Query(filter: receivedFilter)
    }

    var body: some View {
        List {
            Section("Friends") {
                ForEach(friends) { friend in
                    VStack {
                        if let name = friend.name {
                            Text(name)
                        }
                        Text("@\(friend.username)")
                            .font(.callout)
                            .tint(.gray)
                    }
                }
                NavigationLink("Find Friends") {
                    UserSearchView()
                }
            }
        }
    }
}

#Preview {
    FriendsView(user: APIUser.example)
}
