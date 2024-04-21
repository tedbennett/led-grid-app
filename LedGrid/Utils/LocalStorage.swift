//
//  LocalStorage.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Foundation

enum UserDefaultKey: String, CaseIterable {
    case user = "USER"
    case lastReceivedDrawings = "LAST_RECEIVED_DRAWINGS"
}

/// Typesafe wrapper around UserDefaults
enum LocalStorage {
    static func clear() {
        UserDefaultKey.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }

    static var user: APIUser? {
        get {
            return UserDefaults.standard.data(forKey: UserDefaultKey.user.rawValue).flatMap {
                try? JSONDecoder().decode(APIUser.self, from: $0)
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: UserDefaultKey.user.rawValue)
            }
        }
    }

    static var fetchDate: Date? {
        get {
            return UserDefaults.standard.data(forKey: UserDefaultKey.lastReceivedDrawings.rawValue).flatMap {
                try? JSONDecoder().decode(Date.self, from: $0)
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: UserDefaultKey.lastReceivedDrawings.rawValue)
            }
        }
    }
}
