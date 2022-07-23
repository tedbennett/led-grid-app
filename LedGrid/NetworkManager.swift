//
//  NetworkManager.swift
//  LedGrid
//
//  Created by Ted on 29/06/2022.
//

import Foundation
import Utilities

class NetworkManager: Network {
    static var shared = NetworkManager()
    
    private override init() {
        super.init()
    }
    
    func postGrid(_ grid: ColorGrid, completion: @escaping (Error?) -> Void) {
        let url = URL(string: "")!
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(grid) else { return }
        
        makeRequest(url: url, body: data, method: .post) { result in
            switch result {
            case .failure(let error): completion(error)
                return
            case .success(_): completion(nil)
                return
            }
        }
    }
    
    func postToken(_ token: String) {
        let url = URL(string: "/id")!
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(token) else { return }
        
        makeRequest(url: url, body: data, method: .post) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                return
            case .success(_): return
            }
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

