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
                SquareView(color: viewModel.currentColor)
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
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(viewModel: DrawViewModel())
    }
}
