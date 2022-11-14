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
    @State private var colour = Color.red
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    translation = value.translation
                }
            }
    }
                      
    var coordinateDrag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onEnded { value in
                if let coordinates = drawViewModel.findGridCoordinates(at: value.location) {
                    drawViewModel.fillGrid(at: coordinates, color: viewModel.currentColor)
                    translation = CGSize.zero
                } else {
                    withAnimation(.linear(duration: 0.01)) {
                        translation = CGSize.zero
                    }
                }
            }
    }
    
    var body: some View {
            HStack {
                if !viewModel.showSliders {
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
                ColorPickerView(
                    viewModel: viewModel,
                    translation: $translation,
                    showSliders: $viewModel.showSliders
                ) { drag in
                    withAnimation {
                        translation = drag
                    }
                    if viewModel.showSliders {
                        withAnimation {
                            viewModel.showSliders = false
                        }
                    }
                } onDragEnd: { location in
                    if let coordinates = drawViewModel.findGridCoordinates(at: location) {
                        drawViewModel.fillGrid(at: coordinates, color: viewModel.currentColor)
                        translation = CGSize.zero
                    } else {
                        withAnimation {
                            translation = CGSize.zero
                        }
                    }
                }
            }
//            .transition(.slide)
        }
}

struct EditingToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        EditingToolbarView(viewModel: DrawColourViewModel())
    }
}
