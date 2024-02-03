//
//  Network.swift
//  LedGrid
//
//  Created by Ted Bennett on 31/01/2024.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

struct API {
    static var client = Client(
        serverURL: try! Servers.server2(),
        transport: OpenAPIURLSession.URLSessionTransport(),
        middlewares: [AuthorisationMiddleware()]
    )
    
    private init() {}
    
    static func getMe() async throws -> User {
        do {
            let user = try await client.getMe(.init()).ok.body.json
            return user
        } catch {
            throw error
        }
    }
}

typealias User = Components.Schemas.User

struct AuthorisationMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var mutableRequest = request
        let accessToken = ProcessInfo.processInfo.environment["ACCESS_TOKEN"]!
        let field = HTTPField(
            name: .authorization,
            value: "Bearer \(accessToken)"
        )
        mutableRequest.headerFields.append(field)
        return try await next(mutableRequest, body, baseURL)
    }
}
