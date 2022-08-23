//
//  User.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
}

