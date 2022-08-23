//
//  DrawTopBarView.swift
//  LedGrid
//
//  Created by Ted on 21/08/2022.
//

import SwiftUI


struct DrawTopBarView: View {
    @ObservedObject var viewModel: DrawViewModel
    @ObservedObject var manager = DrawManager.shared
    @State private var showChangeSizeWarning = false
    @State private var showChangeSizeDialog = false
    @Binding var showSendView: Bool
    
    var body: some View {
        ZStack {
            if manager.grids.count > 1 {
                HStack {
                    Spacer()
                    
                    Text("Frame \(manager.currentGridIndex + 1)/\(manager.grids.count)").font(.caption).foregroundColor(.gray).padding(0)
                    Spacer()
                }
                
            }
            HStack {
                Menu {
                    Button {
                        if !viewModel.isGridBlank {
                            showChangeSizeWarning = true
                        } else {
                            showChangeSizeDialog = true
                        }
                    } label: {
                        Text("Change Size")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.clearGrid()
                    } label: {
                        Text("Clear")
                    }.buttonStyle(StandardButton(disabled: false))
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(.title3, design: .rounded))
                        .padding(5)
                        .padding(.horizontal, 6)
                }
                
                Spacer()
                Button {
                    withAnimation {
                        showSendView = true
                    }
                } label: {
                    Label { Text("Send") } icon: { Image(systemName: "paperplane.fill") }
                        .font(.system(.title3, design: .rounded).bold())
                }
            }
        }.padding(.top, 0)
            .alert("Warning", isPresented: $showChangeSizeWarning) {
                Button("Ok", role: .destructive) { showChangeSizeDialog = true }.accentColor(.white)
            } message: {
                Text("Changing grid size will erase your current art!")
            }
            .confirmationDialog("Change grid size", isPresented: $showChangeSizeDialog) {
                Button("8x8") { viewModel.setGridSize(.small) }
                Button("12x12") { viewModel.setGridSize(.medium) }
                Button("16x16") { viewModel.setGridSize(.large) }
            }
    }
}

