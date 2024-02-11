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
    var name: String?
    var username: String
    var createdAt: Date
    var status: FriendRequestStatus

    init(from request: APIFriendRequest, sent: Bool) {
        id = request.id
        userId = request.userId
        name = request.name
        username = request.username
        self.sent = sent
        createdAt = request.createdAt
        status = FriendRequestStatus(rawValue: request.status) ?? .sent
    }
}

extension FriendRequest: Identifiable {}
