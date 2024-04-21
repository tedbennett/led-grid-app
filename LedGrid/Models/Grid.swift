//
//  GridModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import Foundation

enum GridSize: Int {
    case small = 8
    case medium = 10
    case large = 12
}

typealias Grid = [[String]]
extension Grid {
    static let black = "#000000"
    static let white = "#ffffff"
    static let empty: Grid = [
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
        [Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black, Grid.black],
    ]
    
    static func emptyFor(size: GridSize, color: String = Grid.black) -> Grid {
        return (0..<size.rawValue).map { _ in
            (0..<size.rawValue).map { _ in color }
        }
    }
}
