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
    case lastReceivedFetchDate
    case lastSelectedFriends
    case artNamesForWidget
    case showGuides
    case user
    case friends
    case colorPicker
    case haptics
    case spinningLogo
    case motionLogo
    case lastOpenedVersion
    case launchedBefore
    case isPlus
}
let background = Color.black
let foreground = Color.white

let DEFAULT_GRID = [
    [background, background, background, background, background, background, background, background],
    [background, background, foreground, background, background, foreground, background, background],
    [background, background, foreground, background, background, foreground, background, background],
    [background, background, background, background, background, background, background, background],
    [background, background, background, background, background, background, background, background],
    [background, foreground, background, background, background, background, foreground, background],
    [background, foreground, foreground, foreground, foreground, foreground, foreground, background],
    [background, background, background, background, background, background, background, background],
]
struct Utility {
    
    static let store = UserDefaults(suiteName: "group.9Y2AMH5S23.com.edwardbennett.pixee")!
    
    static func clear() {
        currentGrids = [GridSize.small.blankGrid]
        currentGridIndex = 0
        // User is cleared elsewhere
//        user = nil
        friends = []
        isPlus = false
        lastReceivedFetchDate = nil
        lastReactionFetchDate = nil
        lastSelectedFriends = []
        colourPickerVariant = .full
        haptics = true
        showGuides = true
        lastSelectedFriends = []
        motionLogo = false
        spinningLogo = true
    }
    
    // User data
    @UserDefaultsValue(nil, key: .user) static var user: MUser?
    @UserDefaultsValue([], key: .friends) static var friends: [MUser]
    @AppStorage(UDKeys.isPlus.rawValue, store: Utility.store) static var isPlus = false
    
    // Editor
    @UserDefaultsValue([GridSize.small.blankGrid], key: .currentGrids) static var currentGrids: [Grid]
    @AppStorage(UDKeys.currentGridIndex.rawValue, store: Utility.store) static var currentGridIndex = 0
    @AppStorage(UDKeys.lastSelectedFriends.rawValue, store: Utility.store) static var lastSelectedFriends: [String] = []
    @AppStorage(UDKeys.lastReactions.rawValue, store: Utility.store) static var lastReactions = ["🥰", "😂", "🤨"]

    // App MetaData
    @AppStorage(UDKeys.launchedBefore.rawValue, store: Utility.store) static var launchedBefore = false
    @AppStorage(UDKeys.lastOpenedVersion.rawValue, store: Utility.store) static var lastOpenedVersion = 1
    
    // Data fetching
    @AppStorage(UDKeys.lastReactionFetchDate.rawValue, store: Utility.store) static var lastReactionFetchDate: Date?
    @AppStorage(UDKeys.lastReceivedFetchDate.rawValue, store: Utility.store) static var lastReceivedFetchDate: Date?
    
    // Preferences
    @AppStorage(UDKeys.colorPicker.rawValue, store: Utility.store) static var colourPickerVariant: ColorPickerVariant = .full
    @AppStorage(UDKeys.haptics.rawValue, store: Utility.store) static var haptics = true
    @AppStorage(UDKeys.showGuides.rawValue, store: Utility.store) static var showGuides = true
    @AppStorage(UDKeys.motionLogo.rawValue, store: Utility.store) static var motionLogo = false
    @AppStorage(UDKeys.spinningLogo.rawValue, store: Utility.store) static var spinningLogo = true
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

typealias StringArray = [String]

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
