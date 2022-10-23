//
//  PixeeProvider.swift
//  LedGrid
//
//  Created by Ted Bennett on 16/10/2022.
//

import Foundation

struct PixeeProvider {
    static func fetchArt() async {
        do {
            let art = try await NetworkManager.shared.getGrids(after: Utility.lastReceivedFetchDate)
            try await CoreDataService.importArt(art)
            Utility.lastReceivedFetchDate = Date()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func sendArt(to users: [String], grids: [Grid]) async -> Bool {
        do {
            let art = try await NetworkManager.shared.sendGrid(
                to: users,
                grids: grids.map { $0.hex() }
            )
            try await CoreDataService.importArt([art])
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func sendReaction(for art: PixelArt, reaction: String) async -> Bool {
        do {
            let reaction = try await NetworkManager.shared.sendReaction(reaction, for: art.id, to: art.sender)
            try await CoreDataService.importReaction(reaction, artId: art.objectID)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func addFriend(_ id: String) async throws {
        do {
            guard Utility.friends.first(where: {$0.id == id }) == nil else { return }
            try await NetworkManager.shared.addFriend(id: id)
            let user = try await NetworkManager.shared.getUser(id: id)
            try await CoreDataService.importFriends([user])
            Utility.friends.append(user)
        } catch {
            print(error.localizedDescription)
            throw PixeeError.failedToAddFriend
        }
    }
    
    static func removeFriend(_ id: String) async {
        do {
            try await NetworkManager.shared.deleteFriend(id: id)
            try await CoreDataService.removeFriend(id: id)
            if let index = Utility.friends.firstIndex(where: { $0.id == id }) {
                Utility.friends.remove(at: index)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchFriends() async {
        do {
            let friends = try await NetworkManager.shared.getFriends()
            try await CoreDataService.importFriends(friends)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchReactions() async {
        do {
            let reactions = try await NetworkManager.shared.getReactions(after: Utility.lastReactionFetchDate)
            try await CoreDataService.importReactions(reactions)
            Utility.lastReactionFetchDate = Date()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchAllData() async throws {
        do {
            let friends = try await NetworkManager.shared.getFriends()
            let received = try await NetworkManager.shared.getGrids(after: nil)
            let sent = try await NetworkManager.shared.getSentGrids(after: nil)
            let reactions = try await NetworkManager.shared.getAllReactions()
            try await CoreDataService.importData(friends: friends, art: received + sent, reactions: reactions)
            Utility.lastReceivedFetchDate = Date()
            Utility.lastReactionFetchDate = Date()
        } catch {
            print(error.localizedDescription)
            throw PixeeError.failedToImportToCoreData
        }
    }
    
    static func removeAllArtAndUsers() async {
        await CoreDataService.clearPersistentData()
    }
}
