//
//  DrawViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

class DrawViewModel: ObservableObject {
    
    typealias Grid = [[Color]]
    
    @Published var grid: Grid = Utility.lastGrid
    @Published var gridSize: GridSize = Utility.lastGridSize
    @Published var currentColor: Color = .red
    @Published var message: String = ""
    @Published var isLiveEditing: Bool = false
    @Published var selectedUsers: [String] = Utility.lastSelectedFriends
    
    @Published var sendingGrid = false
    
    @Published var sentGrid = false
    @Published var failedToSendGrid = false
    
    @Published var undoStates: [Grid] = []
    @Published var redoStates: [Grid] = []
    private var currentState: Grid = Utility.lastGrid
    
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
    
    func selectColor(_ color: Color) {
        currentColor = color
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func shouldSetGridSquare(row: Int, col: Int) -> Bool {
        return grid[col][row] != currentColor
    }
    
    func setGridSquare(row: Int, col: Int) {
        grid[col][row] = currentColor
    }
    
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
    
    var hexGrid: [[String]] {
        grid.map { row in row.map { $0.hex } }
    }
    
    var isGridBlank: Bool {
        grid == gridSize.blankGrid
    }
    
    private func flattenGrid(_ grid: [[Color]]) -> String {
        return grid.flatMap { row in row.map { $0.hex }}.joined(separator: "")
    }
    
    func sendGrid() {
        sendingGrid = true
        Task {
            Utility.lastSelectedFriends = selectedUsers
            let success = await GridManager.shared.sendGrid(grid, to: selectedUsers)
            await MainActor.run {
                sendingGrid = false
                if success {
                    sentGrid = true
                } else {
                    failedToSendGrid = true
                }
            }
        }
    }
    
    func clearGrid() {
        grid = gridSize.blankGrid
        pushUndoState()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

