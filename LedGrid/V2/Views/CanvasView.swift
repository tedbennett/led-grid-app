//
//  CanvasView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct CanvasView: View {
    @Bindable var model: GridModel
    @State private var feedback = false
    
    let color: Color = .yellow

    var body: some View {
        Canvas { context, size in
            let dim = size.width / CGFloat(model.grid.count)
            let size = CGSize(width: dim + 0.2, height: dim + 0.2)
            for (y, row) in model.grid.enumerated() {
                for (x, square) in row.enumerated() {
                    let origin = CGPoint(x: (CGFloat(x) * dim) - 0.1, y: (CGFloat(y) * dim) - 0.1)
                    let rect = CGRect(origin: origin, size: size)
                    let path = Rectangle().path(in: rect)
                    context.fill(path, with: .color(square))
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: feedback)
        .aspectRatio(contentMode: .fit)
        .gesture(DragGesture(), including: .gesture)
        .onLocalTapGesture { position, size in
            logger.info("Tapped at: \(position.x), \(position.y)")
            let x = Int(position.x / size.width * CGFloat(model.grid.count))
            let y = Int(position.y / size.height * CGFloat(model.grid.count))
            logger.info("Registered as: \(x), \(y)")
            if 0...7 ~= x && 0...7 ~= y && model.grid[y][x] != color {
                model.grid[y][x] = color
                feedback.toggle()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(5)
    }
}

#Preview {
    CanvasView(model: GridModel())
}
