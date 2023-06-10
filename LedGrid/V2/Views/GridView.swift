//
//  GridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/06/2023.
//

import SwiftUI

struct GridView: View {
    var grid: Grid
    var body: some View {
        Canvas { context, size in
            let dim = size.width / CGFloat(grid.count)
            let size = CGSize(width: dim + 0.2, height: dim + 0.2)
            for (y, row) in grid.enumerated() {
                for (x, color) in row.enumerated() {
                    let origin = CGPoint(x: (CGFloat(x) * dim) - 0.1, y: (CGFloat(y) * dim) - 0.1)
                    let rect = CGRect(origin: origin, size: size)
                    let path = Rectangle().path(in: rect)
                    context.fill(path, with: .color(Color(hexString: color)))
                }
            }
        }
    }
}

#Preview {
    GridView(grid: Grid.empty)
}
