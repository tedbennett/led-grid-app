//
//  DrawGridView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import AlertToast

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
                SquareView(color: drawViewModel.currentGrid[col][row], strokeWidth: Utility.showGuides ? 1.0 : 0.0)
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
