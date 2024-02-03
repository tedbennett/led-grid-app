//
//  GridModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

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

@Observable
@MainActor
class GridModel {
    var grid: Grid = .empty
    var undoStack: [Grid] = []
    var redoStack: [Grid] = []

    func pushUndo(_ newGrid: Grid) {
        undoStack.append(newGrid)
        redoStack = []
    }

    func undo() async {
        guard let newGrid = undoStack.popLast() else { return }
        redoStack.append(grid)
        grid = newGrid
    }

    func redo() {
        guard let newGrid = redoStack.popLast() else { return }
        undoStack.append(grid)
        grid = newGrid
    }

    func saveArt() {}
}
