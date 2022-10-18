//
//  User.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

struct MUser: Codable, Identifiable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
    
    
    static var example = MUser(id: "123", fullName: "Ted Bennett", email: "ted@email.com")
}

