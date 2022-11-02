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
    
    var body: some View {
        ZStack {
            VStack {
                
//                Title("Draw Something").frame(width: 100, height: 40)
                RotatingLogoView()
                    .padding(.bottom, 10)
                    
//                    .padding(.top, 45)
                Spacer()
                ArtActionsView(showSendView: $showSendView, showUpgradeView: $showUpgradeView)
                    .padding(.top, 0)
                    .padding(.bottom, 10)
                DrawGridView(colorViewModel: colorViewModel)
                    .coordinateSpace(name: "draw-grid")
                    .padding(2)
                    .drawingGroup()
                    .padding(.bottom, 10)
                    .padding(.horizontal, 3)
                EditingToolbarView(viewModel: colorViewModel)
                    .padding(.bottom, 30)
//                DrawActionsView(showUpgradeView: $showUpgradeView)
//                    .padding(.bottom, 20)
                
                Button {
                    drawViewModel.saveGrid()
                    withAnimation {
                        showSendView = true
                    }
                } label: {
                    HStack {
                        Spacer()
                        Label {
                            Text("Send")
                        } icon: {
                            Image(systemName: "paperplane.fill")
                        }.font(
                            .system(.title3, design: .rounded)
                            .weight(.medium)
                        ).foregroundColor(Color(uiColor: .systemBackground))
                            .padding(4)
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color(uiColor: .label).cornerRadius(15))
                .padding(.horizontal, 30)
                
            }.padding(20)
            
            .blur(radius: showSendView || showUpgradeView ? 20 : 0)
//            .simultaneousGesture(TapGesture().onEnded {
//                if !showSendView && !showUpgradeView { return }
//                withAnimation {
//                    showSendView = false
//                    showUpgradeView = false
//                }
//            })
            .allowsHitTesting(!showSendView && !showUpgradeView)
            .onAppear {
                drawViewModel.saveGrid()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
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
