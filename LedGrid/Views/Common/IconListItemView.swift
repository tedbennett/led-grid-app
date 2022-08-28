//
//  IconListItemView.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI

struct IconListItemView: View {
    var image: String
    var title: String
    var subtitle: String
    
    var body: some View {
        ZStack {
            
            HStack(spacing: 5) {
                Spacer().frame(width: 47, height: 47)
                    .padding(8)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).fontWeight(.medium)
                    Text(subtitle).font(.callout).foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(0)
                        
                        .padding(0)
                        
                }
                Spacer()
            }
            HStack(spacing: 5) {
                Image(systemName: image)
                    .font(Font.system(size: 40))
                    .foregroundColor(.accentColor)
                    .frame(width: 47, height: 47)
                    .padding(8)
                Spacer()
                
            }
        }
    }
}

struct IconListItemView_Previews: PreviewProvider {
    static var previews: some View {
        IconListItemView(image: "square.grid.3x3.fill", title: "Multiple Sizes", subtitle: "Create more detailed art with 12x12 and 16x16 grids")
    }
}
