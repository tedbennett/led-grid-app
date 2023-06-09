//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftUI

let logger = Logger(subsystem: "Pixee", category: "Canvas")

struct Home: View {
    @State private var grid: Grid = .example
    let now = Date().timeIntervalSince1970
    @State private var feedback = false
    var body: some View {
        TabView {
            VStack {
                Canvas { context, size in
                    let dim = size.width / CGFloat(grid.count)
                    let size = CGSize(width: dim + 0.2, height: dim + 0.2)
                    for (y, row) in grid.enumerated() {
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
                .onLocalTapGesture { position, size in
                    logger.info("Tapped at: \(position.x), \(position.y)")
                    let x = Int(position.x / size.width * CGFloat(grid.count))
                    let y = Int(position.y / size.height * CGFloat(grid.count))
                    logger.info("Registered as: \(x), \(y)")
                    if 0...7 ~= x && 0...7 ~= y {
                        grid[y][x] = Color.yellow
                        feedback.toggle()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .gesture(DragGesture(), including: .gesture)

                Spacer()
                HStack(alignment: .bottom) {
                    Button {} label: {
                        Image(systemName: "arrow.counterclockwise")
                    }.padding(.leading, 10)
                    Button {} label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "paperplane").padding().background(Circle().fill(.gray))
                    }
                    Spacer()
                    Circle().fill().frame(width: 35).padding(.trailing, 10)
                }
            }
            Text("First")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#Preview {
    Home()
}

struct LocalTapGesture: ViewModifier {
    let action: (CGPoint, CGSize) -> Void
    let space = UUID().uuidString

    func body(content: Content) -> some View {
        content
            .allowsHitTesting(false)
            .coordinateSpace(.named(space))
            .background {
                GeometryReader { geometry in
                    Color.black
                        .onTapGesture(count: 1, coordinateSpace: .named(space)) { position in
                            action(position, geometry.size)
                        }
                }.padding(1)
            }
    }
}

extension View {
    func onLocalTapGesture(_ action: @escaping (CGPoint, CGSize) -> Void) -> some View {
        modifier(LocalTapGesture(action: action))
    }
}
