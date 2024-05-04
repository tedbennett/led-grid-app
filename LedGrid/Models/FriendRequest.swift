//
//  FriendRequest.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Foundation
import SwiftData

enum FriendRequestStatus: String, Codable {
    case accepted
    case revoked
    case sent
}

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

    init(id: String,
         sent: Bool,
         userId: String,
         name: String?,
         username: String,
         createdAt: Date,
         status: String)
    {
        self.id = id
        self.userId = userId
        self.name = name
        self.username = username
        self.sent = sent
        self.createdAt = createdAt
        _status = status.lowercased()
    }
}

extension FriendRequest: Identifiable {}
