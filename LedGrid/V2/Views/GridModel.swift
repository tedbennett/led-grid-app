//
//  GridModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import Foundation

typealias Grid = [[String]]
extension Grid {
    static let black = "#000000"
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
}
