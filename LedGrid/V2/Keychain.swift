//
//  Keychain.swift
//  LedGrid
//
//  Created by Ted Bennett on 17/02/2024.
//

import Foundation
import SimpleKeychain

struct Keychain {
    enum Keys: String {
        case apiKey = "API_KEY"
    }

    private static var keychain = SimpleKeychain(service: "Pixee")

    static var apiKey: String? {
        try? keychain.string(forKey: Keys.apiKey.rawValue)
    }

    static func set(_ value: String, for key: Keys) {
        try? keychain.set(value, forKey: key.rawValue)
    }
}
