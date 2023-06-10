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
    var color: Color

    @State private var prevGrid: Grid?

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
        .onLocalDragGesture { position, size in
            let x = Int(position.x / size.width * CGFloat(model.grid.count))
            let y = Int(position.y / size.height * CGFloat(model.grid.count))
            if 0...7 ~= x && 0...7 ~= y && model.grid[y][x] != color {
                if prevGrid == nil {
                    prevGrid = model.grid
                }
                model.grid[y][x] = color
                feedback.toggle()
            }
        } onEnded: {
            guard let prevGrid else { return }
            model.pushUndo(prevGrid)
            self.prevGrid = nil
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(5)
    }
}

#Preview {
    CanvasView(model: GridModel(), color: .green)
}

struct LocalDragGesture: ViewModifier {
    let action: (CGPoint, CGSize) -> Void
    let onEnded: () -> Void
    let space = UUID().uuidString

    func body(content: Content) -> some View {
        content
            .allowsHitTesting(false)
            .coordinateSpace(.named(space))
            .background {
                GeometryReader { geometry in
                    Color.black
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                                .onChanged { val in
                                    action(val.location, geometry.size)
                                }.onEnded { _ in
                                    onEnded()
                                }
                        )
                }.padding(1)
            }
    }
}

extension View {
    func onLocalDragGesture(_ action: @escaping (CGPoint, CGSize) -> Void, onEnded: @escaping () -> Void) -> some View {
        modifier(LocalDragGesture(action: action, onEnded: onEnded))
    }
}
