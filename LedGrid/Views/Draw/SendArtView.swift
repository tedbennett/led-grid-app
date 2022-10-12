//
//  SendArtView.swift
//  LedGrid
//
//  Created by Ted on 09/08/2022.
//

import SwiftUI

struct SendArtView: View {
    @Binding var isOpened: Bool
    @State private var frameIndex = 0
    @EnvironmentObject var artViewModel: ArtViewModel
    @EnvironmentObject var drawViewModel: DrawViewModel
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @ObservedObject var viewModel: SendArtViewModel
    
    init(grids: [Grid], isOpened: Binding<Bool>) {
        viewModel = SendArtViewModel(grids: grids)
        self._isOpened = isOpened
    }
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var recipientsText: String {
        viewModel.selectedUsers.count > 1 ? "\(viewModel.selectedUsers.count) recipients selected" : "1 recipient selected"
    }
    
    func sendGrid() {
        Task {
            let art = await viewModel.sendArt()
            if let art = art {
                await artViewModel.addSentArt(art)
                await MainActor.run {
                    drawViewModel.sentGrid = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isOpened = false
                    }
                }
            } else {
                await MainActor.run {
                    drawViewModel.failedToSendGrid = true
                }
            }
            // TODO: draw view model toasts
        }
    }
    
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
                GridView(grid: viewModel.grids[frameIndex])
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
                Text("SELECT FRIENDS:")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.gray)
                FriendsView(selectedFriends: $viewModel.selectedUsers)
                    .frame(height: 80)
                    .padding(.bottom)
                if viewModel.sendingArt {
                    Button {
                        // Do nothing
                    } label: {
                        Spinner().font(.title)
                    }.buttonStyle(LargeButton())
                        .disabled(true)
                } else {
                    Button {
                        sendGrid()
                    } label: {
                        Text("Send")
                    }.buttonStyle(LargeButton())
                        .disabled(viewModel.selectedUsers.isEmpty)
                }
                Text(viewModel.selectedUsers.isEmpty ? " " : recipientsText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.gray)
                
        }
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
//            .onChange(of: viewModel.sentGrid) { _ in
//                if viewModel.sentGrid {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        withAnimation {
//                            isOpened = false
//                        }
//                    }
//                }
//            }
//            .onChange(of: viewModel.failedToSendGrid) { _ in
//                if viewModel.failedToSendGrid {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        withAnimation {
//                            isOpened = false
//                        }
//                    }
//                }
//            }
            .onReceive(timer) { time in
                frameIndex = frameIndex >= viewModel.grids.count - 1 ? 0 : frameIndex + 1
            }.onAppear {
                if friendsViewModel.friends.count == 1 {
                    viewModel.selectedUsers = friendsViewModel.friends.map { $0.id }
                }
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}

