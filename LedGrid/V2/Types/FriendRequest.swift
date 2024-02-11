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
    var _status: String
    var status: FriendRequestStatus {
        get {
            FriendRequestStatus(rawValue: _status) ?? .sent
        }
        set {
            _status = newValue.rawValue
        }
    }

    init(from request: APIFriendRequest, sent: Bool) {
        id = request.id
        userId = request.userId
        name = request.name
        username = request.username
        self.sent = sent
        createdAt = request.createdAt
        _status = request.status.lowercased()
    }
}

extension FriendRequest: Identifiable {}
