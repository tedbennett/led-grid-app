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
import OSLog

enum ApiError: Error {
    case forbidden
    case notFound
    case jsonDecodingError(Error)
    case undocumented(Int, UndocumentedPayload)
    case unknown(Error)
}

enum FriendRequestStatus: String, Codable {
    case accepted
    case revoked
    case sent
}

struct API {
    private static var client = Client(
        serverURL: try! Servers.server2(),
        transport: OpenAPIURLSession.URLSessionTransport(),
        middlewares: [AuthorisationMiddleware(), LoggerMiddleware()]
    )

    private init() {}

    static func handleError(e: ApiError) -> ApiError {
        switch e {
        case .forbidden:
            // TODO: Clear core data
            Keychain.clear(key: .apiKey)
            LocalStorage.user = nil
        // Logout
        case .notFound:
            // do nothing
            break
        case .jsonDecodingError:
            // rethrow
            break
        case .undocumented:
            networkLogger.error("Undocumented response from API")
        // rethrow
        case .unknown:
            // rethrow
            break
        }
        return e
    }

    // MARK: - Auth

    static func signIn(code: String, id: String, name: String?, email: String?) async throws -> APISignInResult {
        do {
            let payload: Components.Schemas.SignInPayload = .init(id: id, name: name, email: email, code: code)
            switch try await client.signIn(body: .json(payload)) {
            case .ok(let ok):
                return try ok.body.json
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    // MARK: - Users

    static func getMe() async throws -> APIUser {
        do {
            switch try await client.getMe(.init()) {
            case .ok(let ok):
                return try ok.body.json
            case .notFound: fallthrough
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func updateMe(name: String?, username: String?, image: String?, plus: Bool?) async throws {
        do {
            let payload: Components.Schemas.UpdateUserPayload = .init(image: image, name: name, plus: plus, username: username)
            switch try await client.updateMe(body: .json(payload)) {
            case .noContent:
                return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func deleteMe() async throws {
        do {
            switch try await client.deleteMe() {
            case .noContent:
                return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func createDevice(deviceId: String) async throws {
        do {
            // TODO: Update sandbox to stage
            let payload: Components.Schemas.CreateDevicePayload = .init(deviceId: deviceId, os: "apple", sandbox: true)
            switch try await client.createDevice(body: .json(payload)) {
            case .noContent:
                return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    // MARK: - Usernames

    static func searchUsers(by username: String) async throws -> [APIUser] {
        do {
            switch try await client.searchUsers(query: .init(username: username)) {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func checkUsername(_ username: String) async throws -> Bool {
        do {
            switch try await client.checkUsername(query: .init(username: username)) {
            case .ok(let ok):
                return try ok.body.json.available
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    // MARK: - Friends

    static func getFriends() async throws -> [APIFriend] {
        do {
            switch try await client.getFriends() {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func addFriend(userId: String) async throws {
        do {
            switch try await client.addFriend(path: .init(friendId: userId)) {
            case .noContent: return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func deleteFriend(friendId: String) async throws {
        do {
            switch try await client.deleteFriend(path: .init(friendId: friendId)) {
            case .noContent: return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    // MARK: - Friend Requests

    static func getSentFriendRequests() async throws -> [APIFriendRequest] {
        do {
            switch try await client.getSentFriendRequests() {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func getReceivedFriendRequests() async throws -> [APIFriendRequest] {
        do {
            switch try await client.getReceivedFriendRequests() {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func sendFriendRequest(to userId: String) async throws {
        do {
            switch try await client.sendFriendRequest(query: .init(user: userId)) {
            case .ok:
                return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func updateFriendRequest(_ request: String, status: FriendRequestStatus) async throws {
        do {
            let payload: Components.Schemas.UpdateFriendRequestPayload = .init(status: status.rawValue)
            switch try await client.updateFriendRequest(path: .init(requestId: request), body: .json(payload)) {
            case .noContent:
                return
            case .notFound:
                throw ApiError.notFound
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    // MARK: - Drawings

    static func getSentDrawings(since: Date?) async throws -> [APIDrawing] {
        do {
            switch try await client.getSentDrawings(query: .init(since: since)) {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func getReceivedDrawings(since: Date?) async throws -> [APIDrawing] {
        do {
            switch try await client.getReceivedDrawings(query: .init(since: since)) {
            case .ok(let ok):
                return try ok.body.json
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }

    static func sendDrawing(_ drawing: Grid, to receivers: [String]) async throws {
        do {
            let payload: Components.Schemas.SendDrawingPayload = .init(drawing: [drawing], receivers: receivers)
            switch try await client.sendDrawing(body: .json(payload)) {
            case .noContent:
                return
            case .forbidden:
                throw ApiError.forbidden
            case .undocumented(let statusCode, let payload):
                throw ApiError.undocumented(statusCode, payload)
            }
        } catch let error as ApiError {
            throw handleError(e: error)
        } catch {
            throw handleError(e: .unknown(error))
        }
    }
}

protocol ApiResponse {}

typealias APIUser = Components.Schemas.User
typealias APIFriend = Components.Schemas.Friend
typealias APIFriendRequest = Components.Schemas.FriendRequest
typealias APIDrawing = Components.Schemas.Drawing
typealias APISignInResult = Components.Schemas.TokenPayload

struct AuthorisationMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var mutableRequest = request
        if let accessToken = Keychain.apiKey {
            let field = HTTPField(
                name: .authorization,
                value: "Bearer \(accessToken)"
            )
            mutableRequest.headerFields.append(field)
        }
        return try await next(mutableRequest, body, baseURL)
    }
}

let networkLogger = Logger(subsystem: "Pixee", category: "Network")
struct LoggerMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        networkLogger.info("Network operation: \(operationID) \n \(request.method) \(String(describing: request.path))")
        return try await next(request, body, baseURL)
    }
}
