//
//  RevealView.swift
//  LedGrid
//
//  Created by Ted on 06/08/2022.
//

import SwiftUI

struct RevealView: View {
    let grid: [[Color]]
    var strokeWidth = 1.0
    var cornerRadius = 3.0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    @State private var isTimerRunning = false
    
    @State private var revealed = 0
    
    var body: some View {
        VStack {
            ForEach(0..<8) { col in
                HStack(spacing: 5) {
                    ForEach(0..<8) { row in
                        if revealed > (col * 8) + row {
                            let color = grid[col][row]
                            SquareView(color: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius)
                        } else {
                            SquareView(color: .clear, strokeWidth: 0, cornerRadius: cornerRadius)
                        }
                    }
                }
            }
        }.onReceive(timer) { time in
            if isTimerRunning {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if revealed >= grid.count * grid.count {
                    timer.upstream.connect().cancel()
                    isTimerRunning = false
                } else {
                    revealed += 1
                }
            }
        }.onDisappear {
            timer.upstream.connect().cancel()
            isTimerRunning = false
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isTimerRunning = true
            }
        }
    }
}
