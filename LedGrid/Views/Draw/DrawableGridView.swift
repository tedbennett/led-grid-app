//
//  DrawableGridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import AlertToast

struct DrawableGridView: View {
    @EnvironmentObject var drawViewModel: DrawViewModel
    @ObservedObject var colorViewModel: DrawColourViewModel
    
    
    func grid(proxy: TouchOverProxy<Int>) -> some View {
        GridView(grid: drawViewModel.currentGrid) { _, _, _, col, row in
            let id = (col * drawViewModel.gridSize.rawValue) + row
            let color = drawViewModel.currentGrid[col][row]
            TouchableSquareView(id: id, color: color, proxy: proxy)
        }
    }
    
    var body: some View {
        TouchOverReader(Int.self, onTouch: { id in
            let row = id % drawViewModel.gridSize.rawValue
            let col = id / drawViewModel.gridSize.rawValue
            drawViewModel.trySetGridSquare(row: row, col: col, color: colorViewModel.currentColor)
        }, onLongPress: { id in
            let row = id % drawViewModel.gridSize.rawValue
            let col = id / drawViewModel.gridSize.rawValue
            colorViewModel.setColor(drawViewModel.currentGrid[col][row])
            drawViewModel.showColorChangeToast = true
//            drawViewModel.fillGrid(at: (row: row, col: col), color: colorViewModel.currentColor)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }, onTapEnd: {
            DispatchQueue.main.async {
                drawViewModel.pushUndoState()
            }
        }, onDragEnd: {
            DispatchQueue.main.async {
                drawViewModel.pushUndoState()
            }
        })  { proxy in
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
    
    func getID(position: CGPoint) -> ID? {
        for (id, frame) in frames {
            if frame.contains(position) {
                return id
            }
        }
        return nil
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
    private let onLongPress: ((ID) -> Void)?
    private let onTapEnd: (() -> Void)?
    private let onDragEnd: (() -> Void)?
    
    @State var dragStartTime: Date?
    @State var dragStart: ID?
    
    @State var isDragging = false
    @State var didLongPress = false
    @State var gestureId: String?
    
    init(_ idSelf: ID.Type, // without this, the initializer can't infer ID type
         onTouch: ((ID) -> Void)? = nil,
         onLongPress: ((ID) -> Void)? = nil,
         onTapEnd: (() -> Void)? = nil,
         onDragEnd: (() -> Void)? = nil,
         @ViewBuilder content: @escaping (TouchOverProxy<ID>) -> Content) {
        proxy = TouchOverProxy(onTouch: onTouch)
        self.content = content
        self.onLongPress = onLongPress
        self.onTapEnd = onTapEnd
        self.onDragEnd = onDragEnd
    }
    
    var body: some View {
        content(proxy)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if gestureId == nil {
                            gestureId = UUID().uuidString
                        }
                        let currentGesture = gestureId!
                        if didLongPress {
                            return
                        }
                        if isDragging {
                            proxy.check(dragPosition: value.location)
                        } else if let id = proxy.getID(position: value.location) {
                            if dragStart == nil {
                                // Mark start position and time
                                dragStartTime = value.time
                                dragStart = id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if !self.didLongPress && !self.isDragging && self.gestureId == currentGesture {
                                        self.didLongPress = true
                                        self.onLongPress?(id)
                                    }
                                }
                            } else if dragStart != id {
                                isDragging = true
                                // Now dragging
                                proxy.check(dragPosition: value.location)
                                proxy.check(dragPosition: value.startLocation)
                            } else if let start = dragStartTime, start.distance(to: value.time) > 0.5 {
                                onLongPress?(id)
                                didLongPress = true
                            }
                        }
                    }
                    .onEnded { val in
                        gestureId = nil
                        if !isDragging && !didLongPress {
                            proxy.check(dragPosition: val.location)
                            onTapEnd?()
                        } else if isDragging {
                            onDragEnd?()
                        }
                        isDragging = false
                        didLongPress = false
                        dragStartTime = nil
                        dragStart = nil
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

/// Three possible gestures:
/// 1. Tap gesture -> Changes the colour of the underlying square
/// 2. Long press gesture *in one square* -> Selects the colour of the underlying square
/// 3. Drag gesture -> Changes the colour of all underlying squares
///
/// Also needs to support returning a location when an external drag starts over the grid
///
/// To implement, this will be a single drag gesture
/// On gesture start, cache the initial grid location
/// If gesture is longer than 0.5s, it is now a long press, and shouldn't drag
/// If the gesture moves to another location, it is now a drag
enum DragType {
    case none
    case tap(start: (Int, Int), time: Date)
    case longPress(location: (Int, Int))
    case drag(start: (Int, Int))
}


struct DrawGridView: View {
    @EnvironmentObject var drawViewModel: DrawViewModel
    @ObservedObject var colorViewModel: DrawColourViewModel
    
    // Put this in a vm
    func getCoordinates(at location: CGPoint, in frame: CGRect) -> (Int, Int) {
        let x = Int(location.x / frame.width * Double(drawViewModel.currentGrid.count))
        let y = Int(location.y / frame.height * Double(drawViewModel.currentGrid.count))
        return (x, y)
    }
    
    @State private var dragState: DragType = .none
    
    
    func onDragStart(at location: (Int, Int), start: (Int, Int)) {
        let color = colorViewModel.currentColor
        drawViewModel.trySetGridSquare(row: start.0, col: start.1, color: color)
        drawViewModel.trySetGridSquare(row: location.0, col: location.1, color: color)
        dragState = .drag(start: start)
    }
    
    func onLongPress(at location: (Int, Int)) {
        colorViewModel.setColor(drawViewModel.currentGrid[location.1][location.0])
        drawViewModel.showColorChangeToast = true
        dragState = .longPress(location: location)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            PixelArtGrid(gridSize: drawViewModel.gridSize) { col, row in
                SquareView(color: drawViewModel.currentGrid[col][row])
            }.gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let location = getCoordinates(at: value.location, in: geometry.frame(in: .global))
                        switch dragState {
                        case .none:
                            dragState = .tap(start: location, time: Date.now)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                switch dragState {
                                case .tap(let start, _):
                                    if start == location {
                                        onLongPress(at: location)
                                    }
                                default: break
                                }
                            }
                        case .tap(let start, let time):
                            if start == location && time.distance(to: value.time) > 0.5 {
                                // Long press
                                onLongPress(at: location)
                            } else if start != location {
                                // Drag
                                onDragStart(at: location, start: start)
                            }
                        case .longPress(_):
                            // Do nothing
                            break
                        case .drag(_):
                            let color = colorViewModel.currentColor
                            drawViewModel.trySetGridSquare(row: location.0, col: location.1, color: color)
                        }
                    }
                    .onEnded { _ in
                        switch dragState {
                        case .tap(let start, _):
                            let color = colorViewModel.currentColor
                            drawViewModel.trySetGridSquare(row: start.0, col: start.1, color: color)
                            DispatchQueue.main.async {
                                drawViewModel.pushUndoState()
                            }
                        case .drag(_):
                            DispatchQueue.main.async {
                                drawViewModel.pushUndoState()
                            }
                        default: break
                        }
                        dragState = .none
                    }
            ).onAppear {
                drawViewModel.gridFrame = geometry.frame(in: .global)
            }
        }.aspectRatio(1, contentMode: .fit)
            
    }
}
