//
//  FriendsModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/10/2022.
//

import Foundation

protocol FriendsModelProtocol {
    func refreshFriends() async -> [User]
    func addFriend(id: String) async -> User?
    func removeFriend(id: String) async -> Bool
}

struct FriendsModel: FriendsModelProtocol {
    
    func refreshFriends() async -> [User] {
        do {
            let friends = try await NetworkManager.shared.getFriends()
            return friends
        } catch {
            print("Failed to fetch friends: \(error.localizedDescription)")
            return []
        }
    }
    
    func addFriend(id: String) async -> User? {
        do {
            _ = try await NetworkManager.shared.addFriend(id: id)
            let user = try await NetworkManager.shared.getUser(id: id)
            return user
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func removeFriend(id: String) async -> Bool {
        do {
            try await NetworkManager.shared.deleteFriend(id: id)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
