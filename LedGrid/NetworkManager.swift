//
//  NetworkManager.swift
//  LedGrid
//
//  Created by Ted on 29/06/2022.
//

import Foundation

class NetworkManager {
    static var shared = NetworkManager()
    
    private init() { }
    
    func postGrid(_ grid: ColorGrid, completion: @escaping (Error?) -> Void) {
        let url = URL(string: EnvironmentVariables.endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let payload = GridPayload(grid: grid, user: EnvironmentVariables.recipientId)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(payload)
            request.httpBody = data
            URLSession.shared.dataTask(with: request) { _, _, error in
                completion(error)
            }.resume()
        } catch {
            completion(error)
            return
        }
    }
    
    func postToken(_ token: String) {
        let url = URL(string: "\(EnvironmentVariables.endpoint)/id")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let payload = TokenPayload(user: EnvironmentVariables.userId, device: token)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(payload)
            request.httpBody = data
            URLSession.shared.dataTask(with: request) { _, _, error in
                print(error)
            }.resume()
        } catch {
            return
        }
    }
}

struct GridPayload: Codable {
    var grid: ColorGrid
    var user: String
}

struct TokenPayload: Codable {
    var user: String
    var device: String
}

