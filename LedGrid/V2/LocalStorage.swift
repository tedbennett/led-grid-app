//
//  LocalStorage.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Foundation

/// Typesafe wrapper around UserDefaults
struct LocalStorage {
    static var user: APIUser? {
        get {
            return UserDefaults.standard.data(forKey: "USER").flatMap {
                try? JSONDecoder().decode(APIUser.self, from: $0)
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "USER")
            }
        }
    }

    static var fetchDate: Date? {
        get {
            return UserDefaults.standard.data(forKey: "LAST_RECEIVED_DRAWINGS").flatMap {
                try? JSONDecoder().decode(Date.self, from: $0)
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "LAST_RECEIVED_DRAWINGS")
            }
        }
    }
}
