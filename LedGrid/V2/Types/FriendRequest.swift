//
//  FriendRequest.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Foundation
import SwiftData

@Model
class FriendRequest {
    @Attribute(.unique) var id: String = UUID().uuidString
    var sent: Bool
    var userId: String
    var createdAt: Date

    init(from request: APIFriendRequest, sent: Bool) {
        id = request.id
        userId = sent ? request.receiverId : request.senderId
        self.sent = sent
        createdAt = friend.createdAt
    }
}
