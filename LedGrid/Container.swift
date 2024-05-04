//
//  Container.swift
//  LedGrid
//
//  Created by Ted Bennett on 03/05/2024.
//

import Foundation
import SwiftData

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
        modelContainer = container
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.context = context
    }
}
