//
//  ArtCardDetailsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/10/2022.
//

import SwiftUI

struct ArtCardDetailsView: View {
    var art: PixelArt
//    var snapshot: () -> UIImage
    
    var body: some View {
        HStack {
            Text(art.sentAt.formattedDate())
            Spacer()
            if art.art.grids.count > 1 {
                Image(systemName: "square.stack.3d.up.fill")
            }
            Image(
                systemName: art.sender == Utility.user?.id ?  "arrow.up.right.square" : "arrow.down.left.square"
            ).font(.title2)
            // TODO: 1.2
//            Button {
//                let image = snapshot()
//                Helpers.presentArtShareSheet(image: image)
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//            }
        }.foregroundColor(.gray)
    }
}

//struct ArtCardBottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtCardDetailsView(art: PixelArt.example)
//    }
//}
