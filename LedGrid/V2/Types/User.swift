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
    @Attribute(.unique) var id: String
    @Relationship(.cascade) var sentArt: [SentArt]
    @Relationship(.cascade) var receivedArt: [ReceivedArt]
}
