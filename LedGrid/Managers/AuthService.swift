//
//  AuthService.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation
import SimpleKeychain

class AuthService {
    static let keychain = SimpleKeychain(service: "Pixee", accessGroup: "9Y2AMH5S23.com.edwardbennett.LedGrid")
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func canRenew() -> Bool {
        return (try? keychain.hasItem(forKey: "id_token")) == true &&
                (try? keychain.hasItem(forKey: "refresh_token")) == true &&
                (try? keychain.hasItem(forKey: "expires_at")) == true
    }
    
    static func getRefreshToken() -> String? {
        return try? keychain.string(forKey: "refresh_token")
    }
    
    static func refreshToken() async throws {
        
        let url = Network.makeUrl([.auth, .refresh])
        let token = try keychain.string(forKey: "refresh_token")
        let payload = ["refresh_token": token]
        let body = try JSONSerialization.data(withJSONObject: payload)
        
        let data = try await Network.makeRequest(url: url, body: body, method: .post)
        let result = try decoder.decode(RefreshResponse.self, from: data)
        
        try keychain.set(result.idToken, forKey: "id_token")
        try keychain.set(Date().advanced(by: Double(result.expiresIn)).ISO8601Format(), forKey: "expires_at")
    }
    
    static func login(code: String) async throws {
        let url = Network.makeUrl([.auth, .login])
        let payload = ["code": code]
        let body = try JSONSerialization.data(withJSONObject: payload)
        
        let data = try await Network.makeRequest(url: url, body: body, method: .post)
        let result = try decoder.decode(TokenResponse.self, from: data)
        
        try keychain.set(result.idToken, forKey: "id_token")
        try keychain.set(result.refreshToken, forKey: "refresh_token")
        try keychain.set(Date().advanced(by: Double(result.expiresIn)).ISO8601Format(), forKey: "expires_at")
    }
    
    static func getToken() async throws -> [String: String] {
        guard try keychain.hasItem(forKey: "id_token"),
                try keychain.hasItem(forKey: "refresh_token"),
                try keychain.hasItem(forKey: "expires_at") else {
            throw ApiError.noToken
        }
        let expires_at = try keychain.string(forKey: "expires_at")
        let newFormatter = ISO8601DateFormatter()
        guard let date = newFormatter.date(from: expires_at) else {
            throw ApiError.noToken
        }
        if Date().timeIntervalSince(date) > 0 {
            // Need to refresh
            try await refreshToken()
        }
        return ["Authorization": "Bearer \(try keychain.string(forKey: "id_token"))"]
    }
    
    static func logout() {
        try? keychain.deleteAll()
    }
}
