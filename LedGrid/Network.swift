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
import Sentry

enum ApiError: Error {
    case forbidden
    case notFound
    case jsonDecodingError(Error)
    case undocumented(Int, UndocumentedPayload)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .forbidden:
            return NSLocalizedString("API returned status Forbidden", comment: "Status Code 403")
        case .notFound:
            return NSLocalizedString("API returned status Not Found", comment: "Status Code 404")

        case .jsonDecodingError(let error):
            return NSLocalizedString("Failed to decode json response", comment: "\(error.localizedDescription)")

        case .undocumented(let status, let response):
            return NSLocalizedString("API returned unexpected status code \(status)", comment: "Response body: \(String(describing: response.body))")

        case .unknown(let error):
            return NSLocalizedString("An unknown error occurred", comment: "\(error.localizedDescription)")
        }
    }
}

struct API {
    static var url: URL {
        if let urlString = ProcessInfo.processInfo.environment["SERVER_URL"] {
            return URL(string: urlString)!
        }
        return try! Servers.server3()
    }

    private static var client = Client(
        serverURL: url,
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
            SentrySDK.capture(error: e)
        // do nothing
        case .jsonDecodingError:
            SentrySDK.capture(error: e)
        // rethrow
        case .undocumented:
            SentrySDK.capture(error: e)
            networkLogger.error("Undocumented response from API")
        // rethrow
        case .unknown:
            SentrySDK.capture(error: e)
            // rethrow
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

    static func createDevice(deviceId: String, sandbox: Bool) async throws {
        do {
            let payload: Components.Schemas.CreateDevicePayload = .init(deviceId: deviceId, os: "apple", sandbox: sandbox)
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

extension ReceivedDrawing {
    convenience init?(from drawing: APIDrawing, opened: Bool = false) {
        self.init(id: drawing.id, grid: drawing.grid, createdAt: drawing.createdAt, updatedAt: drawing.updatedAt, opened: opened)
    }
}

extension SentDrawing {
    convenience init?(from drawing: APIDrawing) {
        self.init(id: drawing.id, grid: drawing.grid, createdAt: drawing.createdAt, updatedAt: drawing.updatedAt)
    }
}

extension Friend {
    convenience init(from friend: APIFriend) {
        self.init(name: friend.name, email: friend.email, id: friend.id, username: friend.username, createdAt: friend.createdAt, image: friend.image)
    }

    static func example() -> Friend {
        let friend = APIFriend(createdAt: .now, email: "example@email.com", id: UUID().uuidString, username: "username")
        return .init(from: friend)
    }
}

extension FriendRequest {
    convenience init(from request: APIFriendRequest, sent: Bool) {
        self.init(id: request.id, sent: sent, userId: request.userId, name: request.name, username: request.username, createdAt: request.createdAt, status: request.status)
    }
}
