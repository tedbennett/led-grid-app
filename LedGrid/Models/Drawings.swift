//
//  Art.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import Foundation
import SwiftData

protocol Drawing: Identifiable {
    var id: String { get set }
    var grid: Grid { get set }
    var opened: Bool { get set }
    var sender: Friend? { get }
}

struct GridEncoding {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
}

@Model
class SentDrawing: Drawing {
    @Attribute(.unique) var id: String
    var receivers: [Friend]
    var updatedAt: Date?
    var createdAt: Date
    var opened: Bool {
        get {
            true
        }
        set {}
    }

    var sender: Friend? { nil }

    var serializedGrid: Data
    // Cached
    @Transient private var _grid: [Grid]?
    @Transient var grid: Grid {
        get {
            if let grid = _grid { return grid[0] }
            let deser = (try? GridEncoding.decoder.decode([Grid].self, from: serializedGrid)) ?? [Grid.empty]
            _grid = deser
            return deser[0]
        } set {
            _grid = [newValue]
            guard let data = try? GridEncoding.encoder.encode([newValue]) else { return }
            serializedGrid = data
        }
    }

    init?(id: String, grid: [Grid], createdAt: Date, updatedAt: Date?) {
        self.id = id
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        _grid = grid
        receivers = []
        guard let serialized = try? GridEncoding.encoder.encode(grid) else {
            return nil
        }
        serializedGrid = serialized
    }
}

@Model
class ReceivedDrawing: Drawing {
    @Attribute(.unique) var id: String
    var sender: Friend?
    var updatedAt: Date?
    var createdAt: Date
    var opened: Bool = true

    var serializedGrid: Data
    // Cached
    @Transient var _grid: [Grid]?
    @Transient var grid: Grid {
        get {
            if let grid = _grid { return grid[0] }
            let deser = (try? GridEncoding.decoder.decode([Grid].self, from: serializedGrid)) ?? [Grid.empty]
            _grid = deser
            return deser[0]
        } set {
            _grid = [newValue]
            guard let data = try? GridEncoding.encoder.encode([newValue]) else { return }
            serializedGrid = data
        }
    }

    init?(id: String, grid: [Grid], createdAt: Date, updatedAt: Date?, opened: Bool) {
        self.id = id
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        sender = nil
        _grid = grid
        guard let serialized = try? GridEncoding.encoder.encode(grid) else {
            return nil
        }
        serializedGrid = serialized
        self.opened = opened
    }
}

@Model
final class DraftDrawing: Drawing {
    @Attribute(.unique) var id: String
    var updatedAt: Date
    var createdAt: Date
    // Fields to conform with Drawing
    var opened: Bool {
        get {
            true
        }
        set {}
    }

    var sender: Friend? { nil }

    private var serializedGrid: Data
    // Cached
    @Transient private var _grid: [Grid]?
    @Transient var grid: Grid {
        get {
            if let grid = _grid { return grid[0] }
            let deser = (try? GridEncoding.decoder.decode([Grid].self, from: serializedGrid)) ?? [Grid.empty]
            _grid = deser
            return deser[0]
        } set {
            _grid = [newValue]
            guard let data = try? GridEncoding.encoder.encode([newValue]) else { return }
            serializedGrid = data
        }
    }

    init(size: GridSize = .small, color: String = Grid.black) {
        id = UUID().uuidString
        updatedAt = .now
        createdAt = .now
        let grid = [Grid.emptyFor(size: size, color: color)]
        _grid = grid
        serializedGrid = try! GridEncoding.encoder.encode(grid)
    }
}

extension DraftDrawing: Hashable, Identifiable {
    static func == (lhs: DraftDrawing, rhs: DraftDrawing) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

extension ReceivedDrawing: Hashable, Identifiable {
    static func == (lhs: ReceivedDrawing, rhs: ReceivedDrawing) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

extension SentDrawing: Hashable, Identifiable {
    static func == (lhs: SentDrawing, rhs: SentDrawing) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
