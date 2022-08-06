//
//  ColorPickerView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct ColorPickerView: View {
    @ObservedObject var viewModel: DrawViewModel
    @State var opacity = 0.5
    @State var hue = 0.034
    
    func updateColor() {
        viewModel.currentColor = Color(
            UIColor(
                hue: hue,
                saturation: opacity > 0.5 ? 1 - (2 * (opacity - 0.5)) : 1,
                brightness: opacity < 0.5 ? 2 * opacity : 1,
                alpha: 1.0
            )
        )
    }
    
    func updateSliders() {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(viewModel.currentColor).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        self.hue = h
        if s >= 1 {
            
        } else {
            
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                ColorPickerSlider(value: $hue).padding(.horizontal, 5)
                    .padding(.vertical, 0)
                    .frame(height: 20)
                OpacityPickerSlider(value: $opacity)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 0)
                    .frame(height: 20)
            }
            ZStack {
//                ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
//                    .labelsHidden()
//                    .frame(width: 60, height: 60, alignment: .center)
                SquareView(color: viewModel.currentColor, strokeWidth: 1, cornerRadius: 5)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(10)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: hue) { newVal in
            updateColor()
        }
        .onChange(of: opacity) { newVal in
            updateColor()
        }
        .onChange(of: viewModel.currentColor) { newVal in
            
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(viewModel: DrawViewModel())
    }
}
