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
    
    @Published var grid: [[Color]] = Utility.lastGrid
    @Published var gridSize: GridSize = Utility.lastGridSize
    
    
    @Published var undoStates: [[[Color]]] = []
    @Published var redoStates: [[[Color]]] = []
    private var currentState: [[Color]] = Utility.lastGrid
    
    func setGridSize(_ size: GridSize) {
        if size == gridSize { return }
        clearGrid()
        gridSize = size
        grid = size.blankGrid
        Utility.lastGridSize = size
        undoStates.removeAll()
        redoStates.removeAll()
        currentState = grid
        saveGrid()
    }
    
    func saveGrid() {
        Utility.lastGrid = grid
    }
    
    func clearGrid() {
        grid = gridSize.blankGrid
        pushUndoState()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func undo() {
        guard let previousState = undoStates.popLast() else { return }
        let currentState = grid
        redoStates.append(currentState)
        grid = previousState
        self.currentState = previousState
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func redo() {
        guard let previousState = redoStates.popLast() else { return }
        let currentState = grid
        undoStates.append(currentState)
        grid = previousState
        self.currentState = previousState
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func pushUndoState() {
        redoStates.removeAll()
        if currentState != grid {
            undoStates.append(currentState)
            currentState = grid
        }
    }
    func copyReceviedGrid(_ received: ColorGrid) {
        setGridSize(received.size)
        grid = received.grid
    }
    
}
