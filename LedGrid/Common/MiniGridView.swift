//
//  MiniGridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

struct MiniGridView: View {
    var grid: [[Color]]
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<8) { col in
                HStack(spacing: 5) {
                    ForEach(0..<8) { row in
                        let color = grid[col][row]
                        SquareView(color: color, strokeWidth: 1)
                            .frame(width: 12, height: 12)
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
