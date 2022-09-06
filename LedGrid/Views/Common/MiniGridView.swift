//
//  MiniGridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

enum GridViewSize {
    case small
    case large
    case custom(stroke: Double, cornerRadius: Double, spacing: Double)
}


struct MiniGridView: View {
    var grid: Grid
    var viewSize: GridViewSize
    var gridSize: GridSize
    
    var strokeWidth: Double
    var cornerRadius: Double
    var spacing: Double
    
    init(grid: Grid, viewSize: GridViewSize) {
        self.grid = grid
        self.viewSize = viewSize
        
        let gridSize = GridSize(rawValue: grid.count) ?? .small
        self.gridSize = gridSize
        
        switch viewSize {
        case .small:
            switch gridSize {
            case .small:
                strokeWidth = 0.4
                cornerRadius = 3.0
                spacing = 3.0
            case .medium:
                strokeWidth =  0.3
                cornerRadius = 2.5
                spacing = 2.0
            case .large:
                strokeWidth = 0.2
                cornerRadius = 2.0
                spacing = 1.5
            }
        case .large:
            switch gridSize {
            case .small:
                strokeWidth = 1.0
                cornerRadius = 5.0
                spacing = 6.0
            case .medium:
                strokeWidth =  0.8
                cornerRadius = 4.0
                spacing = 4.0
            case .large:
                strokeWidth = 0.6
                cornerRadius = 3.0
                spacing = 2.0
            }
        case .custom(let stroke, let cornerRadius, let spacing):
            strokeWidth = stroke
            self.cornerRadius = cornerRadius
            self.spacing = spacing
        }
    }
    
    
    var body: some View {
        PixelArtGrid(gridSize: gridSize, spacing: spacing) { col, row in
            let color = grid[col][row]
            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
        }
    }
}

//struct MiniGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        MiniGridView(grid: Array(repeating: Array(repeating: Color.blue, count: 8), count: 8))
//    }
//}
