//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI
import AlertToast

struct DrawView: View {
    @StateObject var drawViewModel = DrawViewModel()
    @StateObject var colorViewModel = DrawColourViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showSendView = false
    @State private var showUpgradeView = false
    
    @State private var initialised = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                RotatingLogoView()
                Spacer()
                VStack(spacing: 10) {
                    ArtActionsView(showSendView: $showSendView, showUpgradeView: $showUpgradeView)
                    
//                    if initialised {
                        DrawGridView(colorViewModel: colorViewModel)
                            .coordinateSpace(name: "draw-grid")
                            .padding(1)
                            .drawingGroup()
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0).onChanged { _ in
                                    if colorViewModel.showSliders {
                                        withAnimation {
                                            colorViewModel.showSliders = false
                                        }
                                    }
                                }
                            )
//                    }
                    
                    EditingToolbarView(viewModel: colorViewModel)
                }.padding(.horizontal, 7)
                
                Spacer()
                Button {
                    drawViewModel.saveGrid()
                    withAnimation {
                        showSendView = true
                    }
                } label: {
                    Label {
                        Text("Send")
                    } icon: {
                        Image(systemName: "paperplane.fill")
                    }
                    .padding(4)
                }.buttonStyle(LargeButton())
                    .padding(.horizontal, 30)
                
                Spacer()
            }.padding(20)
                .blur(radius: showSendView || showUpgradeView ? 20 : 0)
                .allowsHitTesting(!showSendView && !showUpgradeView)
//                .onAppear {
//                    drawViewModel.saveGrid()
//                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        drawViewModel.saveGrid()
                    }
                }
            SlideOverView(isOpened: $showSendView) {
                SendArtView(grids: drawViewModel.grids, isOpened: $showSendView)
            }
            SlideOverView(isOpened: $showUpgradeView) {
                UpgradeView(isOpened: $showUpgradeView)
            }
        }
        .toast(isPresenting: $drawViewModel.sentGrid) {
            AlertToast(type: .complete(.gray), title: "Sent pixel art!")
        }
        .toast(isPresenting: $drawViewModel.failedToSendGrid) {
            AlertToast(type: .error(.gray), title: "Failed to send", subTitle: "Try again later.")
        }
        .toast(isPresenting: $drawViewModel.showColorChangeToast, duration: 1.0) {
            AlertToast(displayMode: .hud, type: .complete(.white), title: "Color copied!")
        }
        .environmentObject(drawViewModel)
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView()
            .environmentObject(DrawViewModel())
            .previewDevice("iPhone 13 mini")
    }
}


//struct AnimatedGridView: View {
//    var grid: Grid
//    var body: some View {
//        GridView(grid: <#T##Grid#>) {
//            Color, Double, Double, Int, Int
//        }
//    }
//}
