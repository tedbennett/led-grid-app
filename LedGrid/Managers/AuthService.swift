//
//  AuthService.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation
import SimpleKeychain
import Auth0
import FirebaseAuth
import CryptoKit

class AuthService {
    static var nonce: String?
    
    static var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func generateNonce() -> String {
        let newNonce = randomNonceString()
        nonce = newNonce
        return toSHA256(newNonce)
    }
    
    static func login(token: String) async throws -> String {
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: token,
            rawNonce: nonce
        )
        let signInResponse =  try await Auth.auth().signIn(with: credential)
        return signInResponse.user.uid
    }
    
    static func getToken() async throws -> [String: String] {
        guard let currentUser = Auth.auth().currentUser else {
            throw ApiError.noUser
        }
        let token = (try await currentUser.getIDToken())
        return ["Authorization": "Bearer \(token)"]
    }
    
    static func logout() {
        do {
            _ = try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private static func toSHA256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

