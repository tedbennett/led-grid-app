//
//  Utility.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct Utility {
    static var lastGrid: [[Color]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lastGrid"),
                  let colors = try? JSONDecoder().decode([[Color]].self, from: data) else {
                return Array(repeating: Array(repeating: Color.black, count: 8), count: 8)
            }
            return colors
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "lastGrid")
            }
        }
    }
    
    static var receivedGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "receivedGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "receivedGrids")
            }
        }
    }
    
    static var sentGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "sentGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "sentGrids")
            }
        }
    }
    
    static var gridDuration: Int {
        get {
            let duration = UserDefaults.standard.integer(forKey: "duration")
            return duration > 0 ? duration : 5
        } set {
            DispatchQueue.main.async {
                UserDefaults.standard.set(newValue, forKey: "duration")
            }
        }
    }
    
    static var user: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "user") else {
                return nil
            }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "user")
            }
        }
    }
    
    static var friends: [User] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "friends"),
                  let users = try? JSONDecoder().decode([User].self, from: data) else {
                return []
            }
            return users
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "friends")
            }
        }
    }
    
    static var lastReceivedFetchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastReceivedFetchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastReceivedFetchDate")
        }
    }
    
    static var lastSentFetchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastSentFetchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSentFetchDate")
        }
    }
    
    static var lastSelectedFriends: [String] {
        get {
            UserDefaults.standard.array(forKey: "lastSelectedFriends") as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSelectedFriends")
        }
    }
    
    static var launchedBefore: Bool {
        get {
            UserDefaults.standard.bool(forKey: "launchedBefore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "launchedBefore")
        }
    }
    
    static var lastOpenedVersion: String? {
        get {
            UserDefaults.standard.string(forKey: "lastOpenedVersion")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastOpenedVersion")
        }
    }
}
