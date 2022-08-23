//
//  Grid.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

public typealias Grid = [[Color]]

extension Grid {
    func hex() -> String {
        self.flatMap { row in row.map { col in col.hex } }.joined()
    }
}

extension Grid {
    var size: GridSize {
        return GridSize(rawValue: self.count) ?? .small
    }
}

enum GridSize: Int, Codable {
    case small = 8
    case medium = 12
    case large = 16
    
    var blankGrid: Grid {
        Array(repeating: Array(repeating: .black, count: self.rawValue), count: self.rawValue)
    }
}
