//
//  FriendsSettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct FriendsSettingsView: View {
    var friends: [User]
    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.fullName ?? "Unknown Friend")
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await PixeeProvider.removeFriend(friend.id)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash.fill")
                        }
                    }
                
                if friends.isEmpty {
                    Button {
                        Helpers.presentAddFriendShareSheet()
                    } label: {
                        Text("Add friends to get started!")
                    }
                }
            }
        }.navigationTitle("Friends")
            .toolbar {
                Button {
                    Helpers.presentAddFriendShareSheet()
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                }
            }
    }
}

//struct FriendsSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendsSettingsView()
//    }
//}
