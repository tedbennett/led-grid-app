//
//  ArtCardTopBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI


struct ArtCardTopBarView: View {
    @EnvironmentObject var viewModel: ArtListViewModel
    @EnvironmentObject var drawViewModel: DrawViewModel
    @EnvironmentObject var reactionsViewModel: ArtReactionsViewModel
    var art: PixelArt
    @Binding var isAnimating: Bool
    @Binding var currentFrameIndex: Int
    var isDisabled: Bool
    
    @State private var showCopyArtWarning = false
    
    var body: some View {
        HStack {
            if reactionsViewModel.openedReactionsId != art.id {
                Button {
                    showCopyArtWarning = true
                } label: {
                    Image(systemName: "square.and.pencil").font(.title2).frame(width: 25, height: 25)
                }.buttonStyle(StandardButton())
                Button {
                    isAnimating = true
                } label: {
                    Image(systemName: "arrow.counterclockwise").font(.title2).frame(width: 25, height: 25)
                }.buttonStyle(StandardButton())
                if art.grids.count > 1 {
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
                drawViewModel.copyReceivedGrid(art, at: currentFrameIndex)
                NavigationManager.shared.currentTab = 0
            }.accentColor(.white)
        } message: {
            Text("You are about to copy this art to your canvas. This will erase the art you're currently drawing!")
        }
    }
}

struct ArtCardTopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ArtCardTopBarView(art: PixelArt.example, isAnimating: .constant(true), currentFrameIndex: .constant(0), isDisabled: false)
            .environmentObject(ArtReactionsViewModel())
            .environmentObject(ArtListViewModel(user: User.example))
            .environmentObject(DrawViewModel())
    }
}
