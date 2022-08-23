//
//  Spinner.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

struct Spinner: View {
    @State var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 1.3)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        Image(systemName: "square.grid.2x2")
            .padding(0)
        
        .rotationEffect(Angle(degrees: isAnimating ? 360: 0 ))
        
        .task {
            withAnimation(self.foreverAnimation) {
                isAnimating = true
            }
        }
    }
}
