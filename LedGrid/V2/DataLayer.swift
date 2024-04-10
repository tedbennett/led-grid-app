//
//  DataLayer.swift
//  LedGrid
//
//  Created by Ted Bennett on 04/02/2024.
//

import Foundation
import SwiftData

struct DataLayer {
    var container: Container

    init(container: Container) {
        self.container = container
    }

    init() {
        self.container = Container()
    }

    func importFriends() async throws {
        async let friends = API.getFriends()
        try await container.insertFriends(friends)
    }

    func importSentRequests() async throws {
        async let sent = API.getSentFriendRequests()
        try await container.insertFriendRequests(sent, sent: true)
    }

    func importReceivedRequests() async throws {
        async let received = API.getReceivedFriendRequests()
        try await container.insertFriendRequests(received, sent: false)
    }

    func importReceivedDrawings(since: Date?) async throws {
        async let drawings = API.getReceivedDrawings(since: since)
        try await container.insertReceivedDrawings(drawings)
    }

    func importSentDrawings(since: Date?) async throws {
        async let drawings = API.getSentDrawings(since: since)
        try await container.insertSentDrawings(drawings)
    }

    func importUser() async throws {
        let user = try await API.getMe()
        LocalStorage.user = user
    }

    func importData(since: Date?, fetchSent: Bool) async throws {
        try await importFriends()
        if fetchSent {
            _ = try await (importSentRequests(), importReceivedRequests(), importFriends(), importReceivedDrawings(since: since), importSentDrawings(since: since), importUser())
        } else {
            _ = try await (importSentRequests(), importReceivedRequests(), importFriends(), importReceivedDrawings(since: since), importUser())
        }
    }

    func refreshFriends() async throws {
        _ = try await (importSentRequests(), importReceivedRequests(), importFriends())
    }

    func sendDrawing(_ grid: Grid, to friends: [String]) async throws {
        let now = Date.now
        try await API.sendDrawing(grid, to: friends)
        let drawings = try await API.getSentDrawings(since: now)
        try await container.insertSentDrawings(drawings)
        _ = try await container.createDraft()
    }

    func sendFriendRequest(to userId: String) async throws {
        try await API.sendFriendRequest(to: userId)
        let requests = try await API.getSentFriendRequests()
        try await container.insertFriendRequests(requests, sent: true)
    }

    func clearDatabase() async throws {
        try await container.clearDatabase()
    }
}

// TODO: Better name
actor Container: ModelActor {
    nonisolated let modelContainer: ModelContainer
    nonisolated let modelExecutor: ModelExecutor

    static let modelContainer: ModelContainer = try! ModelContainer(for:
        SentDrawing.self,
        ReceivedDrawing.self,
        DraftDrawing.self,
        Friend.self,
        FriendRequest.self)

    let context: ModelContext

    init(container: ModelContainer = Container.modelContainer) {
        self.modelContainer = container
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.context = context
    }

    func createDraft() async throws -> String {
        let draft = DraftDrawing()
        context.insert(draft)
        try context.save()
        return draft.id
    }

    func insertFriends(_ friends: [APIFriend]) async throws {
        for friend in friends {
            let object = Friend(from: friend)
            context.insert(object)
        }
        try context.save()
    }

    func insertSentDrawings(_ drawings: [APIDrawing]) async throws {
        let friends = try context.fetch(FetchDescriptor<Friend>(predicate: .true))
        for drawing in drawings {
            // TODO: Handle failed insert
            if let object = SentDrawing(from: drawing) {
                // Parsed correctly
                let receivers = friends.filter { friend in
                    drawing.receivers.contains(friend.id)
                }
                object.receivers = receivers
                context.insert(object)
            }
        }
        try context.save()
    }

    func insertReceivedDrawings(_ drawings: [APIDrawing]) async throws {
        let friends = try context.fetch(FetchDescriptor<Friend>(predicate: .true))
        for drawing in drawings {
            // TODO: Handle failed insert
            if let sender = friends.first(where: { $0.id == drawing.senderId }) {
                if let object = ReceivedDrawing(from: drawing) {
                    object.sender = sender
                    context.insert(object)
                }
            }
        }
        try context.save()
    }

    func insertFriendRequests(_ requests: [APIFriendRequest], sent: Bool) async throws {
        for request in requests {
            let object = FriendRequest(from: request, sent: sent)
            context.insert(object)
        }
        try context.save()
    }

    func clearDatabase() throws {
        try context.delete(model: Friend.self)
        try context.delete(model: FriendRequest.self)
        try context.delete(model: SentDrawing.self)
        try context.delete(model: ReceivedDrawing.self)
        try context.save()
    }
}

@ModelActor final actor DataActor {
    init(container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = true
        modelContainer = container
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
}

@MainActor
enum PreviewStore {
    static var selectedUUID = UUID().uuidString
    static var container = {
        let container = try! ModelContainer(
            for: SentDrawing.self,
            ReceivedDrawing.self,
            DraftDrawing.self,
            Friend.self,
            FriendRequest.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(DraftDrawing())
        container.mainContext.insert(DraftDrawing())
        container.mainContext.insert(Friend.example())
        return container
    }()
}
