//
//  CanvasView.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/06/2023.
//

import SwiftUI

struct CanvasView: View {
    @Bindable var art: DraftDrawing
    @State private var feedback = false
    var color: Color

    @State private var prevGrid: Grid?

    var onChange: (Grid) -> Void

    var body: some View {
        Canvas { context, size in
            let dim = size.width / CGFloat(art.grid.count)
            let size = CGSize(width: dim + 0.2, height: dim + 0.2)
            for (y, row) in art.grid.enumerated() {
                for (x, color) in row.enumerated() {
                    let origin = CGPoint(x: (CGFloat(x) * dim) - 0.1, y: (CGFloat(y) * dim) - 0.1)
                    let rect = CGRect(origin: origin, size: size)
                    let path = Rectangle().path(in: rect)
                    context.fill(path, with: .color(Color(hexString: color)))
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: feedback)
        .aspectRatio(contentMode: .fit)
        .onLocalDragGesture { position, size in
            let x = Int(position.x / size.width * CGFloat(art.grid.count))
            let y = Int(position.y / size.height * CGFloat(art.grid.count))
            if 0...7 ~= x && 0...7 ~= y && art.grid[y][x] != color.hex {
                if prevGrid == nil {
                    prevGrid = art.grid
                }
                art.grid[y][x] = color.hex
                feedback.toggle()
            }
        } onEnded: {
            guard let prevGrid else { return }
            art.updatedAt = .now
            onChange(prevGrid)
            self.prevGrid = nil
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
        )
        .padding(2)
    }
}

// #Preview {
//    CanvasView(art: ReceivedArt(), color: .green) { _ in }
// }

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
