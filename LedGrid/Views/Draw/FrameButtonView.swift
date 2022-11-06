//
//  FrameButtonView.swift
//  LedGrid
//
//  Created by Ted Bennett on 15/10/2022.
//

import SwiftUI

struct FrameButtonView: View {
    @Binding var showUpgradeView: Bool
    @Binding var showEditFrames: Bool
    @EnvironmentObject var viewModel: DrawViewModel
    
    var hasFrames: Bool {
        viewModel.grids.count > 1
    }
    
    var body: some View {
        HStack {
            if hasFrames {
                Button {
                    viewModel.saveGrid()
                    viewModel.changeToGrid(at: viewModel.currentGridIndex - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .padding(.leading)
                        .padding(.vertical)
                }
                .disabled(viewModel.currentGridIndex == 0)
            }
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
                    Text(viewModel.grids.count > 1 ? "\(viewModel.currentGridIndex + 1)/\(viewModel.grids.count)" : "Frames").font(.system(.title3, design: .rounded)).fontWeight(.medium)
                } icon: {
                    Image(systemName: "square.stack.3d.up.fill")
                }.padding(.vertical)
                .padding(.horizontal, hasFrames ? 0 : nil)
            }
            if hasFrames {
                Button {
                    viewModel.saveGrid()
                    viewModel.changeToGrid(at: viewModel.currentGridIndex + 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .padding(.trailing)
                        .padding(.vertical)
                }
                .disabled(viewModel.currentGridIndex == viewModel.grids.count - 1)
            }
        }
        .background(Color.gray.opacity(0.2).cornerRadius(15))
        
    }
}

struct FrameButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FrameButtonView(showUpgradeView: .constant(false), showEditFrames: .constant(false))
    }
}
