//
//  GridView.swift
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


struct GridView<Content: View>: View {
    var grid: Grid
    var content: (Color, Double, Double, Int, Int) -> Content
    var viewSize: GridViewSize
    var strokeWidth: Double
    var cornerRadius: Double
    var spacing: Double
    
    init(grid: Grid, viewSize: GridViewSize = .large, @ViewBuilder content: @escaping (Color, Double, Double, Int, Int) -> Content) {
        self.grid = grid
        
        self.viewSize = viewSize
        let gridSize = GridSize(rawValue: grid.count) ?? .small
        
        switch gridSize {
        case .small:
//            strokeWidth = 0.3
//            cornerRadius = 0
//            spacing = 0
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
        self.content = content
        
    }
    
    init(grid: Grid, viewSize: GridViewSize = .large) where Content == SquareView {
        self.grid = grid
        self.viewSize = viewSize
        let gridSize = GridSize(rawValue: grid.count) ?? .small
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
//                strokeWidth = 0.3
//                cornerRadius = 0
//                spacing = 0
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
            self.strokeWidth = stroke
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            
        }
        
        self.content = { color, strokeWidth, cornerRadius, _, _ in SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius) }
    }
    
    
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(zip(grid.indices, grid)), id: \.0) { col, rowArray in
                HStack(spacing: spacing) {
                    ForEach(Array(zip(rowArray.indices, rowArray)), id: \.0) { row, square in
                        content(square, strokeWidth, cornerRadius, col, row)
                    }
                }
            }
        }
    }
}

//struct MiniGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        MiniGridView(grid: Array(repeating: Array(repeating: Color.blue, count: 8), count: 8))
//    }
//}
