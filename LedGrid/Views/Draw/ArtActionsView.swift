//
//  ArtActionsView.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI


struct ArtActionsView: View {
    @EnvironmentObject var drawViewModel: DrawViewModel
    
    @State private var showChangeSizeWarning = false
    @State private var showChangeSizeDialog = false
    
    @Binding var showSendView: Bool
    @Binding var showUpgradeView: Bool
    
    @State private var showEditFrames = false
    
    var menu: some View {
        Menu {
            Button {
                guard Utility.isPlus else {
                    withAnimation {
                        showUpgradeView = true
                    }
                    return
                }
                if !drawViewModel.isGridBlank {
                    showChangeSizeWarning = true
                } else {
                    showChangeSizeDialog = true
                }
            } label: {
                Text("Change Size")
            }
            Button {
                drawViewModel.showGuides.toggle()
            } label: {
                HStack {
                    Text("Grid Guides")
                    Spacer()
                    if drawViewModel.showGuides {
                        Image(systemName: "checkmark")
                    }
                }
            }
            if drawViewModel.grids.count == 1 {
                Button(role: .destructive) {
                    drawViewModel.clearGrid()
                } label: {
                    Text("Clear")
                }
            } else {
                Button(role: .destructive) {
                    drawViewModel.clearGrid()
                } label: {
                    Text("Clear this frame")
                }
                Button(role: .destructive) {
                    drawViewModel.clearAllGrids()
                } label: {
                    Text("Clear all frames")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .padding(15)
                .padding(.vertical, 5)
                .background(Color.gray.opacity(0.2).cornerRadius(15))
        }
    }
    
    var body: some View {
        ZStack {
//            if drawViewModel.grids.count > 1 {
//                HStack {
//                    Spacer()
//                    Text("Frame \(drawViewModel.currentGridIndex + 1)/\(drawViewModel.grids.count)").font(.caption).foregroundColor(.gray).padding(0)
//                    Spacer()
//                }
//
//            }
            HStack {
                menu
                
                Spacer()
                
                FrameButtonView(showUpgradeView: $showUpgradeView, showEditFrames: $showEditFrames)
            }
        }.padding(.top, 0)
        .alert("Warning", isPresented: $showChangeSizeWarning) {
            Button("Ok", role: .destructive) { showChangeSizeDialog = true }.accentColor(.white)
        } message: {
            Text("Changing grid size will erase your current art!")
        }
        .confirmationDialog("Change grid size", isPresented: $showChangeSizeDialog) {
            Button("8x8") { drawViewModel.setGridSize(.small) }
            Button("12x12") { drawViewModel.setGridSize(.medium) }
            Button("16x16") { drawViewModel.setGridSize(.large) }
        }
        .sheet(isPresented: $showEditFrames) {
            EditFramesView(isOpened: $showEditFrames)
        }
    }
}

