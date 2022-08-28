//
//  ExpandedSendView.swift
//  LedGrid
//
//  Created by Ted on 09/08/2022.
//

import SwiftUI

struct ExpandedSendView: View {
    @Binding var isOpened: Bool
    @State private var frameIndex = 0
    @ObservedObject var manager = DrawManager.shared
    @ObservedObject var viewModel: DrawViewModel
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    CloseButton {
                        withAnimation {
                            isOpened = false
                        }
                    }.padding(.bottom, 10)
                }
                MiniGridView(grid: manager.grids[frameIndex], viewSize: .large)
                    .drawingGroup()
                    .aspectRatio(contentMode: .fit)
                    .gesture(DragGesture().onChanged { val in
                        if val.translation.height > 50.0 {
                            withAnimation {
                                isOpened = false
                            }
                        }
                    })
                    .padding(.bottom, 20)
//                HStack {
//                    Spacer()
//                    TextField("Title (optional)", text: $viewModel.title)
//                        .multilineTextAlignment(.center)
//                        .textFieldStyle(.plain)
//                        .font(.system(.title, design: .rounded).bold())
//                    Spacer()
//                }.padding(.vertical, 10)
                Text("SEND TO:")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.gray)
                FriendsView(selectedFriends: $viewModel.selectedUsers)
                    .frame(height: 80)
                    .padding(.bottom)
                
                if viewModel.sendingGrid {
                    Button {
                        
                    } label: {
                        Spinner().font(.title)
                    }.buttonStyle(LargeButton())
                        .disabled(true)
                } else {
                    Button {
                        viewModel.sendGrid()
                    } label: {
                        Text("Send")
                    }.buttonStyle(LargeButton())
                        .disabled(viewModel.selectedUsers.isEmpty || viewModel.sentGrid || viewModel.failedToSendGrid)
                }
                
        }
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
            .onReceive(timer) { time in
                frameIndex = frameIndex >= manager.grids.count - 1 ? 0 : frameIndex + 1
            }.onAppear {
                manager.grids[manager.currentGridIndex] = manager.currentGrid
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}

