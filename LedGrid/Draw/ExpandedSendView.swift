//
//  ExpandedSendView.swift
//  LedGrid
//
//  Created by Ted on 09/08/2022.
//

import SwiftUI

struct ExpandedSendView: View {
    @Binding var isOpened: Bool
    @ObservedObject var manager = DrawManager.shared
    @ObservedObject var viewModel: DrawViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        isOpened = false
                    }
                } label: {
                    Image(systemName: "xmark").font(.title2)
                }.buttonStyle(StandardButton(disabled: false))
                    .padding(.bottom, 10)
            }
            MiniGridView(grid: manager.grid, viewSize: .large)
                .drawingGroup()
                .matchedGeometryEffect(id: "draw-grid", in: namespace)
                .aspectRatio(contentMode: .fit)
                .gesture(DragGesture().onChanged { val in
                    if val.translation.height > 50.0 {
                        withAnimation {
                            isOpened = false
                        }
                    }
                })
            Text("SEND TO:")
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.gray)
            FriendsView(selectedFriends: $viewModel.selectedUsers)
                .frame(height: 60)
            Button {
                viewModel.sendGrid()
            } label: {
                if viewModel.sendingGrid {
                    ProgressView()
                } else {
                    Text("Send").font(.system(.title, design: .rounded).bold())
                }
            }
        }.padding(20)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
            .onChange(of: viewModel.sentGrid) { _ in
                if viewModel.sentGrid {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isOpened = false
                        }
                    }
                }
            }
            .onChange(of: viewModel.failedToSendGrid) { _ in
                if viewModel.failedToSendGrid {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isOpened = false
                        }
                    }
                }
            }
    }
}

