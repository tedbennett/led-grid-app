//
//  ColorPickerView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct ColorPickerView: View {
    @ObservedObject var viewModel: DrawViewModel
    
    var body: some View {
        HStack {
            VStack {
                ColorPickerSlider(value: $viewModel.hue).padding(.horizontal, 5)
                    .padding(.vertical, 0)
                    .frame(height: 20)
                OpacityPickerSlider(value: $viewModel.opacity)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 0)
                    .frame(height: 20)
            }
            ZStack {
                SquareView(color: viewModel.currentColor, strokeWidth: 1, cornerRadius: 5)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(10)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(viewModel: DrawViewModel())
    }
}
