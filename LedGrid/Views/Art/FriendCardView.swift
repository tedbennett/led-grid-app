//
//  FriendCardView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI

struct FriendCardView: View {
    var friend: User
    var hasUnread: Bool
    var body: some View {
        HStack {
            UserOrb(user: friend)
                .frame(width: 60)
            Text(friend.fullName ?? "Unknown Friend")
                .font(.system(.title3, design: .rounded).weight(.medium))
            Spacer()
            if hasUnread {
                Circle()
                    .fill(Color(uiColor: .systemRed).opacity(0.7))
                    .frame(width: 15, height: 15)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }.padding(10)
    }
}

//struct FriendCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendCardView(friend: User.example, hasUnread: true)
//    }
//}
