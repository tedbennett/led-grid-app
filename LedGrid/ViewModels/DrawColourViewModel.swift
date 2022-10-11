//
//  DrawColourViewModel.swift
//  LedGrid
//
//  Created by Ted Bennett on 09/10/2022.
//

import SwiftUI

class DrawColourViewModel: ObservableObject {
    @Published var currentColor: Color = .red
    
    @Published var hue = 0.03 {
        didSet {
            updateCurrentColor()
        }
    }
    @Published var opacity = 0.5 {
        didSet {
            updateCurrentColor()
        }
    }
    func updateCurrentColor() {
        currentColor = Color(
           UIColor(
               hue: hue,
               saturation: opacity > 0.5 ? 1 - (2 * (opacity - 0.5)) : 1,
               brightness: opacity < 0.5 ? 2 * opacity : 1,
               alpha: 1.0
           )
       )
    }
    
    func setColor(_ color: Color) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        self.hue = h
        if s >= 0.99 {
            self.opacity = b / 2
        } else if b >= 0.99 {
            self.opacity = 1 - (s / 2)
        } else {
            self.opacity = (s / 2) + (b / 2)
        }
    }
    
    
    func selectColor(_ color: Color) {
        currentColor = color
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
