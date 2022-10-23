//
//  Endpoints.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

enum Endpoint {
    case users
    case device
    case art
    case received
    case friends
    case sent
    case last
    case auth
    case login
    case refresh
    case plus
    case reactions
    case dynamic(String)
    
    var raw: String {
        switch self {
        case .users: return "users"
        case .device: return "device"
        case .art: return "art"
        case .friends: return "friends"
        case .sent: return "sent"
        case .received: return "received"
        case .last: return "last"
        case .auth: return "auth"
        case .login: return "login"
        case .refresh: return "refresh"
        case .plus: return "plus"
        case .reactions: return "reactions"
        case .dynamic(let str): return str
        }
    }
}
