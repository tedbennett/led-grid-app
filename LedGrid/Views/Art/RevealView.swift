//
//  RevealView.swift
//  LedGrid
//
//  Created by Ted on 06/08/2022.
//

import SwiftUI
import Combine

struct RevealView: View {
    var grid: Grid
    var strokeWidth = 1.0
    var cornerRadius = 3.0
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    var onFinish: () -> Void
    
    @State private var isTimerRunning = false
    @State private var revealed = 0
    
    
    init(grid: Grid, strokeWidth: Double = 1.0, cornerRadius: Double = 3.0, onFinish: @escaping () -> Void) {
        self.grid = grid
        self.strokeWidth = strokeWidth
        self.cornerRadius = cornerRadius
        self.onFinish = onFinish
        timer = Timer.publish(every: 3.0 / Double(grid.count * grid.count), on: .main, in: .common).autoconnect()
    }
    
    
    var gridSize: GridSize {
        GridSize(rawValue: grid.count) ?? .small
    }
    
    var body: some View {
        GridView(grid: grid) { color, strokeWidth, cornerRadius, col, row in
            if revealed > (col * grid.count) + row {
                let color = grid[col][row]
                SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
            } else {
                SquareView(color: .clear, strokeWidth: 0, cornerRadius: cornerRadius)
            }
        }
//        PixelArtGrid(gridSize: gridSize) { col, row in
//            if revealed > (col * grid.count) + row {
//                let color = grid[col][row]
//                SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
//            } else {
//                SquareView(color: .clear, strokeWidth: 0, cornerRadius: cornerRadius)
//            }
//        }
        .onReceive(timer) { time in
            if isTimerRunning {
                if gridSize == .small || (gridSize == .medium && revealed % 2 == 1) || (gridSize == .large && revealed % 3 == 1) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
                if revealed >= grid.count * grid.count {
                    timer.upstream.connect().cancel()
                    isTimerRunning = false
                    onFinish()
                } else {
                    revealed += 1
                }
            }
        }.onDisappear {
            timer.upstream.connect().cancel()
            isTimerRunning = false
            revealed = 0
            onFinish()
        }.onAppear {
            isTimerRunning = true
        }
    }
}
