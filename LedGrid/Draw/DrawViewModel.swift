//
//  DrawViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

class DrawViewModel: ObservableObject {
    @Published var grid: [[Color]] = Utility.lastGrid
    @Published var currentColor: Color = .blue
    @Published var message: String = ""
    @Published var isLiveEditing: Bool = false
    
    func shouldSetGridSquare(row: Int, col: Int) -> Bool {
        return grid[col][row] != currentColor
    }
    
    func setGridSquare(row: Int, col: Int) {
        grid[col][row] = currentColor
        if isLiveEditing {
            sendGrid()
        }
    }
    
    func saveGrid() {
        Utility.lastGrid = grid
    }
    
    private func flattenGrid(_ grid: [[Color]]) -> String {
        return grid.flatMap { row in row.map { $0.hex }}.joined(separator: "")
    }
    
    func sendGrid() {
        
    }
    
    func uploadGrid() {
        if var sentGrid = Utility.sentGrids.first(where: { flattenGrid($0.grid) == flattenGrid(grid) }) {
            sentGrid.updateDate()
            Utility.sentGrids.removeAll(where: { $0.id == sentGrid.id })
            Utility.sentGrids.append(sentGrid)
            NetworkManager.shared.postGrid(sentGrid) { error in
                // Do something with error
            }
        } else {
            let colorGrid = ColorGrid(id: UUID().uuidString, grid: grid)
            Utility.sentGrids.append(colorGrid)
            NetworkManager.shared.postGrid(colorGrid) { error in
                // Do something with error
            }
        }
    }
    
    func sendGridToDevice() {
        
    }
    
    func clearGrid() {
        grid = Array(repeating: Array(repeating: Color.black, count: 8), count: 8)
        saveGrid()
    }
}

