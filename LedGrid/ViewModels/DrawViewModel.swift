//
//  DrawViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

class DrawViewModel: ObservableObject {
    @Published var sentGrid = false
    @Published var failedToSendGrid = false
    @Published var showColorChangeToast = false
    @Published var grids: [Grid] = Utility.currentGrids
    @Published var gridSize: GridSize = Utility.currentGrids[0].size
    @Published var currentGrid: Grid = {
        let grids = Utility.currentGrids
        return Utility.currentGridIndex < grids.count ? grids[Utility.currentGridIndex] : grids[0]
    }()
    @Published var currentGridIndex: Int = Utility.currentGridIndex {
        didSet {
            currentGrid = grids[currentGridIndex]
            currentState = currentGrid
        }
    }
    
    @Published var undoStates: [[Grid]] = [[]]
    @Published var redoStates: [[Grid]] = [[]]
    
    @Published var gridFrame: CGRect = .zero
    @AppStorage(UDKeys.showGuides.rawValue, store: Utility.store) var showGuides = true
    init() {
        clearUndoAndRedo()
        NotificationCenter.default.addObserver(self, selector: #selector(copyGrids), name: Notifications.copyGrid, object: nil)
    }
    
    private var currentState: Grid = {
        let grids = Utility.currentGrids
        return Utility.currentGridIndex < grids.count ? grids[Utility.currentGridIndex] : grids[0]
    }()
    
    @objc
    func copyGrids(_ notification: Notification) {
        guard let grids = notification.userInfo?["grids"] as? [Grid],
              let count = grids.first?.count,
              let size = GridSize(rawValue: count),
              let index = notification.userInfo?["index"] as? Int else {
            return
        }
        setGridSize(size)
        setCurrentGrids(Utility.isPlus ? grids : [grids[index]])
    }
    
    
    func setCurrentGrids(_ grids: [Grid]) {
        self.grids = grids
        gridSize = grids[0].size
        currentGridIndex = 0
        clearUndoAndRedo()
    }
    
    func changeToGrid(at index: Int) {
        guard index < grids.count, index != currentGridIndex else { return }
        currentGridIndex = index
    }
    
    func setGridSize(_ size: GridSize) {
        if size == gridSize { return }
        clearGrid()
        gridSize = size
        grids = [size.blankGrid]
        clearUndoAndRedo()
        currentGridIndex = 0
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
        if Utility.haptics {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func clearAllGrids() {
        grids = [gridSize.blankGrid]
        clearUndoAndRedo()
        currentGridIndex = 0
        if Utility.haptics {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func undo() {
        guard let previousState = undoStates[currentGridIndex].popLast() else { return }
        let currentState = currentGrid
        redoStates[currentGridIndex].append(currentState)
        currentGrid = previousState
        self.currentState = previousState
        
        if Utility.haptics {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func redo() {
        guard let previousState = redoStates[currentGridIndex].popLast() else { return }
        let currentState = currentGrid
        undoStates[currentGridIndex].append(currentState)
        currentGrid = previousState
        self.currentState = previousState
        
        if Utility.haptics {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func pushUndoState() {
        redoStates[currentGridIndex].removeAll()
        if currentState != currentGrid {
            undoStates[currentGridIndex].append(currentState)
            currentState = currentGrid
        }
    }
    
    func clearUndoAndRedo() {
        undoStates = grids.map { _ in [] }
        redoStates = grids.map { _ in [] }
    }
    
    var canUndo: Bool {
        return !undoStates[currentGridIndex].isEmpty
    }
    
    var canRedo: Bool {
        return !redoStates[currentGridIndex].isEmpty
    }
    
    
    func trySetGridSquare(row: Int, col: Int, color: Color) {
        guard col < gridSize.rawValue, col >= 0, row < gridSize.rawValue, row >= 0 else { return }
        guard currentGrid[col][row] != color else { return }
        currentGrid[col][row] = color
        if Utility.haptics {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    var isGridBlank: Bool {
        grids.allSatisfy { $0 == gridSize.blankGrid }
    }
    
    func newBlankGrid() {
        grids.append(currentGrid.size.blankGrid)
        undoStates.append([])
        redoStates.append([])
        currentGridIndex = grids.count - 1
    }
    
    func duplicateGrid(_ grid: Grid) {
        grids.append(grid)
        undoStates.append([])
        redoStates.append([])
        currentGridIndex = grids.count - 1
    }
    
    func removeGrid(at index: Int) {
        if currentGridIndex == index {
            currentGridIndex = 0
        } else if index < currentGridIndex {
            currentGridIndex -= 1
        }
        grids.remove(at: index)
        _ = undoStates.remove(at: index)
        _ = redoStates.remove(at: index)
    }
    
    func moveGrid(from origin: Int, to destination: Int) {
        let moved = grids.remove(at: origin)
        grids.insert(moved, at: origin > destination ? destination : destination - 1)
        let undo = undoStates.remove(at: origin)
        undoStates.insert(undo, at: origin > destination ? destination : destination - 1)
        let redo = redoStates.remove(at: origin)
        redoStates.insert(redo, at: origin > destination ? destination : destination - 1)
        if origin == currentGridIndex {
            currentGridIndex = origin > destination ? destination : destination - 1
        } else if currentGridIndex > origin && currentGridIndex < destination {
            currentGridIndex -= 1
        } else if currentGridIndex < origin && currentGridIndex > destination {
            currentGridIndex += 1
        } else {
            currentGrid = grids[currentGridIndex]
        }
    }
}


extension DrawViewModel {
    
    typealias GridCoord = (row: Int, col: Int)
    
    func findGridCoordinates(at point: CGPoint) -> (Int, Int)? {
        guard gridFrame != .zero else { return nil }
        
        let x = Int((point.x - gridFrame.minX) / gridFrame.width * Double(currentGrid.count))
        let y = Int((point.y - gridFrame.minY) / gridFrame.height * Double(currentGrid.count))
        
        guard x >= 0, x < currentGrid.count, y >= 0, y < currentGrid.count else { return nil }
        return (x, y)
    }
    
    func fillGrid(at index: GridCoord, color: Color) {
        let startColor = getColor(at: index)
        
        guard color != startColor else { return }
        var toFill: [GridCoord] = []
        var remainingNeighbours = getNeighbours(at: index).filter {
            getColor(at: $0) == startColor
        }
        
        
        while !remainingNeighbours.isEmpty {
            var current: [GridCoord] = []
            for neighbour in remainingNeighbours {
                let validNeighbours = getNeighbours(at: neighbour).filter { coord in
                    let sameColour = getColor(at: coord) == startColor
                    let exists = current.contains { coord == $0 } || toFill.contains { coord == $0 }
                    return sameColour && !exists
                }
                
                current.append(contentsOf: validNeighbours)
            }
            
            toFill.append(contentsOf: remainingNeighbours)
            remainingNeighbours = current
        }
        let speed = UInt64(100_000 * (1.0 / Double(currentGrid.count)))
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        let haptics = Utility.haptics
        Task { [toFill, speed] in
            for (i, neighbour) in toFill.enumerated() {
                await MainActor.run {
                    self.currentGrid[neighbour.col][neighbour.row] = color
                    if !haptics { return }
                    switch gridSize {
                    case .small: break
                    case .medium: if (i % 2) != 0 { return }
                    case .large: if (i % 3) != 0 { return }
                    }
                    
                    generator.impactOccurred()
                    
                }
                try? await Task.sleep(nanoseconds: speed)
            }
            await MainActor.run {
                self.pushUndoState()
            }
        }
        
        
    }
    
    private func getColor(at coord: GridCoord) -> Color {
        return currentGrid[coord.col][coord.row]
    }
    
    
    private func getNeighbours(at index: GridCoord) -> [GridCoord] {
        var neighbours: [(row: Int, col: Int)] = []
        
        if (index.row != 0) {
            neighbours.append((row: index.row - 1, col: index.col))
        }
        if (index.row != gridSize.rawValue - 1) {
            neighbours.append((row: index.row + 1, col: index.col))
        }
        if (index.col != 0) {
            neighbours.append((row: index.row, col: index.col - 1))
        }
        if (index.col != gridSize.rawValue - 1) {
            neighbours.append((row: index.row, col: index.col + 1))
        }
        return neighbours
    }
    
    private func fillNeighbours(at index: GridCoord, color: Color, startColor: Color) {
        for neighbour in getNeighbours(at: index) {
            if getColor(at: neighbour) == startColor {
                currentGrid[neighbour.col][neighbour.row] = color
            }
        }
    }
}
