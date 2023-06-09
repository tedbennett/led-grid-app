//
//  Network.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import Foundation

#if DEBUG
fileprivate var API_ENDPOINT = "https://pixee-api-development.up.railway.app/v1"
#else
fileprivate var API_ENDPOINT = "https://api.pixee-app.com/v1"
#endif


struct Network {
    init() {}
    
    enum HTTPStatusCode: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    static var endpoint: String!
    
    static func request(_ urlRequest: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
            print("Request failed: \(urlRequest.url?.relativePath ?? "") \(response.statusCode)")
            switch response.statusCode {
            case 400: throw NetworkError.badRequest
            case 401: throw NetworkError.notAuthenticated
            case 403: throw NetworkError.notAuthorized
            case 404: throw NetworkError.notFound
            case 500..<600: throw NetworkError.serverError
            default: break
            }
        }

        return data
    }
    
    static func makeUrl(base: String, paths: [String], queries: [String: String] = [:]) -> URL? {
        let components = URLComponents(string: base)
        guard var components = components else {
            return nil
        }
        
        components.queryItems = queries.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        guard var url = components.url else {
           return nil
        }
        paths.forEach { path in
            url.appendPathComponent(path)
        }
        return url
    }
    
    static func makeUrl(_ endpoints: [Endpoint], queries: [String: String] = [:]) -> URL {
        return makeUrl(base: API_ENDPOINT, paths: endpoints.map { $0.raw }, queries: queries)!
    }
    
    static func makeRequest(url: URL, body: Data?, method: HTTPStatusCode = .get, headers: [String:String] = [:]) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let body = body {
            urlRequest.httpBody = body
        }
        headers.forEach {key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            return try await request(urlRequest)
        } catch NetworkError.notAuthenticated {
            NotificationCenter.default.post(Notification(name: Notifications.logout))
            throw NetworkError.notAuthenticated
        }
    }
    
    
}

enum NetworkError: Error {
    case badUrl
    case badRequest
    case notAuthorized
    case notAuthenticated
    case notFound
    case serverError
    case unknown
    case noData
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badUrl: return "Invalid Url"
        case .badRequest: return "Bad Request"
        case .notAuthorized: return "Not Authorized"
        case .notAuthenticated: return "Not Authenticated"
        case .notFound: return "Not Found"
        case .serverError: return "Server Error"
        case .unknown: return "Unknown"
        case .noData: return "No Data"
        }
    }
}


enum ApiError: Error {
    case noToken
    case noUser
}
