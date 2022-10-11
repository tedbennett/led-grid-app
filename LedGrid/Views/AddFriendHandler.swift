//
//  AddFriendHandler.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/09/2022.
//

import SwiftUI
import AlertToast

struct AddFriendHandler: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @State private var addedFriend = false
    @State private var failedToAddFriend = false
    @State private var alreadyFriend = false
    
    func parseUrl(_ url: URL) {
        if url.scheme == "widget" && url.host == "received" {
            NavigationManager.shared.currentTab = 1
            return
        }
        guard url.pathComponents.count == 3,
              url.pathComponents[1] == "user" else {
            return
        }
        let id = url.pathComponents[2]
        guard id != Utility.user?.id else {
            failedToAddFriend.toggle()
            return
        }
        Task {
            do {
                let added = try await friendsViewModel.addFriend(id: id)
                await MainActor.run {
                    if added {
                        addedFriend.toggle()
                    } else {
                        alreadyFriend.toggle()
                    }
                }
            } catch {
                failedToAddFriend.toggle()
            }
        }
    }
    
    var body: some View {
        EmptyView()
            .onOpenURL { parseUrl($0) }
            .toast(isPresenting: $addedFriend) {
                AlertToast(type: .complete(.gray), title: "Added friend")
            }
            .toast(isPresenting: $alreadyFriend) {
                AlertToast(type: .error(.gray), title: "Already added friend")
            }
            .toast(isPresenting: $failedToAddFriend) {
                AlertToast(type: .error(.gray), title: "Failed to add friend")
            }
    }
}

struct AddFriendHandler_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendHandler()
    }
}
