//
//  Utility.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

enum UDKeys: String {
    case currentGrids
    case currentGridIndex
    case lastReactions
}

struct Utility {
    
    static let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
    
    static func clear() {
        currentGrids = [GridSize.small.blankGrid]
        currentGridIndex = 0
        user = nil
        friends = []
        isPlus = false
        lastReceivedFetchDate = nil
        lastSelectedFriends = []
    }
    
    static var currentGrids: [Grid] {
        get {
            guard let data = store.data(forKey: UDKeys.currentGrids.rawValue),
                  let colors = try? JSONDecoder().decode([Grid].self, from: data) else {
                return [GridSize.small.blankGrid]
            }
            return colors
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: UDKeys.currentGrids.rawValue)
        }
    }
    
    static var currentGridIndex: Int {
        get {
            return store.integer(forKey: UDKeys.currentGridIndex.rawValue)
        }
        set {
            store.set(newValue, forKey: UDKeys.currentGridIndex.rawValue)
        }
    }
    
    static var user: MUser? {
        get {
            guard let data = store.data(forKey: "user") else {
                return nil
            }
            return try? JSONDecoder().decode(MUser.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: "user")
        }
    }
    
    static var friends: [MUser] {
        get {
            guard let data = store.data(forKey: "friends"),
                  let users = try? JSONDecoder().decode([MUser].self, from: data) else {
                return []
            }
            return users
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: "friends")
        }
    }
    
    static var isPlus: Bool {
        get {
            store.bool(forKey: "isPlus")
        }
        set {
            store.set(newValue, forKey: "isPlus")
        }
    }
    
    static var lastReceivedFetchDate: Date? {
        get {
            store.object(forKey: "lastReceivedFetchDate") as? Date
        }
        set {
            store.set(newValue, forKey: "lastReceivedFetchDate")
        }
    }
    
    static var lastSelectedFriends: [String] {
        get {
            store.array(forKey: "lastSelectedFriends") as? [String] ?? []
        }
        set {
            store.set(newValue, forKey: "lastSelectedFriends")
        }
    }
    
    static var lastReactions: [String] {
        get {
            store.array(forKey: UDKeys.lastReactions.rawValue) as? [String] ?? ["🥰", "😂", "🤨"]
        }
        set {
            store.set(newValue, forKey: UDKeys.lastReactions.rawValue)
        }
    }
    
    static var launchedBefore: Bool {
        get {
            store.bool(forKey: "launchedBefore")
        }
        set {
            store.set(newValue, forKey: "launchedBefore")
        }
    }
    
    static var lastOpenedVersion: String? {
        get {
            store.string(forKey: "lastOpenedVersion")
        }
        set {
            store.set(newValue, forKey: "lastOpenedVersion")
        }
    }
}
