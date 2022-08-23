//
//  DrawActionsView.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI

struct DrawActionsView: View {
    @ObservedObject var manager = DrawManager.shared
    @ObservedObject var viewModel: DrawViewModel
    @State private var showEditFrames = false
    
    
    var body: some View {
        HStack {
            Button {
                showEditFrames = true
            } label: {
                Label {
                    Text("Frames").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                } icon: {
                    Image(systemName: "square.stack.3d.up.fill")
                }
            }.buttonStyle(StandardButton(disabled: false))
            Spacer()
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: manager.undoStates.isEmpty))
            
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward").font(.system(.title3, design: .rounded).weight(.medium))
                    .padding(4)
            }.buttonStyle(StandardButton(disabled: manager.redoStates.isEmpty))
        }.padding(.vertical, -20)
            .sheet(isPresented: $showEditFrames) {
                EditFramesView(isOpened: $showEditFrames)
            }
    }
}

