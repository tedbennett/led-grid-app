//
//  MReaction.swift
//  LedGrid
//
//  Created by Ted Bennett on 21/10/2022.
//

import Foundation

struct MReaction: Codable {
    var reaction: String
    var sentAt: Date
    var artId: String
    var sender: String
    var id: String
}
