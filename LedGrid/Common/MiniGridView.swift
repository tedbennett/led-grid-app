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
}


struct MiniGridView: View {
    var grid: [[Color]]
    var viewSize: GridViewSize
    
    var strokeWidth: Double {
        switch viewSize {
        case .small:
            switch gridSize {
            case .small: return 0.4
            case .medium: return 0.3
            case .large: return 0.2
            }
        case .large:
            switch gridSize {
            case .small: return 1.0
            case .medium: return 0.8
            case .large: return 0.6
            }
        }
    }
    
    var cornerRadius: Double {
        switch viewSize {
        case .small:
            switch gridSize {
            case .small: return 3.0
            case .medium: return 2.5
            case .large: return 2.0
            }
        case .large:
            switch gridSize {
            case .small: return 5.0
            case .medium: return 4.0
            case .large: return 3.0
            }
        }
    }
    
    var spacing: Double {
        switch viewSize {
        case .small:
            switch gridSize {
            case .small: return 3
            case .medium: return 2
            case .large: return 1.5
            }
        case .large:
            switch gridSize {
            case .small: return 6
            case .medium: return 4
            case .large: return 2
            }
        }
    }
    
    var gridSize: GridSize {
        GridSize(rawValue: grid.count) ?? .small
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
