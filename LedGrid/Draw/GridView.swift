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
        VStack(spacing: 6) {
            ForEach(0..<8) { col in
                HStack(spacing: 6) {
                    ForEach(0..<8) { row in
                        let color = viewModel.grid[col][row]
                        let id = (col * 8) + row
                        TouchableSquareView(id: id, color: color, proxy: proxy)
                    }
                }
            }
        }
    }
    
    var body: some View {
        TouchOverReader(Int.self, onTouch: { id in
            let row = id % 8
            let col = id / 8
            if viewModel.shouldSetGridSquare(row: row, col: col) {
                viewModel.setGridSquare(row: row, col: col)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) { proxy in
            grid(proxy: proxy)
        }
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
        SquareView(color: color)
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
