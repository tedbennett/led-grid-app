//
//  ArtView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI

struct ArtView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @EnvironmentObject var artViewModel: ArtViewModel
    @ObservedObject var navigationManager = NavigationManager.shared
    
    var friends: [User] {
        friendsViewModel.friends.sorted {
            guard let art1 = artViewModel.art[$0.id]?.first else { return false }
            guard let art2 = artViewModel.art[$1.id]?.first else { return true }
            
            return art1.sentAt > art2.sentAt
        }
    }
    
    func hasUnreads(for friend: String) -> Bool {
        artViewModel.art[friend]?.first { !$0.opened } != nil
    }
    
    var body: some View {
        NavigationView {
            List(friends) { friend in
                Section {
                    Button {
                        navigationManager.setFriend(friend)
                    } label: {
                        FriendCardView(friend: friend, hasUnread: hasUnreads(for: friend.id)).padding(.vertical, 20)
                    }
                }
            }
            .refreshable {
                await artViewModel.refreshArt()
            }
            .toolbar {
                Button {
                    Helpers.presentShareSheet()
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            .navigationTitle("Friends")
            .navigationDestination(for: $navigationManager.selectedFriend) { friend in
                let art = artViewModel.art[friend.id] ?? []
                ArtListView(user: friend, art: art)
            }
        }
    }
}

struct ArtView_Previews: PreviewProvider {
    static var previews: some View {
        Utility.friends = [User.example]
        return ArtView()
            .environmentObject(FriendsViewModel())
            .environmentObject(ArtViewModel())
    }
}

