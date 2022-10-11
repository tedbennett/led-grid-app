//
//  LargeSpinner.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

struct SpinningImageView: View {
    @State var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 20.0)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        VStack(spacing: -7) {
            HStack(spacing: -15) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
                
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
            }
            HStack(spacing: -15) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
                
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 96, weight: .thin))
                    .padding(0)
            }
            
        }
        .rotationEffect(Angle(degrees: isAnimating ? 360: 0 ))
        
        .task {
            withAnimation(self.foreverAnimation) {
                isAnimating = true
            }
        }
    }
}

