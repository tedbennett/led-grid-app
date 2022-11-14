//
//  ArtView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI

struct ArtView: View {
    @ObservedObject var navigationManager = NavigationManager.shared
    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastUpdated, order: .reverse)]) var users: FetchedResults<User>
    func hasUnreads(for friend: User) -> Bool {
        friend.artArray.contains { !$0.opened }
    }
    
    var body: some View {
        NavigationView {
            List(users) { friend in
                Section {
                    Button {
                        navigationManager.setFriend(friend.id)
                    } label: {
                        FriendCardView(friend: friend, hasUnread: hasUnreads(for: friend)).padding(.vertical, 20)
                    }
                }
            }
            .refreshable {
                await PixeeProvider.fetchArt()
            }
            .toolbar {
                Button {
                    Helpers.presentAddFriendShareSheet()
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            .navigationTitle("Friends")
            .navigationDestination(for: $navigationManager.selectedFriend) { friendId in
                let friend = users.first(where: { $0.id == friendId })
                if let friend = friend {
                    ArtListView(user: friend)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct ArtView_Previews: PreviewProvider {
    static var previews: some View {
        ArtView()
            .environmentObject(FriendsViewModel())
            .environment(\.managedObjectContext, MockPersistenceController.shared.viewContext)
    }
}

