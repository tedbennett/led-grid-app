//
//  ArtCardView.swift
//  LedGrid
//
//  Created by Ted Bennett on 05/10/2022.
//

import SwiftUI
import Combine

struct ArtCardView: View {
    @EnvironmentObject var artViewModel: ArtViewModel
    @EnvironmentObject var viewModel: ArtListViewModel
    @StateObject var reactionViewModel = ArtReactionsViewModel()
    
    var art: PixelArt
    
    @State private var gridIndex = 0
    @State private var hideGrid = true
    @State private var isAnimating = false
    @State private var pauseAnimating = false
    
    init(art: PixelArt) {
        self.art = art
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            ArtCardBottomBarView(art: art)
            
            // Grid View
            Group {
                if hideGrid {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                hideGrid = false
                                isAnimating = true
                                artViewModel.setArtOpened(id: art.id, friend: viewModel.user.id, opened: true)
                            } label: {
                                Text("Tap to view").font(.system(.title3, design: .rounded).weight(.medium)).padding(4)
                            }.buttonStyle(StandardButton())
                            Spacer()
                        }
                        Spacer()
                    }.aspectRatio(1, contentMode: .fit)
                } else if isAnimating {
                    RevealView(grid: art.grids[0]) {
                        isAnimating = false
                        guard art.grids.count > 1 else { return }
                        viewModel.setAnimatingArt(art.id)
                        pauseAnimating = false
                    }
                } else {
                    GridView(grid: art.grids[gridIndex])
                        .drawingGroup()
                        .onTapGesture {
                            guard art.grids.count > 1 else { return }
                            viewModel.setAnimatingArt(art.id)
                            pauseAnimating.toggle()
                        }
                }
            }.padding(.vertical, 5)
            
            // Bottom Bar
            ArtCardTopBarView(art: art, isAnimating: $isAnimating, currentFrameIndex: $gridIndex, isDisabled: hideGrid)
        }.onReceive(viewModel.timer) { time in
            if viewModel.animatingId == art.id && !pauseAnimating {
                gridIndex = gridIndex == art.grids.count - 1 ? 0 : gridIndex + 1
            }
        }.onAppear {
            self.hideGrid = !art.opened
            pauseAnimating = false
        }
    }
}

struct ArtCardView_Previews: PreviewProvider {
    static var previews: some View {
        ArtCardView(art: PixelArt.example2)
            .environmentObject(ArtListViewModel(user: User.example))
            .environmentObject(ArtReactionsViewModel())
            .environmentObject(ArtViewModel())
    }
}
