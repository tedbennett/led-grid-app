//
//  NetworkManager.swift
//  LedGrid
//
//  Created by Ted on 29/06/2022.
//

import Foundation
import Utilities
import Auth0
import AuthenticationServices

fileprivate var API_ENDPOINT = ""

class NetworkManager: Network {
    static var shared = NetworkManager()
    
    let credentialManager = CredentialsManager(authentication: Auth0.authentication())
    
    
    private override init() {
        super.init()
    }
    
    private func getToken() async throws -> [String: String] {
        let credentials = try await credentialManager.credentials()
        return ["Authorization": "Bearer \(credentials.idToken)"]
    }
    
    private func getUrl(endpoints: [Endpoint]) -> URL {
        var url = URL(string: API_ENDPOINT)!
        endpoints.forEach { endpoint in
            url.appendPathComponent(endpoint.rawValue)
        }
        return url
    }
    
    func handleSignInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let code = appleIDCredential.authorizationCode,
              let authorizationCode = String(data: code, encoding: .utf8) else {
            // throw
            return
        }
        
        let credentials = try await Auth0.authentication().login(appleAuthorizationCode: authorizationCode, fullName: appleIDCredential.fullName).start()
        
        let _ = credentialManager.store(credentials: credentials)
        Utility.userId = appleIDCredential.user
        if try await !checkUserExists(id: appleIDCredential.user) {
            try await createAccount(id: appleIDCredential.user, fullName: appleIDCredential.fullName?.formatted(), givenName: appleIDCredential.fullName?.givenName, email: appleIDCredential.email)
        }
        
    }
    
    func createAccount(id: String, fullName: String?, givenName: String?, email: String?) async throws {
        let payload = CreateAccountPayload(id: id, fullName: fullName, givenName: givenName, email: email)
        let data = try JSONEncoder().encode(payload)
        let url = getUrl(endpoints: [.user])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .put, headers: headers)
    }
    
    func checkUserExists(id: String) async throws -> Bool {
        return true
    }
}

enum ApiError: Error {
    case noToken
}

enum Endpoint: String {
    case user = "user"
}

struct CreateAccountPayload: Codable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
}
