//
//  DrawActionsView.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI
import Sentry

struct DrawActionsView: View {
    @EnvironmentObject var drawViewModel: DrawViewModel
    
    
    @State private var showEditFrames = false
    @Binding var showUpgradeView: Bool
    
    var body: some View {
        HStack {
            Button {
                if Utility.isPlus {
                    showEditFrames.toggle()
                } else {
                    withAnimation {
                        showUpgradeView = true
                    }
                }
            } label: {
                Label {
                    Text("Frames").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                } icon: {
                    Image(systemName: "square.stack.3d.up.fill")
                }.padding(4)
            }.buttonStyle(StandardButton())
            Spacer()
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
        }.padding(.vertical, -20)
            .sheet(isPresented: $showEditFrames) {
                EditFramesView(isOpened: $showEditFrames)
            }
    }
}

