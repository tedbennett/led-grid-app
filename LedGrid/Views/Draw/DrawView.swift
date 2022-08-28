//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI
import AlertToast

struct DrawView: View {
    @ObservedObject var manager = DrawManager.shared
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showSendView = false
    @State private var showUpgradeView = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Title("Draw Something").frame(width: 100, height: 40)
                    .padding(.top, 45)
                Spacer()
                DrawTopBarView(viewModel: viewModel, showSendView: $showSendView, showUpgradeView: $showUpgradeView)
                    .padding(.top, 0)
                    .padding(.bottom, 10)
                DrawableGridView(viewModel: viewModel)
                    .drawingGroup()
                    .padding(.bottom, 10)
                    .padding(.horizontal, 3)
                ColorPickerView(viewModel: viewModel)
                    .padding(.bottom, 30)
                DrawActionsView(viewModel: viewModel, showUpgradeView: $showUpgradeView)
                    .padding(.bottom, 20)
                Spacer()
                
            }.padding(.horizontal, 20)
            
            .blur(radius: showSendView || showUpgradeView ? 20 : 0)
            .onTapGesture {
                if !showSendView && !showUpgradeView { return }
                withAnimation {
                    showSendView = false
                    showUpgradeView = false
                }
            }
            .allowsHitTesting(!showSendView && !showUpgradeView)
            .onAppear {
                viewModel.saveGrid()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    viewModel.saveGrid()
                }
            }
            
            SlideOverView(isOpened: $showSendView) {
                ExpandedSendView(isOpened: $showSendView, viewModel: viewModel)
            }
            SlideOverView(isOpened: $showUpgradeView) {
                UpgradeView(isOpened: $showUpgradeView)
            }
        }
        .toast(isPresenting: $viewModel.sentGrid) {
            AlertToast(type: .complete(.gray), title: "Sent pixel art!")
        }
        .toast(isPresenting: $viewModel.failedToSendGrid) {
            AlertToast(type: .error(.gray), title: "Failed to send", subTitle: "Try again later.")
        }
        .toast(isPresenting: $viewModel.showColorChangeToast, duration: 1.0) {
            AlertToast(displayMode: .hud, type: .complete(.white), title: "Color copied!")
        }
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView()
            .previewDevice("iPhone 13 mini")
    }
}
