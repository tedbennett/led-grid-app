//
//  MiniGridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

struct MiniGridView: View {
    var grid: [[Color]]
    var strokeWidth = 1.0
    var cornerRadius = 3.0
    var spacing = 5.0
    
    var body: some View {
        VStack(spacing: spacing) {
            if grid.count == 8 {
                ForEach(0..<8) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<8) { row in
                            let color = grid[col][row]
                            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
                            
                        }
                    }
                }
            } else if grid.count == 12 {
                ForEach(0..<12) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<12) { row in
                            let color = grid[col][row]
                            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
                            
                        }
                    }
                }
            } else if grid.count == 16 {
                ForEach(0..<16) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<16) { row in
                            let color = grid[col][row]
                            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
                            
                        }
                    }
                }
            }
        }
    }
}

struct MiniGridView_Previews: PreviewProvider {
    static var previews: some View {
        MiniGridView(grid: Array(repeating: Array(repeating: Color.blue, count: 8), count: 8))
    }
}
