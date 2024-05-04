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

    init(name: String?, email: String, id: String, username: String, createdAt: Date, image: String?) {
        self.name = name
        self.email = email
        self.id = id
        self.username = username
        self.createdAt = createdAt
        self.image = image
    }
    
}
