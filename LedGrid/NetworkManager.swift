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
        let url = URL(string: "https://rlefhg7mpa.execute-api.us-east-1.amazonaws.com/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let data = try JSONEncoder().encode(grid)
            request.httpBody = data
            URLSession.shared.dataTask(with: request) { _, _, error in
                completion(error)
            }.resume()
        } catch {
            completion(error)
            return
        }
    }
}
