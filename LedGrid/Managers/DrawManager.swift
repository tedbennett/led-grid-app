//
//  DrawManager.shared.swift
//  LedGrid
//
//  Created by Ted on 09/08/2022.
//

import Foundation
import SwiftUI

class DrawManager: ObservableObject {
    
    static var shared = DrawManager()
    private init() { }
    
    
    @Published var grids: [Grid] = Utility.currentGrids
    @Published var gridSize: GridSize = Utility.currentGrids[0].size
    @Published var currentGrid: Grid = {
        let grids = Utility.currentGrids
        return Utility.currentGridIndex < grids.count ? grids[Utility.currentGridIndex] : grids[0]
    }()
    @Published var currentGridIndex: Int = Utility.currentGridIndex {
        didSet {
            currentGrid = grids[currentGridIndex]
        }
    }
    
    @Published var undoStates: [Grid] = []
    @Published var redoStates: [Grid] = []
    private var currentState: Grid = {
        let grids = Utility.currentGrids
        return Utility.currentGridIndex < grids.count ? grids[Utility.currentGridIndex] : grids[0]
    }()
    
    func setCurrentGrids(_ grids: [Grid], clearUndo: Bool = false) {
        self.grids = grids
        gridSize = grids[0].size
        currentGridIndex = 0
        if clearUndo {
            undoStates.removeAll()
            redoStates.removeAll()
        }
    }
    
    func changeToGrid(at index: Int) {
        guard index < grids.count, index != currentGridIndex else { return }
        currentGridIndex = index
        undoStates.removeAll()
        redoStates.removeAll()
        
    }
    
    func setGridSize(_ size: GridSize) {
        if size == gridSize { return }
        clearGrid()
        gridSize = size
        grids = [size.blankGrid]
        currentGridIndex = 0
        undoStates.removeAll()
        redoStates.removeAll()
        currentState = currentGrid
        saveGrid()
    }
    
    func saveGrid() {
        grids[currentGridIndex] = currentGrid
        Utility.currentGrids = grids
        Utility.currentGridIndex = currentGridIndex
    }
    
    func clearGrid() {
        currentGrid = gridSize.blankGrid
        pushUndoState()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func undo() {
        guard let previousState = undoStates.popLast() else { return }
        let currentState = currentGrid
        redoStates.append(currentState)
        currentGrid = previousState
        self.currentState = previousState
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func redo() {
        guard let previousState = redoStates.popLast() else { return }
        let currentState = currentGrid
        undoStates.append(currentState)
        currentGrid = previousState
        self.currentState = previousState
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func pushUndoState() {
        redoStates.removeAll()
        if currentState != currentGrid {
            undoStates.append(currentState)
            currentState = currentGrid
        }
    }
    func copyReceivedGrid(_ received: PixelArt) {
        setGridSize(received.size)
        setCurrentGrids(Utility.isPlus ? received.grids : [received.grids[0]])
    }
    
}

