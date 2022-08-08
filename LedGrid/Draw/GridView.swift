//
//  GridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var viewModel: DrawViewModel
    
    func grid(proxy: TouchOverProxy<Int>) -> some View {
        PixelArtGrid(gridSize: viewModel.gridSize) { col, row in
            let color = viewModel.grid[col][row]
            let id = (col * viewModel.gridSize.rawValue) + row
            TouchableSquareView(id: id, color: color, proxy: proxy)
        }
    }
    
    var body: some View {
        TouchOverReader(Int.self, onTouch: { id in
            let row = id % viewModel.gridSize.rawValue
            let col = id / viewModel.gridSize.rawValue
            if viewModel.shouldSetGridSquare(row: row, col: col) {
                viewModel.setGridSquare(row: row, col: col)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) { proxy in
            grid(proxy: proxy)
        }
        .simultaneousGesture(
            DragGesture()
                .onEnded { _ in
                    viewModel.pushUndoState()
                }
        ).simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    viewModel.pushUndoState()
                }
        )
    }
}

//struct GridView_Previews: PreviewProvider {
//    static var previews: some View {
//        GridView(color: .constant(.blue))
//    }
//}

struct TouchableSquareView: View {
    let id: Int
    let color: Color
    let proxy: TouchOverProxy<Int>
    
    var body: some View {
        SquareView(color: color, strokeWidth: 1, cornerRadius: 5)
            .aspectRatio(contentMode: .fit)
        //        .frame(width: 40, height: 40)
            .touchOver(id: id, proxy: proxy)
    }
}

class TouchOverProxy<ID: Hashable> {
    let onTouch: ((ID) -> Void)?
    
    private var frames = [ID: CGRect]()
    
    init(onTouch: ((ID) -> Void)?) {
        self.onTouch = onTouch
    }
    
    func register(id: ID, frame: CGRect) {
        frames[id] = frame
    }
    
    func check(dragPosition: CGPoint) {
        for (id, frame) in frames {
            if frame.contains(dragPosition) {
                DispatchQueue.main.async { [self] in
                    onTouch?(id)
                }
            }
        }
    }
}

struct TouchOverReader<ID, Content>: View where ID : Hashable, Content : View {
    private let proxy: TouchOverProxy<ID>
    private let content: (TouchOverProxy<ID>) -> Content
    
    init(_ idSelf: ID.Type, // without this, the initializer can't infer ID type
         onTouch: ((ID) -> Void)? = nil,
         @ViewBuilder content: @escaping (TouchOverProxy<ID>) -> Content) {
        proxy = TouchOverProxy(onTouch: onTouch)
        self.content = content
    }
    
    var body: some View {
        content(proxy)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        proxy.check(dragPosition: value.location)
                    }
            )
    }
}

struct GroupTouchOver<ID>: ViewModifier where ID : Hashable {
    let id: ID
    let proxy: TouchOverProxy<ID>
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geo in
                dragObserver(geo)
            })
    }
    
    private func dragObserver(_ geo: GeometryProxy) -> some View {
        proxy.register(id: id, frame: geo.frame(in: .global))
        return Color.clear
    }
}

extension View {
    func touchOver<ID: Hashable>(id: ID, proxy: TouchOverProxy<ID>) -> some View {
        self.modifier(GroupTouchOver(id: id, proxy: proxy))
    }
}


struct PixelArtGrid<Content: View>: View {
    let content: (Int, Int) -> Content
    let gridSize: GridSize
    let _spacing: Double?
    
    init(gridSize: GridSize, spacing: Double? = nil, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.content = content
        self.gridSize = gridSize
        self._spacing = spacing
    }
    
    var spacing: Double {
        if let spacing = _spacing { return spacing }
        switch gridSize {
        case .small:
            return 6
        case .medium:
            return 4
        case .large:
            return 2
        }
    }
    
    var body: some View {
        switch gridSize {
        case .small:
            VStack(spacing: spacing) {
                ForEach(0..<8) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<8) { row in
                            content(col, row)
                        }
                    }
                }
            }
        case .medium:
            VStack(spacing: spacing) {
                ForEach(0..<12) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<12) { row in
                            content(col, row)
                        }
                    }
                }
            }
        case .large:
            VStack(spacing: spacing) {
                ForEach(0..<16) { col in
                    HStack(spacing: spacing) {
                        ForEach(0..<16) { row in
                            content(col, row)
                        }
                    }
                }
            }
        }
    }
    
}
