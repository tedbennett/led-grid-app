//
//  ColorPickerView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct ColorPickerView: View {
    @ObservedObject var viewModel: DrawColourViewModel
    @State var translation = CGSize.zero
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.translation = value.translation
            }.onEnded { _ in
                withAnimation {
                    self.translation = CGSize.zero
                }
            }
    }
    
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
                Circle().fill(viewModel.currentColor).frame(width: 40, height: 40).padding(10)
                    .scaleEffect(translation == CGSize.zero ? 0.5 : 1.2)
                    .offset(translation)
                    .shadow(color: translation == CGSize.zero ? .clear : .black, radius: translation == CGSize.zero ? 0 : 5)
                    .gesture(
                        simpleDrag
                    )
            }
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(viewModel: DrawColourViewModel())
    }
}
