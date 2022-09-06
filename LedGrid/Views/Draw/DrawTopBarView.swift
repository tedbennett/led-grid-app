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
    @Binding var showUpgradeView: Bool
    
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
                        guard Utility.isPlus else {
                            withAnimation {
                                showUpgradeView = true
                            }
                            return
                        }
                        if !viewModel.isGridBlank {
                            showChangeSizeWarning = true
                        } else {
                            showChangeSizeDialog = true
                        }
                    } label: {
                        Text("Change Size")
                    }
                    if manager.grids.count == 1 {
                        Button(role: .destructive) {
                            viewModel.clearGrid()
                        } label: {
                            Text("Clear")
                        }
                    } else {
                        Button(role: .destructive) {
                            viewModel.clearGrid()
                        } label: {
                            Text("Clear this frame")
                        }
                        Button(role: .destructive) {
                            viewModel.clearAllGrids()
                        } label: {
                            Text("Clear all frames")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis").font(.system(.title3, design: .rounded).weight(.medium))
                        .padding(15)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2).cornerRadius(15))
                }
                
                Spacer()
                Button {
                    withAnimation {
                        showSendView = true
                    }
                } label: {
                    Label { Text("Send") } icon: { Image(systemName: "paperplane.fill") }.font(.system(.title3, design: .rounded).weight(.medium)).padding(4)
                }.buttonStyle(StandardButton())
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

