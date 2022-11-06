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
    case lastReactionFetchDate
    case artNamesForWidget
    case showGuides
    case user
    case friends
    case colorPicker
    case haptics
    case spinningLogo
}

struct Utility {
    
    static let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
    
    static func clear() {
        currentGrids = [GridSize.small.blankGrid]
        currentGridIndex = 0
//        user = nil
        friends = []
        isPlus = false
        lastReceivedFetchDate = nil
        lastSelectedFriends = []
    }
    
    static var currentGridIndex: Int {
        get {
            return store.integer(forKey: UDKeys.currentGridIndex.rawValue)
        }
        set {
            store.set(newValue, forKey: UDKeys.currentGridIndex.rawValue)
        }
    }
    
    @UserDefaultsValue(nil, key: .user) static var user: MUser?
    @UserDefaultsValue([], key: .friends) static var friends: [MUser]
    @UserDefaultsValue([GridSize.small.blankGrid], key: .currentGrids) static var currentGrids: [Grid]
    static var haptics: Bool {
        get {
            store.bool(forKey: UDKeys.haptics.rawValue)
        }
        set {
            store.set(newValue, forKey: UDKeys.haptics.rawValue)
        }
    }
    
//    static var user: MUser? {
//        get {
//            guard let data = store.data(forKey: "user") else {
//                return nil
//            }
//            return try? JSONDecoder().decode(MUser.self, from: data)
//        }
//        set {
//            let data = try? JSONEncoder().encode(newValue)
//            store.set(data, forKey: "user")
//        }
//    }
    
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
    
    static var lastReactionFetchDate: Date? {
        get {
            store.object(forKey: UDKeys.lastReactionFetchDate.rawValue) as? Date
        }
        set {
            store.set(newValue, forKey: UDKeys.lastReactionFetchDate.rawValue)
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
    
    @UserDefaultsValue([], key: .artNamesForWidget) static var artNamesForWidget: [ArtAssociatedName]
    
    static var showGuides: Bool {
        get {
            store.bool(forKey: UDKeys.showGuides.rawValue)
        }
        set {
            store.set(newValue, forKey: UDKeys.showGuides.rawValue)
        }
    }
}


@propertyWrapper struct UserDefaultsValue<T: Codable> {
    var wrappedValue: T {
        get {
            guard let data = store.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data) else {
                return fallback
            }
            return value
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: key)
        }
    }
    
    var store: UserDefaults
    var key: String
    var fallback: T
    
    init(_ fallback: T, key: String,  store: UserDefaults) {
        self.key = key
        self.store = store
        self.fallback = fallback
    }
}

extension UserDefaultsValue {
    init(_ fallback: T, key: UDKeys) {
        self.init(fallback, key: key.rawValue, store: UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!)
    }
}
