//
//  User.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import Foundation
import SwiftData

@Model
class Friend {
    @Attribute(.unique) var id: String = UUID().uuidString
    var email: String
    var username: String
    var name: String?
    var createdAt: Date
    var image: String?
    @Relationship(deleteRule: .cascade) var sentArt: [SentDrawing] = []
    @Relationship(deleteRule: .cascade) var receivedArt: [ReceivedDrawing] = []

    init(from friend: APIFriend) {
        name = friend.name
        email = friend.email
        id = friend.id
        username = friend.username
        createdAt = friend.createdAt
        image = friend.image
    }
    
    static func example() -> Friend {
        let friend = APIFriend(createdAt: .now, email: "example@email.com", id: UUID().uuidString, username: "username")
        return .init(from: friend)
    }
}
