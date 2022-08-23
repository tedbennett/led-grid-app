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
    @Namespace private var gridAnimation
    
    @State private var showSendView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    DrawTopBarView(viewModel: viewModel, showSendView: $showSendView)
                        .padding(.top, 0)
                        .padding(.bottom, 10)
                    DrawableGridView(viewModel: viewModel)
                        .drawingGroup()
                        .padding(.bottom, 10)
                    ColorPickerView(viewModel: viewModel)
                        .padding(.bottom, 30)
                    DrawActionsView(viewModel: viewModel)
                        .padding(.bottom, 20)
                    Spacer()
                    
                }
                
                .blur(radius: showSendView ? 20 : 0)
                .onTapGesture {
                    if !showSendView { return }
                    withAnimation {
                        showSendView = false
                    }
                }
                .allowsHitTesting(!showSendView)
                if showSendView {
                    ExpandedSendView( isOpened: $showSendView, viewModel: viewModel, namespace: gridAnimation)
                        .padding(10)
                        .transition(AnyTransition.move(edge: .bottom))
                        .zIndex(99)
                }
            }.padding(.horizontal, 20)
                .navigationTitle("Draw Something")
                .onAppear {
                    viewModel.saveGrid()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        viewModel.saveGrid()
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
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView()
            .previewDevice("iPhone 13 mini")
    }
}
