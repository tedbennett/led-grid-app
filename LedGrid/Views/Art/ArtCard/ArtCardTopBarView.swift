//
//  ArtCardTopBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI


struct ArtCardTopBarView: View {
    @EnvironmentObject var viewModel: ArtListViewModel
    @EnvironmentObject var reactionsViewModel: ArtReactionsViewModel
    @ObservedObject var art: PixelArt
    @Binding var isAnimating: Bool
    @Binding var currentFrameIndex: Int
    var isDisabled: Bool
    
    @State private var showCopyArtWarning = false
    @State private var showUpgradeWarning = false
    
    func copyReceivedGrid() {
        let payload: [String: Any] = [
            "grids": art.art.toColors(),
            "index": currentFrameIndex
        ]
        NotificationCenter.default.post(name: Notifications.copyGrid, object: nil, userInfo: payload)
    }
    
    var showPlusWarning: Bool {
        return !Utility.isPlus && art.gridSize != .small
    }
    
    var body: some View {
        HStack {
            if reactionsViewModel.openedReactionsId != art.id {
                Button {
                    if showPlusWarning {
                        showUpgradeWarning = true
                    } else {
                        showCopyArtWarning = true
                    }
                } label: {
                    Image(systemName: "square.on.square").font(.title2).frame(width: 25, height: 25)
                }.buttonStyle(StandardButton())
                Button {
                    isAnimating = true
                } label: {
                    Image(systemName: "arrow.counterclockwise").font(.title2).frame(width: 25, height: 25)
                }.buttonStyle(StandardButton())
                if art.art.grids.count > 1 {
                    Button {
                        viewModel.setAnimatingArt(art.id)
                    } label: {
                        Image(systemName: viewModel.animatingId == art.id ? "pause" :  "play").font(.title2).frame(width: 25, height: 25)
                    }.buttonStyle(StandardButton())
                }
            }
            Spacer()
            
//            ArtReactionsView(artId: art.id)
        }.disabled(isDisabled)
        .alert("Copy to canvas", isPresented: $showCopyArtWarning) {
            Button("Copy", role: .destructive) {
                copyReceivedGrid()
                NavigationManager.shared.currentTab = 0
            }.accentColor(.white)
        } message: {
            Text("You are about to copy this art to your canvas. This will erase the art you're currently drawing!")
        }
        .alert("Pixee Plus required", isPresented: $showUpgradeWarning) {
            Button("Upgrade", role: .none) {
                withAnimation {
                    viewModel.showUpgradeView.toggle()
                }
            }.accentColor(.white)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To edit larger sizes of pixel art, you need to upgrade to Pixee Plus.")
        }
    }
}

//struct ArtCardTopBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtCardTopBarView(art: PixelArt.example, isAnimating: .constant(true), currentFrameIndex: .constant(0), isDisabled: false)
//            .environmentObject(ArtReactionsViewModel())
//            .environmentObject(ArtListViewModel(user: User.example))
//            .environmentObject(DrawViewModel())
//    }
//}
