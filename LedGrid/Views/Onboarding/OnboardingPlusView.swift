//
//  OnboardingPlusView.swift
//  LedGrid
//
//  Created by Ted Bennett on 14/11/2022.
//

import SwiftUI


struct OnboardingPlusView: View {
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "star.circle").font(.largeTitle)
                Text("Pixee Plus")
                    .font(.system(size: 30, design: .rounded).weight(.bold))
            }
            .fadeInWithDelay(0.2)
            .padding(.top, 20)
            Text("Upgrading for a better experience. Benefits include:")
                .font(.system(size: 20, design: .rounded).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.top, 20)
                .fadeInWithDelay(0.4)
            
            
            Spacer()
            
            VStack(spacing: 10) {
                IconListItemView(image: "square.grid.3x3.fill", title: "Multiple Sizes", subtitle: "Create more detailed art with 12x12 and 16x16 grids")
                    .frame(minHeight: 70)
                
                    .fadeInWithDelay(0.5)
                IconListItemView(image: "square.stack.3d.up.fill", title: "Frames", subtitle: "Send movies of multiple grids, just like a gif")
                    .frame(minHeight: 70)
                
                    .fadeInWithDelay(0.6)
                IconListItemView(image: "plus.circle", title: "And More...", subtitle: "Improved widgets and better sharing are on the way")
                    .frame(minHeight: 70)
                    .fadeInWithDelay(0.7)
            }
            
            Spacer()
            
            Text("Upgrade in the Settings tab")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.top)
                .fadeInWithDelay(0.9)
            VStack {
                Button {
                    onComplete()
                } label: {
                    Text("Done")
                }.buttonStyle(LargeButton())
                    .padding(.horizontal, 30)
            }
            .fadeInWithDelay(0.9)
            .padding(.bottom, 60)
        }
    }
}


struct OnboardingPlusView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPlusView {
            
        }
    }
}
