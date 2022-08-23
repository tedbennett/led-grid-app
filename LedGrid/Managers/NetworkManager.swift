//
//  NetworkManager.swift
//  LedGrid
//
//  Created by Ted on 29/06/2022.
//

import Foundation
import AuthenticationServices
import SimpleKeychain

class NetworkManager {
    static var shared = NetworkManager()
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = PersistenceManager.shared.viewContext
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {
    }
    
    public func getRequest<T: Codable>(url: URL, headers: [String: String]) async throws -> T {
        let data = try await Network.makeRequest(url: url, body: nil, headers: headers)
        return try decoder.decode(T.self, from: data)
    }
    
    func handleSignInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let code = appleIDCredential.authorizationCode,
              let authorizationCode = String(data: code, encoding: .utf8) else {
            // throw
            return
        }
        
        try await AuthService.login(code: authorizationCode)
       
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
    
    
    func deleteAccount() {
        
        AuthService.logout()
        // Delete account endpoint
    }
    
    func getGrid(id: String) async throws -> PixelArt {
        let url = Network.makeUrl([.art, .dynamic(id)])
        let headers = try await AuthService.getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func getGrids(after: Date?) async throws -> [PixelArt] {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let queries: [String: String] = after != nil ? ["after": after!.ISO8601Format()] : [:]
        let url = Network.makeUrl([.art, .users, .dynamic(userId), .received], queries: queries)
        let headers = try await AuthService.getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    
    func getSentGrids(after: Date?) async throws -> [PixelArt] {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let queries: [String: String] = after != nil ? ["after": after!.ISO8601Format()] : [:]
        let url = Network.makeUrl([.art, .users, .dynamic(userId), .sent], queries: queries)
        let headers = try await AuthService.getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func sendGrid(to recipients: [String], grids: [String]) async throws -> PixelArt {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = [
            "receivers": recipients,
            "grid": grids,
        ] as [String : Any]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let url = Network.makeUrl([.art, .users, .dynamic(userId)])
        
        let headers = try await AuthService.getToken()
        
        let data = try await Network.makeRequest(url: url, body: body, method: .post, headers: headers)
        print(try! JSONSerialization.jsonObject(with: data, options: []))
        let art = try decoder.decode(PixelArt.self, from: data)
        
        return art
    }
    
    func getUser(id: String) async throws -> User {
        let url = Network.makeUrl([.users, .dynamic(id)])
        let headers = try await AuthService.getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func createAccount(id: String, fullName: String?, givenName: String?, email: String?) async throws {
        let payload = User(id: id, fullName: fullName, givenName: givenName, email: email)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        let url = Network.makeUrl( [.users])
        
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .post, headers: headers)
    }
    
    func updateUser(id: String, fullName: String, givenName: String, email: String) async throws {
        let payload = User(id: id, fullName: fullName, givenName: givenName, email: email)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        let url = Network.makeUrl([.users, .dynamic(id)])
        
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .put, headers: headers)
    }
    
    func getFriends() async throws -> [User] {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let url = Network.makeUrl([.users, .dynamic(userId), .friends])
        let headers = try await AuthService.getToken()
        
        return try await getRequest(url: url, headers: headers)
    }
    
    func addFriend(id: String) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = ["friend": id]
        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = Network.makeUrl([.users, .dynamic(userId), .friends])
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .post, headers: headers)
    }
    
    func deleteFriend(id: String) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }
        let payload = ["friend": id]
        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = Network.makeUrl([.users, .dynamic(userId), .friends])
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .delete, headers: headers)
    }
    
    func registerDevice(with token: String) async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }

        var payload = ["device_id": token, "is_sandbox": false] as [String: Any]
#if DEBUG
        payload["is_sandbox"] = true
#endif

        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = Network.makeUrl([.users, .dynamic(userId), .device])
        
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .put, headers: headers)
    }
    
    func upgradeToPlus() async throws {
        guard let userId = Utility.user?.id else { throw ApiError.noUser }

        let payload = ["plus": true]

        let data = try JSONSerialization.data(withJSONObject: payload)
        let url = Network.makeUrl([.users, .dynamic(userId), .plus])
        
        let headers = try await AuthService.getToken()
        
        let _ = try await Network.makeRequest(url: url, body: data, method: .put, headers: headers)
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

