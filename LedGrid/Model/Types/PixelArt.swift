//
//  PixelArt.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI

struct PixelArt: Codable, Identifiable {
    var id: String
    var title: String?
    var sentAt: Date
    var sender: String
    var receivers: [String]
    var opened: Bool
    var hidden: Bool
    var grids: [Grid]
    
    enum CodingKeys: String, CodingKey {
        case id, grid, sentAt, opened, hidden, title, sender, receivers
    }
    
    init(
        id: String,
        title: String?,
        sentAt: Date,
        sender: String,
        receivers: [String],
        opened: Bool,
        hidden: Bool,
        grids: [Grid]
    ) {
        self.id = id
        self.title = title
        self.sentAt = sentAt
        self.sender = sender
        self.receivers = receivers
        self.opened = opened
        self.hidden = hidden
        self.grids = grids
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grids.map { $0.hex() }, forKey: .grid)
        try container.encode(title, forKey: .title)
        try container.encode(sentAt, forKey: .sentAt)
        try container.encode(id, forKey: .id)
        try container.encode(opened, forKey: .opened)
        try container.encode(sender, forKey: .sender)
        try container.encode(receivers, forKey: .receivers)
        try container.encode(hidden, forKey: .hidden)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let encodedGrids = try (try? container.decode([String].self, forKey: .grid)) ?? [try container.decode(String.self, forKey: .grid)]
        
        self.grids = PixelArt.parseGrids(from: encodedGrids)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.sentAt = try container.decode(Date.self, forKey: .sentAt)
        self.sender = try container.decode(String.self, forKey: .sender)
        if let receivers = try? container.decode([String].self, forKey: .receivers) {
            self.receivers = receivers
        } else {
            self.receivers = [try container.decode(String.self, forKey: .receivers)]
        }
        self.opened = (try? container.decode(Bool.self, forKey: .opened)) ?? true
        self.hidden = (try? container.decode(Bool.self, forKey: .hidden)) ?? false
    }
    
    static func parseGrids(from strings: [String]) -> [Grid] {
        return strings.map { string in
            let components = string.components(withMaxLength: 6).map { Color(hexString: $0) }
            let size = Int(Double(components.count).squareRoot())
            return (0..<size).map {
                let index = $0 * size
                return Array(components[index..<(index + size)])
            }
        }
    }
    
    var size: GridSize {
        grids[0].size
    }
    
    static var example: Self = PixelArt(
        id: UUID().uuidString,
        title: nil,
        sentAt: Date.now,
        sender: UUID().uuidString,
        receivers: [UUID().uuidString],
        opened: true,
        hidden: false,
        grids: [Grid.example, Grid.example2])
    
    static var example2: Self = PixelArt(
        id: UUID().uuidString,
        title: nil,
        sentAt: Date.now,
        sender: UUID().uuidString,
        receivers: [UUID().uuidString],
        opened: false,
        hidden: false,
        grids: [Grid.example2, Grid.example])
    
    static var example3: Self = PixelArt(
        id: UUID().uuidString,
        title: nil,
        sentAt: Date.now,
        sender: UUID().uuidString,
        receivers: [UUID().uuidString],
        opened: true,
        hidden: false,
        grids: [Grid.example, Grid.example2])
    
}
