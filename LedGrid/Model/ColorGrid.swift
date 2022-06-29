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
    var opened: Bool
    
    init(id: String, grid: [[Color]], sentAt: Date = Date(), opened: Bool = true) {
        self.id = id
        self.grid = grid
        self.sentAt = sentAt
        self.opened = opened
    }
    
    enum CodingKeys: String, CodingKey {
        case id, grid, sentAt, opened
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.grid = try container.decode([[Color]].self, forKey: .grid)
        self.id = try container.decode(String.self, forKey: .id)
        self.sentAt = try container.decode(Date.self, forKey: .sentAt)
        self.opened = (try? container.decode(Bool.self, forKey: .opened)) ?? true
    }
    
    func toHex() -> [String] {
        return grid.flatMap { $0 }.map { $0.hex }
    }
    
    mutating func updateDate() {
        sentAt = Date()
    }
    
    static func example(color: Color) -> ColorGrid {
        var grid = ColorGrid(
            id: UUID().uuidString,
            grid: Array(repeating: Array(repeating: color, count: 8), count: 8)
        )
        grid.opened = Int.random(in: 0..<2) > 0
        return grid
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
        let parsed = Int(hexString.suffix(6)) ?? 0
        self.init(hex: parsed)
    }
    
    var hex: String {
        let uiColor = UIColor(self)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
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

