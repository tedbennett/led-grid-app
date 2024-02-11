//
//  FriendCard.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/02/2024.
//

import SwiftUI

struct FriendCard: View {
    var friend: APIUser
    var added: Bool
    var addFriend: (String) -> Void
    var body: some View {
        UserCard(name: friend.name, username: friend.username) {
            if added {
                Image(systemName: "checkmark")
            } else {
                Button {
                    addFriend(friend.id)
                } label: {
                    Image(systemName: "person.badge.plus").padding(10)
                }
            }
        }
        .padding(15)
        .background(.bar)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    FriendCard(friend: APIUser(createdAt: .now, email: "", id: "", name: "This is my real name", plus: false, username: "Really long long username"), added: true) { _ in }.padding(20)
}
