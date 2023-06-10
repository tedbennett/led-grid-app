//
//  Art.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import Foundation
import SwiftData

@Model
class SentArt {
    @Attribute(.unique) var id: String
    var grid: Grid
    var receivers: [Friend]
    var sentAt: Date
}

@Model
class ReceivedArt {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    @Attribute(.unique) var id: String
    var serializedGrid: Data
    var sender: Friend?
    var lastUpdated: Date
    @Transient var grid: Grid {
        get  {
            return (try? ReceivedArt.decoder.decode(Grid.self, from: serializedGrid)) ?? Grid.empty
        } set {
            guard let data = try? ReceivedArt.encoder.encode(newValue) else { return }
            serializedGrid = data
        }
    }
    
//    init(grid: Grid) {
//        self.id = ""
//        self.lastUpdated = .now
//        self.sender = nil
//        self.grid = grid
//    }
}

@Model
final class DraftArt {
    @Attribute(.unique) var id: UUID
    var lastUpdated: Date
    var createdAt: Date
    private var serializedGrid: Data
    @Transient private var _grid: Grid?
    @Transient var grid: Grid {
        get {
            if let grid = _grid { return grid }
            let deser = (try? ReceivedArt.decoder.decode(Grid.self, from: serializedGrid)) ?? Grid.empty
            _grid = deser
            return deser
        } set {
            _grid = newValue
            guard let data = try? ReceivedArt.encoder.encode(newValue) else { return }
            serializedGrid = data
        }
    }
    
    init () {
        id = UUID()
        lastUpdated = .now
        createdAt = .now
        _grid = .empty
        serializedGrid = try! ReceivedArt.encoder.encode(Grid.empty)
    }
}


extension DraftArt: Hashable, Identifiable {
    static func == (lhs: DraftArt, rhs: DraftArt) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
