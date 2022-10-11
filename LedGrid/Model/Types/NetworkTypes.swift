//
//  NetworkTypes.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

struct TokenResponse: Codable {
    var expiresIn: Int
    var idToken: String
    var refreshToken: String
}
struct RefreshResponse: Codable {
    var expiresIn: Int
    var idToken: String
}
