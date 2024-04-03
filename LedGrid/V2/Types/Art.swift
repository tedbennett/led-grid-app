//
//  Art.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import Foundation
import SwiftData

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

    init(id: String = UUID().uuidString, grid: Grid, receivers: [Friend]) {
        self.id = id
        self.receivers = receivers
        createdAt = .now
        updatedAt = nil
        _grid = [grid]
        serializedGrid = try! GridEncoding.encoder.encode([grid])
    }

    init?(from drawing: APIDrawing) {
        id = drawing.id
        updatedAt = drawing.updatedAt
        createdAt = drawing.createdAt
        _grid = drawing.grid
        receivers = []
        guard let serialized = try? GridEncoding.encoder.encode(drawing.grid) else {
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

    init(id: String = UUID().uuidString, grid: Grid) {
        self.id = id
        updatedAt = nil
        createdAt = .now
        sender = nil
        _grid = [grid]
        serializedGrid = try! GridEncoding.encoder.encode([grid])
        opened = false
    }

    init?(from drawing: APIDrawing) {
        id = drawing.id
        updatedAt = drawing.updatedAt
        createdAt = drawing.createdAt
        sender = nil
        _grid = drawing.grid
        guard let serialized = try? GridEncoding.encoder.encode(drawing.grid) else {
            return nil
        }
        serializedGrid = serialized
        opened = false
    }
}

@Model
final class DraftDrawing: Drawing {
    @Attribute(.unique) var id: String
    var updatedAt: Date
    var createdAt: Date

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
