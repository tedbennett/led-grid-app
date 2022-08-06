//
//  ColorGrid.swift
//  LedGrid
//
//  Created by Ted on 29/06/2022.
//

import SwiftUI

struct ColorGrid: Identifiable, Codable {
    var id: String
    var grid: [[Color]]
    var sentAt: Date
    var sender: String
    var receiver: [String]
    var opened: Bool
    var hidden: Bool
    
    init(
        id: String,
        grid: [[Color]],
        sender: String,
        receiver: [String],
        sentAt: Date = Date(),
        opened: Bool = false,
        hidden: Bool = false
    ) {
        self.id = id
        self.grid = grid
        self.sentAt = sentAt
        self.opened = opened
        self.sender = sender
        self.receiver = receiver
        self.hidden = hidden
    }
    
    func toHex() -> String {
        grid.flatMap { row in row.map { col in col.hex } }.joined(separator: "")
    }
    
    var size: GridSize {
        switch grid.count {
        case 8: return .small
        case 12: return .medium
        case 16: return .large
        default: return .small
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, grid, sentAt, opened, gridSize, receiver, hidden
        case sender = "user"
    }
    
    private static func parseGrid(from string: String, size: GridSize) -> [[Color]] {
        let components = string.components(withMaxLength: 6).map { Color(hexString: $0) }
        return (0..<size.rawValue).map {
            let index = $0 * size.rawValue
            return Array(components[index..<(index + size.rawValue)])
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gridSize = try container.decode(GridSize.self, forKey: .gridSize)
        let encodedGrid = try container.decode(String.self, forKey: .grid)
        
        self.grid = ColorGrid.parseGrid(from: encodedGrid, size: gridSize)
        self.id = try container.decode(String.self, forKey: .id)
        self.sentAt = try container.decode(Date.self, forKey: .sentAt)
        self.sender = try container.decode(String.self, forKey: .sender)
        if let receivers = try? container.decode([String].self, forKey: .receiver) {
            self.receiver = receivers
        } else {
            self.receiver = [try container.decode(String.self, forKey: .receiver)]
        }
        self.opened = (try? container.decode(Bool.self, forKey: .opened)) ?? false
        self.hidden = (try? container.decode(Bool.self, forKey: .hidden)) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let encoded: [String] = self.grid.flatMap { row in row.map { col in col.hex } }
        try container.encode(encoded.joined(), forKey: .grid)
        try container.encode(GridSize(rawValue: self.grid.count), forKey: .gridSize)
        try container.encode(sentAt, forKey: .sentAt)
        try container.encode(id, forKey: .id)
        try container.encode(opened, forKey: .opened)
        try container.encode(sender, forKey: .sender)
        try container.encode(receiver, forKey: .receiver)
        try container.encode(hidden, forKey: .hidden)
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(hexString: String) {
        let parsed = Int(hexString.suffix(6), radix: 16) ?? 0
        self.init(hex: parsed)
    }
    var hex: String {
        let uiColor = UIColor(self)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"%06x", rgb)
    }
}


fileprivate extension Color {
    typealias SystemColor = UIColor
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}

enum GridSize: Int, Codable {
    case small = 8
    case medium = 12
    case large = 16
}

extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
