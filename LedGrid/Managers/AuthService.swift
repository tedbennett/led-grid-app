//
//  AuthService.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation
import SimpleKeychain
import Auth0

class AuthService {
    static let manager = CredentialsManager(authentication: Auth0.authentication())

    static func canRenew() -> Bool {
        return manager.canRenew()
    }
    
    static func login(code: String, fullName: PersonNameComponents? = nil) async throws {
        let credentials = try await Auth0
            .authentication()
            .login(
                appleAuthorizationCode: code,
                fullName: fullName,
                audience: "https://com.edwardbennett.LedGrid",
                scope: "offline_access"
            ).start()
        print(credentials.idToken)
        _ = manager.store(credentials: credentials)
    }
    
    static func getToken() async throws -> [String: String] {
        let token = (try await manager.credentials()).idToken
        return ["Authorization": "Bearer \(token)"]
    }
    
    static func logout() {
        _ = manager.clear()
    }
}
