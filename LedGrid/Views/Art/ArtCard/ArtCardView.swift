//
//  ArtCardView.swift
//  LedGrid
//
//  Created by Ted Bennett on 05/10/2022.
//

import SwiftUI
import Combine

struct ArtCardView: View {
    @EnvironmentObject var viewModel: ArtListViewModel
    
    @ObservedObject var art: PixelArt
    var grids: [Grid]
    
    @State private var gridIndex = 0
    @State private var isRevealing = false
    @State private var pauseAnimating = false
    
    init(art: PixelArt) {
        self.art = art
        self.grids = art.art.toColors()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            ArtCardDetailsView(art: art)
            
            // Grid View
            Group {
                if !art.opened {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                isRevealing = true
                                art.opened = true
                            } label: {
                                Text("Tap to view").font(.system(.title3, design: .rounded).weight(.medium)).padding(4)
                            }.buttonStyle(StandardButton())
                            Spacer()
                        }
                        Spacer()
                    }.aspectRatio(1, contentMode: .fit)
                } else if isRevealing {
                    RevealView(grid: grids[0]) {
                        isRevealing = false
                        guard grids.count > 1 else { return }
                        viewModel.animatingId = art.id
                        pauseAnimating = false
                    }
                } else {
                    GridView(grid: grids[gridIndex])
                        .drawingGroup()
                        .onTapGesture {
                            guard grids.count > 1 else { return }
                            viewModel.setAnimatingArt(art.id)
                            pauseAnimating.toggle()
                        }
                }
            }.padding(.vertical, 5)
            
            // Bottom Bar
            ArtCardActionsView(art: art, isAnimating: $isRevealing, currentFrameIndex: $gridIndex, isDisabled: !art.opened)
        }
        .onReceive(viewModel.timer) { time in
            if viewModel.animatingId == art.id && !pauseAnimating {
                gridIndex = gridIndex == grids.count - 1 ? 0 : gridIndex + 1
            }
        }
        .onAppear {
            pauseAnimating = false
        }
    }
}

//struct ArtCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtCardView(art: PixelArt.example2)
//            .environmentObject(ArtListViewModel(user: User.example))
//            .environmentObject(ArtReactionsViewModel())
//            .environmentObject(ArtViewModel())
//    }
//}
