//
//  FriendsViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI

class FriendsViewModel: ObservableObject {
    
    var model: FriendsModelProtocol
    
    init(model: FriendsModelProtocol = FriendsModel()) {
        self.model = model
    }
    
    @Published var friends: [MUser] = Utility.friends {
        didSet {
            Utility.friends = friends
        }
    }
    
    func refreshFriends() async {
        let newFriends = await model.refreshFriends()
        if !newFriends.isEmpty {
            await MainActor.run {
                friends = newFriends
            }
        }
    }
    // returns false if already a friend
    func addFriend(id: String) async throws -> Bool {
        guard !friends.contains(where: { $0.id == id }) else { return false }
        guard let user = await model.addFriend(id: id) else { return false }
        
        await MainActor.run {
            friends.append(user)
        }
        return true
    }
    
    func removeFriend(id: String) {
        friends = friends.filter { $0.id != id }
        Task {
            await model.removeFriend(id: id)
        }
    }
    
    func logout() {
        friends = []
    }
}
