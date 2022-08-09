//
//  DrawViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

class DrawViewModel: ObservableObject {
    
    typealias Grid = [[Color]]
    
    var manager = DrawManager.shared
    @Published var currentColor: Color = .red
    @Published var selectedUsers: [String] = Utility.lastSelectedFriends
    
    @Published var sendingGrid = false
    
    @Published var sentGrid = false
    @Published var failedToSendGrid = false
    @Published var showColorChangeToast = false
    
    @Published var hue = 0.03 {
        didSet {
            updateCurrentColor()
        }
    }
    @Published var opacity = 0.5 {
        didSet {
            updateCurrentColor()
        }
    }
    
    func updateCurrentColor() {
        currentColor = Color(
           UIColor(
               hue: hue,
               saturation: opacity > 0.5 ? 1 - (2 * (opacity - 0.5)) : 1,
               brightness: opacity < 0.5 ? 2 * opacity : 1,
               alpha: 1.0
           )
       )
    }
    
    func setColor(_ color: Color) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        self.hue = h
        if s >= 0.99 {
            self.opacity = b / 2
        } else if b >= 0.99 {
            self.opacity = 1 - (s / 2)
        } else {
            self.opacity = (s / 2) + (b / 2)
        }
    }
    
    func undo() {
        DrawManager.shared.undo()
    }
    
    func redo() {
        DrawManager.shared.redo()
        
    }
    
    func pushUndoState() {
        DrawManager.shared.pushUndoState()
    }
    
    func selectColor(_ color: Color) {
        currentColor = color
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func shouldSetGridSquare(row: Int, col: Int) -> Bool {
        return manager.grid[col][row] != currentColor
    }
    
    func setGridSquare(row: Int, col: Int) {
        manager.grid[col][row] = currentColor
    }
    
    func setGridSize(_ size: GridSize) {
        DrawManager.shared.setGridSize(size)
    }
    
    func saveGrid() {
        DrawManager.shared.saveGrid()
    }
    
    func clearGrid() {
        DrawManager.shared.clearGrid()
    }
    
    var hexGrid: [[String]] {
        manager.grid.map { row in row.map { $0.hex } }
    }
    
    var isGridBlank: Bool {
        manager.grid == manager.gridSize.blankGrid
    }
    
    private func flattenGrid(_ grid: [[Color]]) -> String {
        return grid.flatMap { row in row.map { $0.hex }}.joined(separator: "")
    }
    
    func sendGrid() {
        sendingGrid = true
        Task {
            Utility.lastSelectedFriends = selectedUsers
            let success = await GridManager.shared.sendGrid(manager.grid, to: selectedUsers)
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
    
}

