//
//  ArtCardBottomBarView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI

struct ArtCardBottomBarView: View {
    var art: PixelArt
    
    var body: some View {
        HStack {
            Text(art.sentAt.formattedDate())
            Spacer()
            Image(
                systemName: art.sender == Utility.user?.id ?  "arrow.up.right.square" : "arrow.down.left.square"
            ).font(.title2)
        }.foregroundColor(.gray)
    }
}

struct ArtCardBottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        ArtCardBottomBarView(art: PixelArt.example)
    }
}