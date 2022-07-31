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

fileprivate var API_ENDPOINT = "https://rlefhg7mpa.execute-api.us-east-1.amazonaws.com"

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
    
    private func getUrl(endpoints: [Endpoint], queries: [String: String] = [:]) -> URL {
        return makeUrl(base: API_ENDPOINT, paths: endpoints.map { $0.raw }, queries: queries)!
    }
    
    func handleSignInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let code = appleIDCredential.authorizationCode,
              let authorizationCode = String(data: code, encoding: .utf8) else {
            // throw
            return
        }
        
        let credentials = try await Auth0.authentication().login(appleAuthorizationCode: authorizationCode, fullName: appleIDCredential.fullName, audience: "https://com.edwardbennett.LedGrid", scope: "offline_access").start()
        
        let _ = credentialManager.store(credentials: credentials)
        
       
        if try await !checkUserExists(id: appleIDCredential.user) {
            UserManager.shared.setUser(User(
                id: appleIDCredential.user,
                fullName: appleIDCredential.fullName?.formatted(),
                givenName: appleIDCredential.fullName?.givenName,
                email: appleIDCredential.email
            ))
            try await createAccount(id: appleIDCredential.user, fullName: appleIDCredential.fullName?.formatted(), givenName: appleIDCredential.fullName?.givenName, email: appleIDCredential.email)
        } else {
            let user = try await getUser(id: appleIDCredential.user)
            UserManager.shared.setUser(user)
        }
        
    }
    
    func logout() {
        _ = credentialManager.clear()
    }
    
    func deleteAccount() {
        
        logout()
        // Delete account endpoint
    }
    
    func getGrid(id: String) async throws -> PixelArt {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let url = getUrl(endpoints: [.user, .dynamic(userId), .grid, .dynamic(id)])
        let headers = try await getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func getGrids(after: Date?) async throws -> [ColorGrid] {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let queries: [String: String] = after != nil ? ["after": "\(after!.timeIntervalSince1970)"] : [:]
        let url = getUrl(endpoints: [.user, .dynamic(userId), .grid], queries: queries)
        let headers = try await getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func createGrid(id: String, grid: [[String]]) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = PixelArt(user: userId, grid: grid, id: id)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(payload)
        let url = getUrl(endpoints: [.grid])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .put, headers: headers)
    }
    
    func sendGrid(id: String, to recipient: String, grid: String, gridSize: GridSize) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = [
            "receiver": recipient,
            "id": id,
            "grid": grid,
            "grid_size": gridSize.rawValue
        ] as [String : Any]
        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = getUrl(endpoints: [.user, .dynamic(userId), .grid])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .post, headers: headers)
    }
    
    func getUser(id: String) async throws -> User {
        let url = getUrl(endpoints: [.user, .dynamic(id)])
        let headers = try await getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func createAccount(id: String, fullName: String?, givenName: String?, email: String?) async throws {
        let payload = User(id: id, fullName: fullName, givenName: givenName, email: email)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(payload)
        let url = getUrl(endpoints: [.user])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .put, headers: headers)
    }
    
    func updateUser(id: String, fullName: String, givenName: String, email: String) async throws {
        let payload = User(id: id, fullName: fullName, givenName: givenName, email: email)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(payload)
        let url = getUrl(endpoints: [.user, .dynamic(id)])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .patch, headers: headers)
    }
    
    func registerDevice(with token: String) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = ["device": token]
        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = getUrl(endpoints: [.user, .dynamic(userId), .device])
        
        let headers = try await getToken()
        
        let _ = try await makeRequest(url: url, body: data, method: .patch, headers: headers)
    }
    
    func checkUserExists(id: String) async throws -> Bool {
        do {
            let _ = try await getUser(id: id)
            return true
        } catch NetworkError.notFound {
            return false
        }
    }
}

enum ApiError: Error {
    case noToken
    case noUser
}

enum Endpoint {
    case user
    case device
    case grid
    case send
    case dynamic(String)
    
    var raw: String {
        switch self {
        case .user: return "user"
        case .device: return "device"
        case .grid: return "grid"
        case .send: return "send"
        case .dynamic(let str): return str
        }
    }
}

struct User: Codable, Identifiable {
    var id: String
    var fullName: String?
    var givenName: String?
    var email: String?
}

struct PixelArt: Codable, Identifiable {
    var user: String
    var grid: [[String]]
//    var sentAt: Date?
    var id: String
}
