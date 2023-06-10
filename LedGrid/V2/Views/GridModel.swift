//
//  GridModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import Foundation
import Observation

@Observable
class GridModel {
    var grid: Grid = .example
    var undoStack: [Grid] = []
    var redoStack: [Grid] = []

    func pushUndo(_ newGrid: Grid) {
        undoStack.append(newGrid)
        redoStack = []
    }

    func undo() {
        guard let newGrid = undoStack.popLast() else { return }
        redoStack.append(grid)
        grid = newGrid
    }

    func redo() {
        guard let newGrid = redoStack.popLast() else { return }
        undoStack.append(grid)
        grid = newGrid
    }
}
