//
//  EditingToolbarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/03/2022.
//

import SwiftUI

struct EditingToolbarView: View {
    @ObservedObject var viewModel: DrawColourViewModel
    @EnvironmentObject var drawViewModel: DrawViewModel
    @State var translation = CGSize.zero
    @State private var showSliders = false
    @State private var colour = Color.red
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.translation = value.translation
            }
    }
                      
    var coordinateDrag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onEnded { value in
                if let coordinates = drawViewModel.findGridCoordinates(at: value.location) {
                    drawViewModel.fillGrid(at: coordinates, color: viewModel.currentColor)
                    self.translation = CGSize.zero
                } else {
                    withAnimation {
                        self.translation = CGSize.zero
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            HStack {
                if !showSliders {
                    Button {
                        drawViewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward").font(.system(.title3, design: .rounded).weight(.medium))
                            .padding(4)
                    }.disabled(!drawViewModel.canUndo)
                        .buttonStyle(StandardButton())
                    
                    Button {
                        drawViewModel.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward").font(.system(.title3, design: .rounded).weight(.medium))
                            .padding(4)
                    }.disabled(!drawViewModel.canRedo)
                        .buttonStyle(StandardButton())
                }
                Spacer()
            }
            HStack {
                if showSliders {
                    HStack {
                        VStack {
                            ColorPickerSlider(value: $viewModel.hue).padding(.horizontal, 5)
                                .padding(.vertical, 0)
                                .frame(height: 20)
                            OpacityPickerSlider(value: $viewModel.opacity)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 0)
                                .frame(height: 20)
                        }.coordinateSpace(name: "draw")
                        ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                } else {
                    Spacer()
                }
                ZStack {
                    SquareView(color: viewModel.currentColor, strokeWidth: 1, cornerRadius: 5)
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(10)
    //                    .allowsHitTesting(false)
                        .onTapGesture {
                            withAnimation {
                                showSliders.toggle()
                            }
                        }
                        .simultaneousGesture(simpleDrag)
                        .simultaneousGesture(coordinateDrag)
                    Circle().fill(viewModel.currentColor).frame(width: 40, height: 40).padding(10)
                        .scaleEffect(translation == CGSize.zero ? 0.5 : 1.2)
                        .offset(translation)
                        .shadow(color: translation == CGSize.zero ? .clear : .black, radius: translation == CGSize.zero ? 0 : 5)
    //                    .gesture(
    //                        simpleDrag
    //                    )
    //                    .simultaneousGesture(coordinateDrag)
                }
            }.transition(.slide)
        }
        
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EditingToolbarView(viewModel: DrawColourViewModel())
    }
}
