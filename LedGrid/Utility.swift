//
//  Utility.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct Utility {
    static var lastGrid: [[Color]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lastGrid"),
                  let colors = try? JSONDecoder().decode([[Color]].self, from: data) else {
                return Array(repeating: Array(repeating: Color.black, count: 8), count: 8)
            }
            return colors
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "lastGrid")
        }
    }
    
    static var receivedGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "receivedGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "receivedGrids")
        }
    }
    
    static var sentGrids: [ColorGrid] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "sentGrids"),
                  let grids = try? JSONDecoder().decode([ColorGrid].self, from: data) else {
                return []
            }
            return grids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "sentGrids")
        }
    }
    
    static var gridDuration: Double {
        get {
            let duration = UserDefaults.standard.double(forKey: "duration")
            return duration > 0 ? duration : 5
        } set {
            UserDefaults.standard.set(newValue, forKey: "duration")
        }
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
