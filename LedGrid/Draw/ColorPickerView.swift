//
//  ColorPickerView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct ColorPickerView: View {
    @ObservedObject var viewModel: DrawViewModel
    @State var color: Color = .blue
    
    var body: some View {
        ZStack {
            ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 60, height: 60, alignment: .center)
            SquareView(color: viewModel.currentColor)
                .frame(width: 40, height: 40, alignment: .center)
                .padding(10)
                .allowsHitTesting(false)
        }
    }
}

//struct ColorPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorPickerView(color: .constant(.blue))
//    }
//}
