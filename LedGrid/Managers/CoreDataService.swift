//
//  CoreDataService.swift
//  LedGrid
//
//  Created by Ted Bennett on 16/10/2022.
//

import Foundation
import CoreData

struct CoreDataService {
    
    static private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = PersistenceManager.shared.container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    static func importData(
        friends mFriends: [MUser],
        art mArt: [MPixelArt],
        reactions mReactions: [MReaction]
    ) async throws {
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform {
            let friends: [String: User] = mFriends.map { friend in
                let user = User(context: backgroundContext)
                user.fullName = friend.fullName
                user.givenName = friend.givenName
                user.email = friend.email
                user.id = friend.id
                user.lastUpdated = nil
                return user
            }.reduce(into: [:]) { acc, val in
                acc[val.id] = val
            }
            let art = mArt.map {
                let userIds: [String] = $0.sender == Utility.user?.id ? $0.receivers : [$0.sender]
                let users = userIds.compactMap { friends[$0] }
                let art = PixelArt(from: $0, users: users, context: backgroundContext)
                art.opened = true
                for user in users {
                    if  user.lastUpdated == nil || art.sentAt > user.lastUpdated! {
                        user.lastUpdated = art.sentAt
                    }
                }
                return art
            }
                
            let artLookup = art.reduce(into: [:]) { acc, val in
                acc[val.id] = val
            }
            
            for mReaction in mReactions {
                let reaction = Reaction(context: backgroundContext)
                reaction.reaction = mReaction.reaction
                reaction.sender = mReaction.sender
                reaction.sentAt = mReaction.sentAt
                reaction.art = artLookup[mReaction.artId]
                reaction.id = mReaction.id
            }
            
            try backgroundContext.save()
        }
    }
    
    static func importArt(_ mArt: [MPixelArt]) async throws {
        let backgroundContext = newTaskContext()
        do {
            try await backgroundContext.perform {
                let friendsFetch = User.fetchRequest()
                let friends = (try backgroundContext.fetch(friendsFetch)).reduce(into: [:]) { acc, val in
                    acc[val.id] = val
                }
                
                for art in mArt {
                    let userIds: [String] = art.sender == Utility.user?.id ? art.receivers : [art.sender]
                    let users = userIds.compactMap { friends[$0] }
                    let art = PixelArt(from: art, users: users, context: backgroundContext)
                    for user in users {
                        if user.lastUpdated == nil || art.sentAt > user.lastUpdated! {
                            user.lastUpdated = art.sentAt
                        }
                    }
                }
                try backgroundContext.save()
            }
        } catch {
            throw PixeeError.failedToImportToCoreData
        }
    }
    
    static func importReaction(_ mReaction: MReaction, artId: NSManagedObjectID) async throws {
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform {
            
            let art: PixelArt = try backgroundContext.existingObject(with: artId) as! PixelArt
            
            let reaction = Reaction(context: backgroundContext)
            reaction.reaction = mReaction.reaction
            reaction.sender = mReaction.sender
            reaction.sentAt = mReaction.sentAt
            reaction.art = art
            reaction.id = mReaction.id
            try backgroundContext.save()
        }
    }
    
    static func importReactions(_ mReactions: [MReaction]) async throws {
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform {
            let ids = mReactions.map { $0.artId }
            
            let fetch = PixelArt.fetchRequest()
            fetch.predicate = NSPredicate(format: "id IN %@", ids)
            let artLookup = (try backgroundContext.fetch(fetch)).reduce(into: [:]) { acc, val in
                acc[val.id] = val
            }
            
            for mReaction in mReactions {
                let reaction = Reaction(context: backgroundContext)
                reaction.reaction = mReaction.reaction
                reaction.sender = mReaction.sender
                reaction.sentAt = mReaction.sentAt
                reaction.art = artLookup[mReaction.artId]
                reaction.id = mReaction.id
            }
            try backgroundContext.save()
        }
    }
    
    static func importFriends(_ mUsers: [MUser]) async throws {
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform {
            for friend in mUsers {
                let user = User(context: backgroundContext)
                user.fullName = friend.fullName
                user.givenName = friend.givenName
                user.email = friend.email
                user.id = friend.id
                user.lastUpdated = Date()
            }
            try backgroundContext.save()
        }
    }
    
    static func removeFriend(id: String) async throws {
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform {
            let friendsFetch = User.fetchRequest()
            friendsFetch.predicate = NSPredicate(format: "id = %@", id)
            let friends = try backgroundContext.fetch(friendsFetch)
            friends.forEach { backgroundContext.delete($0) }
            try backgroundContext.save()
        }
    }
    
    static func clearPersistentData() async {
        let backgroundContext = newTaskContext()
        
        do {
            try await backgroundContext.perform {
                let fetch: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
                // Deleting users should cascade and delete art too
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                _ = try backgroundContext.execute(deleteRequest)
                try backgroundContext.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

enum PixeeError: Error {
    case failedToImportToCoreData
    case failedToFetchFromCoreData
    case failedToFetchFromAPI
    case failedToAddFriend
}
